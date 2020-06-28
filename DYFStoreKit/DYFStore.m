//
//  DYFStore.m
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

#import "DYFStore.h"

// Returns a Boolean value that indicates whether the receiver implements
// or inherits a method that can respond to a specified message.
#define OBJC_RESPONDS_TO_SEL(target, selector) (target && [target respondsToSelector:selector])

// Provides notification about the purchase.
NSString *const DYFStorePurchasedNotification = @"DYFStorePurchasedNotification";

// Provides notification about the download.
NSString *const DYFStoreDownloadedNotification = @"DYFStoreDownloadedNotification";

// The error domain for store.
NSString *const DYFStoreErrorDomain = @"SKErrorDomain.dyfstore";

@interface DYFStore ()

/** An object that can retrieve localized information from the App Store about a specified list of products.
 */
@property (nonatomic, strong) SKProductsRequest *productsRequest;

/** Accepts the response from the App Store that contains the requested product information.
 */
@property (nonatomic, copy) DYFStoreProductsRequestDidFinish productsRequestDidFinish;

/** Tells the user that the request failed to execute.
 */
@property (nonatomic, copy) DYFStoreProductsRequestDidFail productsRequestDidFail;

/** The number of items the user wants to purchase. It must be greater than 0, the default value is 1.
 */
@property (nonatomic, assign) NSInteger quantity;

/** A request to refresh the receipt, which represents the user's transactions with your app.
 */
@property (nonatomic, strong) SKReceiptRefreshRequest *refreshReceiptRequest;

/** The block to be called if the refresh receipt request is sucessful.
 */
@property (nonatomic, copy) DYFStoreRefreshReceiptSuccessBlock refreshReceiptSuccessBlock;

/** The block to be called if the refresh receipt request fails.
 */
@property (nonatomic, copy) DYFStoreRefreshReceiptFailureBlock refreshReceiptFailureBlock;

@end

@implementation DYFStore

// Provides a global static variable.
static DYFStore *_instance = nil;

+ (instancetype)defaultStore {
    return [[self.class alloc] init];
}

/** Returns a new instance of the receiving class.
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    
    return _instance;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [super init];
        [_instance setup];
    });
    
    return _instance;
}

/** Sets initial value for some member variables.
 */
- (void)setup {
    self.availableProducts     = [NSMutableArray arrayWithCapacity:0];
    self.invalidIdentifiers    = [NSMutableArray arrayWithCapacity:0];
    self.purchasedTranscations = [NSMutableArray arrayWithCapacity:0];
    self.restoredTranscations  = [NSMutableArray arrayWithCapacity:0];
    self.quantity              = 1;
}

#pragma mark - StoreKit Wrapper

/** Adds an observer to the payment queue.
 */
- (void)addPaymentTransactionObserver {
    [SKPaymentQueue.defaultQueue addTransactionObserver:self];
}

/** Removes an observer from the payment queue.
 */
- (void)removePaymentTransactionObserver {
    [SKPaymentQueue.defaultQueue removeTransactionObserver:self];
}

+ (BOOL)canMakePayments {
    return SKPaymentQueue.canMakePayments;
}

- (void)requestProductWithIdentifier:(NSString *)identifier
                             success:(DYFStoreProductsRequestDidFinish)success
                             failure:(DYFStoreProductsRequestDidFail)failure {
    
    if (!identifier || identifier.length == 0) {
        
        self.productsRequestDidFail = failure;
        
        DYFStoreLog(@"This product identifier is null or empty");
        
        NSString *errDesc = NSLocalizedStringFromTable(@"This product identifier is null or empty", @"DYFStore", @"Error description");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errDesc};
        NSError *error = [NSError errorWithDomain:DYFStoreErrorDomain
                                             code:DYFStoreErrorCodeInvalidParameter
                                         userInfo:userInfo];
        
        !self.productsRequestDidFail ?: self.productsRequestDidFail(error);
        
        return;
    }
    
    DYFStoreLog();
    
    [self requestProductWithIdentifiers:@[identifier]
                                success:success
                                failure:failure];
}

- (void)requestProductWithIdentifiers:(NSArray *)identifiers
                              success:(DYFStoreProductsRequestDidFinish)success
                              failure:(DYFStoreProductsRequestDidFail)failure {
    
    if (!identifiers || identifiers.count == 0) {
        
        self.productsRequestDidFail = failure;
        
        DYFStoreLog(@"An array of product identifiers is null or empty");
        
        NSString *errDesc = NSLocalizedStringFromTable(@"An array of product identifiers is null or empty", @"DYFStore", @"Error description");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errDesc};
        NSError *error = [NSError errorWithDomain:DYFStoreErrorDomain
                                             code:DYFStoreErrorCodeInvalidParameter
                                         userInfo:userInfo];
        
        !self.productsRequestDidFail ?: self.productsRequestDidFail(error);
        
        return;
    }
    
    DYFStoreLog(@"product identifiers: %@", identifiers);
    
    if (!self.productsRequest) {
        
        self.productsRequestDidFinish = success;
        self.productsRequestDidFail = failure;
        
        NSSet *setOfProductId = [NSSet setWithArray:identifiers];
        // Creates a product request object and initialize it with our product identifiers.
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:setOfProductId];
        self.productsRequest.delegate = self;
        // Sends the request to the App Store.
        [self.productsRequest start];
    }
}

#pragma mark - Product management

/** Whether the product is contained in the list of available products.
 
 @param product An `SKProduct` object.
 @return True if it is contained, otherwise, false.
 */
- (BOOL)containsProduct:(SKProduct *)product {
    BOOL shouldContain = NO;
    
    for (SKProduct *aProduct in self.availableProducts) {
        NSString *id = aProduct.productIdentifier;
        
        if ([id isEqualToString:product.productIdentifier]) {
            shouldContain = YES;
            break;
        }
    }
    
    return shouldContain;
}

- (SKProduct *)productForIdentifier:(NSString *)productIdentifier {
    SKProduct *product = nil;
    
    for (SKProduct *aProduct in self.availableProducts) {
        NSString *id = aProduct.productIdentifier;
        
        if ([id isEqualToString:productIdentifier]) {
            product = aProduct;
            break;
        }
    }
    
    return product;
}

- (NSString *)localizedPriceOfProduct:(SKProduct *)product {
    
    if (!product) { return nil; }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    
    return [numberFormatter stringFromNumber:product.price];
}

#pragma mark - SKProductsRequestDelegate

// Accepts the response from the App Store that contains the requested product information.
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    DYFStoreLog(@"products request received response");
    
    // The array contains products whose identifiers have been recognized by the App Store.
    NSArray<SKProduct *> *products = response.products;
    // The array contains all product identifiers have not been recognized by the App Store.
    NSArray<NSString *> *invalidProductIdentifiers = response.invalidProductIdentifiers;
    
    for (SKProduct *product in products) {
        DYFStoreLog(@"received product with id: %@", product.productIdentifier);
        
        if (![self containsProduct:product]) {
            [self.availableProducts addObject:product];
        }
    }
    
    for (int idx = 0; idx < invalidProductIdentifiers.count; idx++) {
        NSString *value = invalidProductIdentifiers[idx];
        DYFStoreLog(@"invalid product with id: %@, index: %d", value, idx);
        
        if (![self.invalidIdentifiers containsObject:value]) {
            [self.invalidIdentifiers addObject:value];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        !self.productsRequestDidFinish ?:
        self.productsRequestDidFinish(products, invalidProductIdentifiers);
    });
}

#pragma mark - SKRequestDelegate

// Tells the delegate that the request has completed. When this method is called, your delegate receives no further communication from the request and can release it.
- (void)requestDidFinish:(SKRequest *)request {
    
    if (self.productsRequest && self.productsRequest == request) {
        
        DYFStoreLog(@"products request finished");
        
        self.productsRequest = nil;
        
    } else if (self.refreshReceiptRequest &&
               self.refreshReceiptRequest == request) {
        
        DYFStoreLog(@"refresh receipt finished");
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !self.refreshReceiptSuccessBlock ?:
            self.refreshReceiptSuccessBlock();
        });
        
        self.refreshReceiptRequest = nil;
    }
}

// Tells the delegate that the request failed to execute. The requestDidFinish(_:) method is not called after this method is called.
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    if (self.productsRequest && self.productsRequest == request) {
        
        // Prints the cause of the product request failure.
        DYFStoreLog(@"products request failed with error: %@", error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !self.productsRequestDidFail ?:
            self.productsRequestDidFail(error);
        });
        
        self.productsRequest = nil;
        
    } else if (self.refreshReceiptRequest &&
               self.refreshReceiptRequest == request) {
        
        DYFStoreLog(@"refresh receipt failed with error: %@", error);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            !self.refreshReceiptFailureBlock ?:
            self.refreshReceiptFailureBlock(error);
        });
        
        self.refreshReceiptRequest = nil;
    }
}

#pragma mark - Posts Notification

/** Creates a notification with a given name and sender and posts it to the notification center. The default name of the notification is DYFStorePurchasedNotification.
 
 @param info The `DYFStoreNotificationInfo` object posting the notification.
 */
- (void)postNotification:(DYFStoreNotificationInfo *)info {
    [self postNotificationWithName:DYFStorePurchasedNotification info:info];
}

/** Creates a notification with a given name and sender and posts it to the notification center.
 
 @param name The name of the notification. The default is DYFStorePurchasedNotification.
 @param info The `DYFStoreNotificationInfo` object posting the notification.
 */
- (void)postNotificationWithName:(NSString *)name info:(DYFStoreNotificationInfo *)info {
    [NSNotificationCenter.defaultCenter postNotificationName:name object:info];
}

#pragma mark - Purchases Product

- (BOOL)hasPurchasedTransactions {
    return self.purchasedTranscations.count > 0;
}

- (BOOL)hasRestoredTransactions {
    return self.restoredTranscations.count > 0;
}

- (SKPaymentTransaction *)extractPurchasedTransaction:(NSString *)transactionIdentifier {
    
    __block SKPaymentTransaction *transaction = nil;
    
    if (!transactionIdentifier || transactionIdentifier.length == 0) {
        return transaction;
    }
    
    [self.purchasedTranscations enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SKPaymentTransaction *tempTransaction = obj;
        
        NSString *id = tempTransaction.transactionIdentifier;
        
        DYFStoreLog(@"index: %zi, transactionId: %@", idx, id);
        
        if ([id isEqualToString:transactionIdentifier]) {
            transaction = tempTransaction;
        }
    }];
    
    return transaction;
}

- (SKPaymentTransaction *)extractRestoredTransaction:(NSString *)transactionIdentifier {
    
    __block SKPaymentTransaction *transaction = nil;
    
    if (!transactionIdentifier || transactionIdentifier.length == 0) {
        return transaction;
    }
    
    [self.restoredTranscations enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SKPaymentTransaction *tempTransaction = obj;
        
        NSString *id = tempTransaction.transactionIdentifier;
        NSString *originalId = tempTransaction.originalTransaction.transactionIdentifier;
        
        DYFStoreLog(@"index: %zi, transactionId: %@, originalTransactionId: %@", idx, id, originalId);
        
        if ([id isEqualToString:transactionIdentifier]) {
            transaction = tempTransaction;
        }
    }];
    
    return transaction;
}

- (void)purchaseProduct:(NSString *)productIdentifier {
    [self purchaseProduct:productIdentifier userIdentifier:nil];
}

- (void)purchaseProduct:(NSString *)productIdentifier userIdentifier:(NSString *)userIdentifier {
    [self purchaseProduct:productIdentifier userIdentifier:userIdentifier quantity:1];
}

- (void)purchaseProduct:(NSString *)productIdentifier userIdentifier:(NSString *)userIdentifier quantity:(NSInteger)quantity {
    
    if (!productIdentifier || productIdentifier.length == 0) {
        
        DYFStoreLog(@"The given product identifier is null or empty");
        
        NSString *errDesc = NSLocalizedStringFromTable(@"The given product identifier is null or empty", @"DYFStore", @"Error description");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errDesc};
        NSError *error = [NSError errorWithDomain:DYFStoreErrorDomain
                                             code:DYFStoreErrorCodeInvalidParameter
                                         userInfo:userInfo];
        
        DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
        info.state = DYFStorePurchaseStateFailed;
        info.error = error;
        [self postNotificationWithName:DYFStorePurchasedNotification info:info];
        
        return;
    }
    
    SKProduct *product = [self productForIdentifier:productIdentifier];
    if (product) {
        
        DYFStoreLog(@"productIdentifier: %@, quantity: %zi", productIdentifier, quantity);
        
        self.quantity = quantity;
        
        // Creates and adds a mutable payment request to the payment queue.
        SKMutablePayment *paymet = [SKMutablePayment paymentWithProduct:product];
        paymet.quantity = quantity;
        if (@available(iOS 7.0, *)) {
            paymet.applicationUsername = userIdentifier;
        }
        [SKPaymentQueue.defaultQueue addPayment:paymet];
        
        return;
    }
    
    DYFStoreLog(@"Unknown product identifier: %@", productIdentifier);
    
    NSString *errDesc = NSLocalizedStringFromTable(@"Unknown product identifier", @"DYFStore", @"Error description");
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errDesc};
    NSError *error = [NSError errorWithDomain:DYFStoreErrorDomain
                                         code:DYFStoreErrorCodeUnknownProductIdentifier
                                     userInfo:userInfo];
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.state = DYFStorePurchaseStateFailed;
    info.productIdentifier = productIdentifier;
    info.error = error;
    [self postNotificationWithName:DYFStorePurchasedNotification info:info];
}

- (void)restoreTransactions {
    [self restoreTransactions:nil];
}

- (void)restoreTransactions:(NSString *)userIdentifier {
    self.restoredTranscations = [NSMutableArray arrayWithCapacity:0];
    
    if (!userIdentifier || userIdentifier.length == 0) {
        [SKPaymentQueue.defaultQueue restoreCompletedTransactions];
        return;
    }
    
    NSAssert([SKPaymentQueue.defaultQueue respondsToSelector:@selector(restoreCompletedTransactionsWithApplicationUsername:)], @"restoreCompletedTransactionsWithApplicationUsername: not supported in this iOS version. Use restoreCompletedTransactions instead.");
    
    if (@available(iOS 7.0, *)) {
        [SKPaymentQueue.defaultQueue restoreCompletedTransactionsWithApplicationUsername:userIdentifier];
    } else {
        [SKPaymentQueue.defaultQueue restoreCompletedTransactions];
    }
}

- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    DYFStoreLog(@"transactionIdentifier: %@", transaction.transactionIdentifier ?: @"");
    if (!transaction) { return; }
    [SKPaymentQueue.defaultQueue finishTransaction:transaction];
}

#pragma mark - Receipt

+ (NSURL *)receiptURL {
    // The general best practice of weak linking using the respondsToSelector: method cannot be used here. Prior to iOS 7, the method was implemented as private API, but that implementation called the doesNotRecognizeSelector: method.
    NSAssert(floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1, @"appStoreReceiptURL not supported in this iOS version.");
    NSURL *receiptURL = NSBundle.mainBundle.appStoreReceiptURL;
    return receiptURL;
}

- (void)refreshReceiptOnSuccess:(DYFStoreRefreshReceiptSuccessBlock)successBlock failure:(DYFStoreRefreshReceiptFailureBlock)failureBlock {
    
    if (!self.refreshReceiptRequest) {
        
        self.refreshReceiptSuccessBlock = successBlock;
        self.refreshReceiptFailureBlock = failureBlock;
        
        self.refreshReceiptRequest = [[SKReceiptRefreshRequest alloc] initWithReceiptProperties:@{}];
        self.refreshReceiptRequest.delegate = self;
        [self.refreshReceiptRequest start];
    }
}

#pragma mark - SKPaymentTransactionObserver

// Tells an observer that one or more transactions have been updated.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                [self purchasingTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStatePurchased:
                [self didPurchaseTransaction:transaction queue:queue];
                break;
            case SKPaymentTransactionStateFailed:
                [self didFailWithTransaction:transaction queue:queue error:transaction.error];
                break;
            case SKPaymentTransactionStateRestored:
                [self didRestoreTransaction:transaction queue:queue];
                break;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
            case SKPaymentTransactionStateDeferred:
                [self didDeferTransaction:transaction queue:queue];
                break;
#endif
            default:
                DYFStoreLog(@"Unknown transaction state");
                break;
        }
    }
}

// Tells the observer that the payment queue has updated one or more download objects.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
    
    for (SKDownload *download in downloads) {
        
        SKDownloadState state = [self stateForDownload:download];
        
        switch (state) {
            case SKDownloadStateWaiting:
                DYFStoreLog(@"The download is inactive, waiting to be downloaded.");
                //[queue startDownloads:@[download]];
                break;
            case SKDownloadStateActive:
                [self didUpdateDownload:download queue:queue];
                break;
            case SKDownloadStatePaused:
                [self didPauseDownload:download queue:queue];
                break;
            case SKDownloadStateFinished:
                [self didFinishDownload:download queue:queue];
                break;
            case SKDownloadStateFailed:
                [self didFailWithDownload:download queue:queue];
                break;
            case SKDownloadStateCancelled:
                [self didCancelDownload:download queue:queue];
                break;
            default:
                break;
        }
    }
}

// Tells the observer that the payment queue has finished sending restored transactions.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    DYFStoreLog(@"The payment queue has finished sending restored transactions");
}

// Tells the observer that an error occurred while restoring transactions.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    
    DYFStoreLog(@"The restored transactions failed with error(%@)", error);
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    
    // The user cancels the purchase.
    if (error.code == SKErrorPaymentCancelled) {
        info.state = DYFStorePurchaseStateCancelled;
    } else {
        info.state = DYFStorePurchaseStateRestoreFailed;
    }
    
    info.error = error;
    
    [self postNotification:info];
}

// Tells an observer that one or more transactions have been removed from the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    
    for (SKPaymentTransaction *transaction in transactions) {
        // Logs all transactions that have been removed from the payment queue.
        NSString *productId = transaction.payment.productIdentifier;
        DYFStoreLog(@"%@ has been removed from the payment queue", productId);
    }
}

// Tells the observer that a user initiated an in-app purchase from the App Store.
- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    
    if (@available(iOS 11.0, *)) {
        
        if (![self containsProduct:product]) {
            [self.availableProducts addObject:product];
        }
        
        if (OBJC_RESPONDS_TO_SEL(self.delegate,
                                 @selector(didReceiveAppStorePurchaseRequest:payment:forProduct:))
            ) {
            
            [self.delegate didReceiveAppStorePurchaseRequest:queue payment:payment forProduct:product];
            
        } else { /* Fallback on earlier versions. Never execute. */ }
    }
    
    return NO;
}

#pragma mark - Process Transaction

/** The transaction is being processed by the App Store.
 
 @param transaction An `SKPaymentTransaction` object in the payment queue.
 @param queue The payment queue that updated the transactions.
 */
- (void)purchasingTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue {
    DYFStoreLog(@"The transaction is purchasing");
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.state = DYFStorePurchaseStatePurchasing;
    [self postNotification:info];
}

/** The App Store successfully processed payment. Your application should provide the content the user purchased.
 
 @param transaction An `SKPaymentTransaction` object in the payment queue.
 @param queue The payment queue that updated the transactions.
 */
- (void)didPurchaseTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue {
    DYFStoreLog(@"The transaction purchased. Deliver the content for %@", transaction.payment.productIdentifier);
    
    [self.purchasedTranscations addObject:transaction];
    // Checks whether the purchased product has content hosted with Apple.
    if (transaction.downloads.count > 0) {
        
        // Starts the download process and send a DYFStoreDownloadStateStarted notification.
        [queue startDownloads:transaction.downloads];
        
        DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
        info.downloadState = DYFStoreDownloadStateStarted;
        [self postNotificationWithName:DYFStoreDownloadedNotification info:info];
        
    } else {
        
        [self didFinishTransaction:transaction queue:queue forState:DYFStorePurchaseStateSucceeded];
    }
}

/** The transaction failed. Check the error property to determine what happened.
 
 @param transaction An `SKPaymentTransaction` object in the payment queue.
 @param queue The payment queue that updated the transactions.
 @param error An object describing the error that occurred while processing the transaction.
 */
- (void)didFailWithTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue error:(NSError *)error {
    
    DYFStoreLog(@"The transaction failed with product(%@) and error(%@)", transaction.payment.productIdentifier, error.debugDescription);
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    
    // The user cancels the purchase.
    if (error.code == SKErrorPaymentCancelled) {
        info.state = DYFStorePurchaseStateCancelled;
    } else {
        info.state = DYFStorePurchaseStateFailed;
    }
    
    info.error = error;
    info.productIdentifier = transaction.payment.productIdentifier;
    
    [self postNotification:info];
    [self finishTransaction:transaction];
}

/** This transaction restores content previously purchased by the user. Read the original property to obtain information about the original purchase.
 
 @param transaction An `SKPaymentTransaction` object in the payment queue.
 @param queue The payment queue that updated the transactions.
 */
- (void)didRestoreTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue {
    DYFStoreLog(@"The transaction restored. Restore the content for %@", transaction.payment.productIdentifier);
    
    [self.restoredTranscations addObject:transaction];
    // Sends a DYFStoreDownloadStateStarted notification if it has.
    if (transaction.downloads.count > 0) {
        
        [queue startDownloads:transaction.downloads];
        
        DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
        info.downloadState = DYFStoreDownloadStateStarted;
        [self postNotificationWithName:DYFStoreDownloadedNotification info:info];
        
    } else {
        
        [self didFinishTransaction:transaction queue:queue forState:DYFStorePurchaseStateRestored];
    }
}

/** The transaction is in the queue, but its final status is pending external action such as Ask to Buy. Update your UI to show the deferred state, and wait for another callback that indicates the final status.
 
 @param transaction An `SKPaymentTransaction` object in the payment queue.
 @param queue The payment queue that updated the transactions.
 */
- (void)didDeferTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue {
    // Do not block your UI. Allow the user to continue using your app.
    DYFStoreLog(@"The transaction deferred. Do not block your UI. Allow the user to continue using your app.");
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.state = DYFStorePurchaseStateDeferred;
    [self postNotification:info];
}

/** Notifies the user about the purchase process finished.
 
 @param transaction An `SKPaymentTransaction` object in the payment queue.
 @param queue The payment queue that updated the transactions.
 @param state The state of purchase.
 */
- (void)didFinishTransaction:(SKPaymentTransaction *)transaction queue:(SKPaymentQueue *)queue forState:(DYFStorePurchaseState)state {
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.state = state;
    info.productIdentifier = transaction.payment.productIdentifier;
    if (@available(iOS 7.0, *)) {
        info.userIdentifier = transaction.payment.applicationUsername;
    }
    info.transactionDate = transaction.transactionDate;
    info.transactionIdentifier = transaction.transactionIdentifier;
    
    SKPaymentTransaction *originalTx = transaction.originalTransaction;
    if (originalTx != nil) {
        info.originalTransactionDate = originalTx.transactionDate;
        info.originalTransactionIdentifier = originalTx.transactionIdentifier;
    }
    
    [self postNotification:info];
}

#pragma mark - Download Transaction

- (void)didUpdateDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue {
    DYFStoreLog(@"The download(%@) for product(%@) updated", download.contentIdentifier, download.transaction.payment.productIdentifier);
    
    // The content is being downloaded. Let's provide a download progress to the user.
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.downloadState = DYFStoreDownloadStateInProgress;
    info.downloadProgress = download.progress * 100;
    
    [self postNotificationWithName:DYFStoreDownloadedNotification info:info];
}

- (void)didPauseDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue {
    DYFStoreLog(@"The download(%@) for product(%@) paused", download.contentIdentifier, download.transaction.payment.productIdentifier);
}

- (void)didCancelDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue {
    SKPaymentTransaction *transaction = download.transaction;
    
    DYFStoreLog(@"The download(%@) for product(%@) cancelled", download.contentIdentifier, transaction.payment.productIdentifier);
    
    // StoreKit saves your downloaded content in the Caches directory. Let's remove it.
    NSError *err = nil;
    [NSFileManager.defaultManager removeItemAtURL:download.contentURL error:&err];
    if (err) {
        DYFStoreLog(@"[NSFileManager.defaultManager removeItemAtURL:] (%@)", err.localizedDescription);
    }
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.downloadState = DYFStoreDownloadStateCancelled;
    [self postNotificationWithName:DYFStoreDownloadedNotification info:info];
    
    BOOL hasPendingDownloads = [self.class hasPendingDownloadsInTransaction:transaction];
    if (!hasPendingDownloads) {
        
        NSString *errDesc = NSLocalizedStringFromTable(@"The download cancelled", @"DYFStore", @"Error description");
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: errDesc};
        NSError *error = [NSError errorWithDomain:DYFStoreErrorDomain
                                             code:DYFStoreErrorCodeDownloadCancelled
                                         userInfo:userInfo];
        
        [self didFailWithTransaction:transaction queue:queue error:error];
    }
}

- (void)didFailWithDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue {
    SKPaymentTransaction *transaction = download.transaction;
    NSError *error = download.error;
    
    DYFStoreLog(@"The download(%@) for product(%@) failed with error(%@)", download.contentIdentifier, transaction.payment.productIdentifier, error.localizedDescription);
    
    // If a download fails, remove it from the Caches, then finish the transaction.
    // It is recommended to retry downloading the content in this case.
    NSError *err = nil;
    [NSFileManager.defaultManager removeItemAtURL:download.contentURL error:&err];
    if (err) {
        DYFStoreLog(@"[NSFileManager.defaultManager removeItemAtURL:] (%@)", err.localizedDescription);
    }
    
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.downloadState = DYFStoreDownloadStateFailed;
    info.error = error;
    [self postNotificationWithName:DYFStoreDownloadedNotification info:info];
    
    BOOL hasPendingDownloads = [self.class hasPendingDownloadsInTransaction:transaction];
    if (!hasPendingDownloads) {
        [self didFailWithTransaction:transaction queue:queue error:error];
    }
}

- (void)didFinishDownload:(SKDownload *)download queue:(SKPaymentQueue *)queue {
    SKPaymentTransaction *transaction = download.transaction;
    
    // The download is complete. StoreKit saves the downloaded content in the Caches directory.
    DYFStoreLog("The download(%@) for product(%@) finished. Location of downloaded file(%@)", download.contentIdentifier, transaction.payment.productIdentifier, download.contentURL.absoluteString);
    
    // Post a DYFStoreDownloadStateSucceeded notification if the download is completed.
    DYFStoreNotificationInfo *info = [[DYFStoreNotificationInfo alloc] init];
    info.downloadState = DYFStoreDownloadStateSucceeded;
    [self postNotificationWithName:DYFStoreDownloadedNotification info:info];
    
    // It indicates whether all content associated with the transaction were downloaded.
    BOOL allAssetsDownloaded = YES;
    if ([self.class hasPendingDownloadsInTransaction:transaction]) {
        // We found an ongoing download. Therefore, there are still pending downloads.
        allAssetsDownloaded = NO;
    }
    
    if (allAssetsDownloaded) {
        DYFStorePurchaseState state;
        
        if (transaction.transactionState == SKPaymentTransactionStateRestored) {
            state = DYFStorePurchaseStateRestored;
        } else {
            state = DYFStorePurchaseStateSucceeded;
        }
        
        [self didFinishTransaction:transaction queue:queue forState:state];
    }
}

/** Returns the state that a download operation can be in.
 
 @param download Downloadable content associated with a product.
 @return The state that a download operation can be in.
 */
- (SKDownloadState)stateForDownload:(SKDownload *)download {
    
    SKDownloadState state;
    
    if (@available(iOS 12.0, *)) {
        state = download.state;
    } else {
        state = download.downloadState;
    }
    
    return state;
}

/** Whether there are pending downloads in the transaction.
 
 @param transaction An `SKPaymentTransaction` object in the payment queue.
 @return YES if there are pending downloads and NO, otherwise.
 */
+ (BOOL)hasPendingDownloadsInTransaction:(SKPaymentTransaction *)transaction {
    
    // A download is complete if its state is SKDownloadState.cancelled, SKDownloadState.failed, or SKDownloadState.finished
    // and pending, otherwise. We finish a transaction if and only if all its associated downloads are complete.
    // For the SKDownloadState.failed case, it is recommended to try downloading the content again before finishing the transaction.
    for (SKDownload *download in transaction.downloads) {
        
        SKDownloadState state = [DYFStore.defaultStore stateForDownload:download];
        
        switch (state) {
            case SKDownloadStateActive:
            case SKDownloadStatePaused:
            case SKDownloadStateWaiting:
                return YES;
                
            case SKDownloadStateCancelled:
            case SKDownloadStateFailed:
            case SKDownloadStateFinished:
                continue;
        }
    }
    
    return NO;
}

- (void)dealloc {
    [self removePaymentTransactionObserver];
}

@end

@implementation NSDate (DYFStore)

- (NSString *)toString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    NSString *dateString = [dateFormatter stringFromDate:self];
    
    return dateString;
}

- (NSString *)toGTMString {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale = [NSLocale currentLocale];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss Z";
    
    NSString *dateString = [dateFormatter stringFromDate:self];
    
    return dateString;
}

- (NSString *)timestamp {
    
    NSTimeInterval timeInterval = [self timeIntervalSince1970];
    NSNumber *number = [NSDecimalNumber numberWithDouble:timeInterval];
    
    return [NSString stringWithFormat:@"%@", number];
}

@end

@implementation NSData (DYFStore)

- (NSData *)base64Encode {
    return [self base64EncodedDataWithOptions:kNilOptions];
}

- (NSString *)base64EncodedString {
    return [self base64EncodedStringWithOptions:kNilOptions];
}

- (NSData *)base64Decode {
    return [[NSData alloc] initWithBase64EncodedData:self options:kNilOptions];
}

- (NSString *)base64DecodedString {
    NSData *data = [self base64Decode];
    if (!data) { return nil; }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (DYFStore)

- (NSDate *)timestampToDate {
    return [NSDate dateWithTimeIntervalSince1970:self.doubleValue];
}

- (NSString *)base64Encode {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:kNilOptions];
}

- (NSData *)base64EncodedData {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedDataWithOptions:kNilOptions];
}

- (NSString *)base64Decode {
    NSData *data = [self base64DecodedData];
    if (!data) { return nil; }
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSData *)base64DecodedData {
    return [[NSData alloc] initWithBase64EncodedString:self options:kNilOptions];
}

@end

@implementation DYFStoreNotificationInfo

@end
