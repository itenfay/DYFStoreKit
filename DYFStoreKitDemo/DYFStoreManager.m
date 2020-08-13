//
//  DYFStoreManager.m
//
//  Created by dyf on 2014/11/4. ( https://github.com/dgynfi/DYFStoreKit )
//  Copyright © 2014 dyf. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "DYFStoreManager.h"

@interface DYFStoreManager () <DYFStoreReceiptVerifierDelegate>

@property (nonatomic, strong) DYFStoreNotificationInfo *purchaseInfo;
@property (nonatomic, strong) DYFStoreNotificationInfo *downloadInfo;

@property (nonatomic, strong) DYFStoreReceiptVerifier *receiptVerifier;

@end

@implementation DYFStoreManager

// Provides a global static variable.
static DYFStoreManager *_instance = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    [self addStoreObserver];
}

- (void)addPayment:(NSString *)productIdentifier {
    [self addPayment:productIdentifier userIdentifier:nil];
}

- (void)addPayment:(NSString *)productIdentifier userIdentifier:(NSString *)userIdentifier {
    [self showLoading:@"Waiting..."]; // Initiate purchase request.
    [DYFStore.defaultStore purchaseProduct:productIdentifier userIdentifier:userIdentifier];
}

- (void)restorePurchases {
    [self restorePurchases:nil];
}

- (void)restorePurchases:(NSString *)userIdentifier {
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    [self showLoading:@"Restoring..."];
    [DYFStore.defaultStore restoreTransactions:userIdentifier];
}

- (void)addStoreObserver {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(processPurchaseNotification:) name:DYFStorePurchasedNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(processDownloadNotification:) name:DYFStoreDownloadedNotification object:nil];
}

- (void)removeStoreObserver {
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:DYFStorePurchasedNotification
                                                object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:DYFStoreDownloadedNotification
                                                object:nil];
}

- (void)processPurchaseNotification:(NSNotification *)notification {
    
    [self hideLoading];
    self.purchaseInfo = notification.object;
    
    switch (self.purchaseInfo.state) {
        case DYFStorePurchaseStatePurchasing:
            [self showLoading:@"Purchasing..."];
            break;
        case DYFStorePurchaseStateCancelled:
            [self sendNotice:@"You cancel the purchase"];
            break;
        case DYFStorePurchaseStateFailed:
            [self sendNotice:[NSString stringWithFormat:@"An error occurred, %zi", self.purchaseInfo.error.code]];
            break;
        case DYFStorePurchaseStateSucceeded:
        case DYFStorePurchaseStateRestored:
            [self completePayment];
            break;
        case DYFStorePurchaseStateRestoreFailed:
            [self sendNotice:[NSString stringWithFormat:@"An error occurred, %zi", self.purchaseInfo.error.code]];
            break;
        case DYFStorePurchaseStateDeferred:
            DYFStoreLog(@"Deferred");
            break;
        default:
            break;
    }
}

- (void)processDownloadNotification:(NSNotification *)notification {
    
    self.downloadInfo = notification.object;
    
    switch (self.downloadInfo.downloadState) {
        case DYFStoreDownloadStateStarted:
            DYFStoreLog(@"The download started");
            break;
        case DYFStoreDownloadStateInProgress:
            DYFStoreLog(@"The download progress: %.2f%%", self.downloadInfo.downloadProgress);
            break;
        case DYFStoreDownloadStateCancelled:
            DYFStoreLog(@"The download cancelled");
            break;
        case DYFStoreDownloadStateFailed:
            DYFStoreLog(@"The download failed");
            break;
        case DYFStoreDownloadStateSucceeded:
            DYFStoreLog(@"The download succeeded: 100%%");
            break;
        default:
            break;
    }
}

- (void)completePayment {
    DYFStoreNotificationInfo *info = self.purchaseInfo;
    DYFStore *store = DYFStore.defaultStore;
    DYFStoreKeychainPersistence *persister = store.keychainPersister;
    
    NSString *identifier = info.transactionIdentifier;
    if (![persister containsTransaction:identifier]) {
        [self storeReceipt];
        return;
    }
    
    DYFStoreTransaction *tx = [persister retrieveTransaction:identifier];
    NSData *receiptData = tx.transactionReceipt.base64DecodedData;
    DYFStoreLog(@"transaction.state: %zi", tx.state);
    DYFStoreLog(@"transaction.productIdentifier: %@", tx.productIdentifier);
    DYFStoreLog(@"transaction.userIdentifier: %@", tx.userIdentifier);
    DYFStoreLog(@"transaction.transactionIdentifier: %@", tx.transactionIdentifier);
    DYFStoreLog(@"transaction.transactionTimestamp: %@", tx.transactionTimestamp);
    DYFStoreLog(@"transaction.originalTransactionIdentifier: %@", tx.originalTransactionIdentifier);
    DYFStoreLog(@"transaction.originalTransactionTimestamp: %@", tx.originalTransactionTimestamp);
    DYFStoreLog(@"transaction.transactionReceipt: %@", receiptData);
    
    [self verifyReceipt:receiptData];
    
    // Reads the backup data.
    DYFStoreUserDefaultsPersistence *uPersister = [[DYFStoreUserDefaultsPersistence alloc] init];
    if ([uPersister containsTransaction:identifier]) {
        DYFStoreTransaction *tx = [uPersister retrieveTransaction:identifier];
        NSData *receiptData = tx.transactionReceipt.base64DecodedData;
        DYFStoreLog(@"[BAK] transaction.state: %zi", tx.state);
        DYFStoreLog(@"[BAK] transaction.productIdentifier: %@", tx.productIdentifier);
        DYFStoreLog(@"[BAK] transaction.userIdentifier: %@", tx.userIdentifier);
        DYFStoreLog(@"[BAK] transaction.transactionIdentifier: %@", tx.transactionIdentifier);
        DYFStoreLog(@"[BAK] transaction.transactionTimestamp: %@", tx.transactionTimestamp);
        DYFStoreLog(@"[BAK] transaction.originalTransactionIdentifier: %@", tx.originalTransactionIdentifier);
        DYFStoreLog(@"[BAK] transaction.originalTransactionTimestamp: %@", tx.originalTransactionTimestamp);
        DYFStoreLog(@"[BAK] transaction.transactionReceipt: %@", receiptData);
    }
}

- (void)storeReceipt {
    DYFStoreLog();
    
    NSURL *receiptURL = DYFStore.receiptURL;
    NSData *data = [NSData dataWithContentsOfURL:receiptURL];
    if (!data || data.length == 0) {
        [self refreshReceipt];
        return;
    }
    
    DYFStoreNotificationInfo *info = self.purchaseInfo;
    DYFStore *store = DYFStore.defaultStore;
    DYFStoreKeychainPersistence *persister = store.keychainPersister;
    
    DYFStoreTransaction *transaction = [[DYFStoreTransaction alloc] init];
    
    if (info.state == DYFStorePurchaseStateSucceeded) {
        transaction.state = DYFStoreTransactionStatePurchased;
    } else if (info.state == DYFStorePurchaseStateRestored) {
        transaction.state = DYFStoreTransactionStateRestored;
    }
    
    transaction.productIdentifier = info.productIdentifier;
    transaction.userIdentifier = info.userIdentifier;
    transaction.transactionIdentifier = info.transactionIdentifier;
    transaction.transactionTimestamp = info.transactionDate.timestamp;
    transaction.originalTransactionTimestamp = info.originalTransactionDate.timestamp;
    transaction.originalTransactionIdentifier = info.originalTransactionIdentifier;
    
    transaction.transactionReceipt = data.base64EncodedString;
    [persister storeTransaction:transaction];
    
    // Makes the backup data.
    DYFStoreUserDefaultsPersistence *uPersister = [[DYFStoreUserDefaultsPersistence alloc] init];
    if (![uPersister containsTransaction:info.transactionIdentifier]) {
        [uPersister storeTransaction:transaction];
    }
    
    [self verifyReceipt:data];
}

- (void)refreshReceipt {
    DYFStoreLog();
    [self showLoading:@"Refresh receipt..."];
    
    [DYFStore.defaultStore refreshReceiptOnSuccess:^{
        [self storeReceipt];
    } failure:^(NSError *error) {
        [self failToRefreshReceipt];
    }];
}

- (void)failToRefreshReceipt {
    DYFStoreLog();
    [self hideLoading];
    
    [self showAlertWithTitle:NSLocalizedStringFromTable(@"Notification", nil, @"")
                     message:@"Fail to refresh receipt! Please check if your device can access the internet."
           cancelButtonTitle:@"Cancel"
                      cancel:^(UIAlertAction *action) {}
          confirmButtonTitle:NSLocalizedStringFromTable(@"Retry", nil, @"")
                     execute:^(UIAlertAction *action) {
        [self refreshReceipt];
    }];
}

// It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C).
// If the receipts are verified by your own server, the client needs to upload these parameters, such as: "transaction identifier, bundle identifier, product identifier, user identifier, shared sceret(Subscription), receipt(Safe URL Base64), original transaction identifier(Optional), original transaction time(Optional) and the device information, etc.".
- (void)verifyReceipt:(NSData *)receiptData {
    DYFStoreLog();
    [self hideLoading];
    [self showLoading:@"Verify receipt..."];
    
    if (!_receiptVerifier) {
        _receiptVerifier = [[DYFStoreReceiptVerifier alloc] init];
        _receiptVerifier.delegate = self;
    }
    
    NSData *data = receiptData ?: [NSData dataWithContentsOfURL:DYFStore.receiptURL];
    DYFStoreLog(@"data: %@", data);
    
    [_receiptVerifier verifyReceipt:data];
    // Only used for receipts that contain auto-renewable subscriptions.
    //[_receiptVerifier verifyReceipt:data sharedSecret:@"A43512564ACBEF687924646CAFEFBDCAEDF4155125657"];
}

- (void)retryToVerifyReceipt {
    DYFStoreNotificationInfo *info = self.purchaseInfo;
    DYFStore *store = DYFStore.defaultStore;
    DYFStoreKeychainPersistence *persister = store.keychainPersister;
    
    NSString *identifier = info.transactionIdentifier;
    DYFStoreTransaction *transaction = [persister retrieveTransaction:identifier];
    NSData *receiptData = transaction.transactionReceipt.base64DecodedData;
    [self verifyReceipt:receiptData];
}

- (void)verifyReceiptDidFinish:(nonnull DYFStoreReceiptVerifier *)verifier didReceiveData:(nullable NSDictionary *)data {
    DYFStoreLog(@"data: %@", data);
    
    [self hideLoading];
    [self showTipsMessage:@"Purchase Successfully"];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        
        DYFStoreNotificationInfo *info = self.purchaseInfo;
        DYFStore *store = DYFStore.defaultStore;
        DYFStoreKeychainPersistence *persister = store.keychainPersister;
        
        if (info.state == DYFStorePurchaseStateRestored) {
            
            SKPaymentTransaction *transaction = [store extractRestoredTransaction:info.transactionIdentifier];
            [store finishTransaction:transaction];
            
        } else {
            
            SKPaymentTransaction *transaction = [store extractPurchasedTransaction:info.transactionIdentifier];
            // The transaction can be finished only after the client and server adopt secure communication and data encryption and the receipt verification is passed. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification, we want `StoreKit` to keep reminding us that there are still outstanding transactions.
            [store finishTransaction:transaction];
        }
        
        [persister removeTransaction:info.transactionIdentifier];
        if (info.originalTransactionIdentifier) {
            [persister removeTransaction:info.originalTransactionIdentifier];
        }
    });
}

- (void)verifyReceipt:(nonnull DYFStoreReceiptVerifier *)verifier didFailWithError:(nonnull NSError *)error {
    
    // Prints the reason of the error.
    DYFStoreLog(@"error: %zi, %@", error.code, error.localizedDescription);
    
    [self hideLoading];
    
    // An error occurs that has nothing to do with in-app purchase. Maybe it's the internet.
    if (error.code < 21000) {
        
        // After several attempts, you can cancel refreshing receipt.
        [self showAlertWithTitle:NSLocalizedStringFromTable(@"Notification", nil, @"")
                         message:@"Fail to verify receipt! Please check if your device can access the internet."
               cancelButtonTitle:@"Cancel"
                          cancel:NULL
              confirmButtonTitle:NSLocalizedStringFromTable(@"Retry", nil, @"")
                         execute:^(UIAlertAction *action) {
            [self verifyReceipt:nil];
        }];
        
        return;
    }
    
    [self showTipsMessage:@"Fail to purchase product!"];
    
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC));
    dispatch_after(time, dispatch_get_main_queue(), ^{
        DYFStoreNotificationInfo *info = self.purchaseInfo;
        DYFStore *store = DYFStore.defaultStore;
        DYFStoreKeychainPersistence *persister = store.keychainPersister;
        
        if (info.state == DYFStorePurchaseStateRestored) {
            
            SKPaymentTransaction *transaction = [store extractRestoredTransaction:info.transactionIdentifier];
            [store finishTransaction:transaction];
            
        } else {
            
            SKPaymentTransaction *transaction = [store extractPurchasedTransaction:info.transactionIdentifier];
            // The transaction can be finished only after the client and server adopt secure communication and data encryption and the receipt verification is passed. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification, we want `StoreKit` to keep reminding us that there are still outstanding transactions.
            [store finishTransaction:transaction];
        }
        
        [persister removeTransaction:info.transactionIdentifier];
        if (info.originalTransactionIdentifier) {
            [persister removeTransaction:info.originalTransactionIdentifier];
        }
    });
}

- (void)sendNotice:(NSString *)message {
    [self showAlertWithTitle:NSLocalizedStringFromTable(@"Notification", nil, @"")
                     message:message
           cancelButtonTitle:nil
                      cancel:NULL
          confirmButtonTitle:NSLocalizedStringFromTable(@"I see!", nil, @"")
                     execute:^(UIAlertAction *action) {
        DYFStoreLog(@"alert action title: %@", action.title);
    }];
}

- (void)dealloc {
    [self removeStoreObserver];
}

@end
