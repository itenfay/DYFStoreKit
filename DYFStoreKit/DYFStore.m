//
//  DYFStore.m
//
//  Created by dyf on 2014/11/4.
//  Copyright © 2014 dyf. ( https://github.com/dgynfi/DYFStoreKit )
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

// Controls the printing of the purchase log.
#ifndef PrintLogFlag
    #define PrintLogFlag              1
#endif

// Print purchase log.
#ifndef PrintLog
    #if PrintLogFlag
        #define PrintLog(format, ...) NSLog((@" [IAP]: " format), ##__VA_ARGS__)
    #else
        #define PrintLog(format, ...) {}
    #endif
#endif

// Provides notification about the purchase.
NSString *const DYFIAPPurchaseNotification = @"DYFIAPPurchaseNotification";

@implementation DYFIAPPurchaseNotificationObject

@end

@interface DYFStore ()

// The store request data for a POST request.
@property (nonatomic, strong) NSData *storeRequestData;

// The request object for fetching products from store.
@property (nonatomic, strong) SKProductsRequest *productsRequest;

@end

@implementation DYFStore

+ (instancetype)helper {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initArray];
        [self addTransactionObserver];
    }
    return self;
}

#pragma mark - Init mutable array

- (void)initArray {
    self.availableProducts = [NSMutableArray arrayWithCapacity:0];
    self.invalidProductIds = [NSMutableArray arrayWithCapacity:0];
    self.purchasedProducts = [NSMutableArray arrayWithCapacity:0];
    self.restoredProducts  = [NSMutableArray arrayWithCapacity:0];
}

#pragma mark - Transaction Observer

- (void)addTransactionObserver {
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)removeTransactionObserver {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

#pragma mark - Request information

// Query the App Store about the given product identifier.
- (void)requestProductForId:(NSString *)productId {
    [self requestProductForIds:[NSArray arrayWithObject:productId]];
}

// Fetch information about your products from the App Store.
- (void)requestProductForIds:(NSArray *)productIds {
    if (!_productsRequest) {
        // Create a product request object and initialize it with our product identifiers.
        NSSet *idsSet = [NSSet setWithArray:productIds];
        _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:idsSet];
        _productsRequest.delegate = self;
        // Send the request to the App Store.
        [_productsRequest start];
    }
}

#pragma mark - SKProductsRequestDelegate

- (BOOL)containsProduct:(SKProduct *)product {
    BOOL re = NO;
    NSString *productId = product.productIdentifier;
    
    for (SKProduct *mProduct in self.availableProducts) {
        NSString *mProductId = mProduct.productIdentifier;
        if ([mProductId isEqualToString:productId]) {
            re = YES;
            break;
        }
    }
    
    return re;
}

// Used to get the App Store's response to your request and notifies your observer.
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    self.productsRequest = nil;
    
    // The products array contains products whose identifiers have been recognized by the App Store.
    NSArray *products = response.products;
    
    // The invalidProductIdentifiers array contains all product identifiers not recognized by the App Store.
    NSArray *invalidProductIds = response.invalidProductIdentifiers;
    
    if ([products count] > 0 && [invalidProductIds count] == 0) {
        if ([products count] > 1) {
            self.productRequestStatus = DYFIAPProductsFound;
        } else {
            self.productRequestStatus = DYFIAPProductFound;
        }
    } else if ([products count] > 0 && [invalidProductIds count] > 0) {
        self.productRequestStatus = DYFIAPProductRequestResponse;
    } else if ([products count] == 0 && [invalidProductIds count] > 0) {
        self.productRequestStatus = DYFIAPIdentifiersNotFound;
    } else  {
        self.productRequestStatus = DYFIAPIdentifiersNotFound;
    }
    
    for (SKProduct *product in products) {
        if (![self containsProduct:product]) {
            [self.availableProducts addObject:product];
        }
    }
    
    for (NSString *invalidProductId in invalidProductIds) {
        PrintLog(@"invalid product identifier: %@.", invalidProductId);
        if (![self.invalidProductIds containsObject:invalidProductId]) {
            [self.invalidProductIds addObject:invalidProductId];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(productRequestDidComplete)]) {
        [self.delegate productRequestDidComplete];
    }
}

#pragma mark - SKRequestDelegate

// Called when the product request failed.
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    self.productsRequest = nil;
    
    // Prints the cause of the product request failure.
    PrintLog(@"Products request error: %zi, %@.", error.code, error.localizedDescription);
    
    self.productRequestStatus = DYFIAPRequestFailed;
    self.productRequestError = error;
    
    if ([self.delegate respondsToSelector:@selector(productRequestDidComplete)]) {
        [self.delegate productRequestDidComplete];
    }
}

// Returns the product by matching a given product identifier.
- (id)getProduct:(NSString *)productId {
    SKProduct *availableProduct = nil;
    for (SKProduct *product in self.availableProducts) {
        NSString *m_id = product.productIdentifier;
        if ([m_id isEqualToString:productId]) {
            availableProduct = product;
        }
    }
    return availableProduct;
}

// Returns the localized price of product by matching a given product identifier.
- (NSString *)getLocalePrice:(NSString *)productId {
    SKProduct *product = [self getProduct:productId];
    if (product) {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:product.priceLocale];
        return [numberFormatter stringFromNumber:product.price];
    }
    return nil;
}

#pragma mark - Can make payments

- (BOOL)canMakePayments {
    return [SKPaymentQueue canMakePayments];
}

#pragma mark - Has purchased products

// Returns whether there are purchased products.
- (BOOL)hasPurchasedProducts {
    // Returns YES if it contains some items and NO, otherwise.
    return (self.purchasedProducts.count > 0);
}

#pragma mark - Has restored products

// Returns whether there are restored purchases.
- (BOOL)hasRestoredProducts {
    // Returns YES if it contains some items and NO, otherwise.
    return (self.restoredProducts.count > 0);
}

#pragma mark - Make a purchase

// Create and add a payment request to the payment queue.
- (void)buyProduct:(SKProduct *)product {
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

// Create and add a mutable payment request to the payment queue.
- (void)buyProduct:(SKProduct *)product quantity:(NSInteger)quantity {
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = quantity;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - Restore purchases

- (void)restoreProducts {
    self.restoredProducts = [NSMutableArray arrayWithCapacity:0];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - Finish transaction

// Remove the transaction from the queue for purchased and restored statuses.
- (void)finishTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

#pragma mark - SKPaymentTransactionObserver

// Called when there are trasactions in the payment queue.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing: {
                PrintLog(@"Purchasing.");
                DYFIAPPurchaseNotificationObject *nObject = [[DYFIAPPurchaseNotificationObject alloc] init];
                nObject.status = DYFIAPStatusPurchasing;
                DYFPostNotificationWithObject(nObject);
                break;
            }
                
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
            case SKPaymentTransactionStateDeferred: {
                // Do not block your UI. Allow the user to continue using your app.
                PrintLog(@"Deferred. Allow the user to continue using your app.");
                break;
            }
#endif
                
            case SKPaymentTransactionStatePurchased: {
                PrintLog(@"Purchased. Deliver content for %@.", transaction.payment.productIdentifier);
                // Check whether the purchased product has content hosted with Apple.
                [self.purchasedProducts addObject:transaction];
                if (transaction.downloads && transaction.downloads.count > 0) {
                    [self completeTransaction:transaction forStatus:DYFIAPDownloadStarted];
                } else {
                    [self completeTransaction:transaction forStatus:DYFIAPPurchaseSucceeded];
                }
                break;
            }
                
            case SKPaymentTransactionStateRestored: {
                PrintLog(@"Restored. Restore content for %@.", transaction.payment.productIdentifier);
                // Send a DYFIAPDownloadStarted notification if it has.
                [self.restoredProducts addObject:transaction];
                if (transaction.downloads && transaction.downloads.count > 0) {
                    [self completeTransaction:transaction forStatus:DYFIAPDownloadStarted];
                } else {
                    [self completeTransaction:transaction forStatus:DYFIAPRestoredSucceeded];
                }
                break;
            }
                
            case SKPaymentTransactionStateFailed: {
                PrintLog(@"Purchase of %@ failed.", transaction.payment.productIdentifier);
                [self.purchasedProducts addObject:transaction];
                [self completeTransaction:transaction forStatus:DYFIAPPurchaseFailed];
                break;
            }
                
            default:
                break;
        }
    }
}

// Called when the payment queue has downloaded content.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray<SKDownload *> *)downloads {
    for (SKDownload *download in downloads) {
        switch (download.downloadState) {
            case SKDownloadStateActive: {
                // The content is being downloaded. Let's provide a download progress to the user.
                DYFIAPPurchaseNotificationObject *nObject = [[DYFIAPPurchaseNotificationObject alloc] init];
                nObject.status = DYFIAPDownloadInProgress;
                nObject.downloadProgress = download.progress*100;
                DYFPostNotificationWithObject(nObject);
                break;
            }
                
            case SKDownloadStateCancelled: {
                // StoreKit saves your downloaded content in the Caches directory. Let's remove it.
                // before finishing the transaction.
                [[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
                [self finishDownloadTransaction:download.transaction];
                break;
            }
                
            case SKDownloadStateFailed: {
                // If a download fails, remove it from the Caches, then finish the transaction.
                // It is recommended to retry downloading the content in this case.
                [[NSFileManager defaultManager] removeItemAtURL:download.contentURL error:nil];
                [self finishDownloadTransaction:download.transaction];
                break;
            }
                
            case SKDownloadStatePaused: {
                PrintLog(@"Download was paused.");
                break;
            }
                
            case SKDownloadStateFinished: {
                // Download is complete. StoreKit saves the downloaded content in the Caches directory.
                PrintLog(@"Finished. Location of downloaded file %@.", download.contentURL);
                [self finishDownloadTransaction:download.transaction];
                break;
            }
                
            case SKDownloadStateWaiting: {
                PrintLog(@"Download Waiting.");
                [[SKPaymentQueue defaultQueue] startDownloads:@[download]];
                break;
            }
                
            default:
                break;
        }
    }
}

// Called when an error occur while restoring purchases. Notify the user about the error.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if (error.code != SKErrorPaymentCancelled) {
        DYFIAPPurchaseNotificationObject *nObject = [[DYFIAPPurchaseNotificationObject alloc] init];
        nObject.status = DYFIAPRestoredFailed;
        nObject.message = error.localizedDescription;
        DYFPostNotificationWithObject(nObject);
    }
}

// Called when all restorable transactions have been processed by the payment queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    PrintLog(@"All restorable transactions have been processed by the payment queue.");
}

// Logs all transactions that have been removed from the payment queue.
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        PrintLog(@"%@ was removed from the payment queue.", transaction.payment.productIdentifier);
    }
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
- (BOOL)paymentQueue:(SKPaymentQueue *)queue shouldAddStorePayment:(SKPayment *)payment forProduct:(SKProduct *)product {
    return YES;
}
#endif

#pragma mark - Complete transaction

// Notify the user about the purchase process. Start the download process if status is
// DYFIAPDownloadStarted. Finish all transactions, otherwise.
- (void)completeTransaction:(SKPaymentTransaction *)transaction forStatus:(NSInteger)status {
    // Do not send any notifications when the user cancels the purchase.
    DYFIAPPurchaseNotificationObject *nObject = [[DYFIAPPurchaseNotificationObject alloc] init];
    nObject.status = status;
    
    if (nObject.status == DYFIAPDownloadStarted) {
        [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
    } else {
        nObject.transactionId = transaction.transactionIdentifier;
        if (transaction.error) {
            nObject.message = transaction.error.localizedDescription;
        }
    }
    
    DYFPostNotificationWithObject(nObject);
}

#pragma mark - Handle download transaction

- (void)finishDownloadTransaction:(SKPaymentTransaction *)transaction {
    // AllAssetsDownloaded indicates whether all content associated with the transaction were downloaded.
    BOOL allAssetsDownloaded = YES;
    
    // A download is complete if its state is SKDownloadStateCancelled, SKDownloadStateFailed, or SKDownloadStateFinished
    // and pending, otherwise. We finish a transaction if and only if all its associated downloads are complete.
    // For the SKDownloadStateFailed case, it is recommended to try downloading the content again before finishing the transaction.
    for (SKDownload *download in transaction.downloads) {
        if (download.downloadState != SKDownloadStateCancelled &&
            download.downloadState != SKDownloadStateFailed &&
            download.downloadState != SKDownloadStateFinished ) {
            // Let's break. We found an ongoing download. Therefore, there are still pending downloads.
            allAssetsDownloaded = NO;
            break;
        }
    }
    
    if (allAssetsDownloaded) {
        // Post a DYFIAPDownloadSucceeded notification if all downloads are complete.
        DYFIAPPurchaseNotificationObject *nObject = [[DYFIAPPurchaseNotificationObject alloc] init];
        nObject.status = DYFIAPDownloadSucceeded;
        DYFPostNotificationWithObject(nObject);
        
        if ([self.restoredProducts containsObject:transaction]) {
            DYFIAPPurchaseNotificationObject *nObject = [[DYFIAPPurchaseNotificationObject alloc] init];
            nObject.status = DYFIAPRestoredSucceeded;
            nObject.transactionId = transaction.transactionIdentifier;
            DYFPostNotificationWithObject(nObject);
        }
    }
}

- (void)verifyReceipt:(NSData *)receiptData {
    [self verifyReceipt:receiptData sharedSecret:nil];
}

- (void)verifyReceipt:(NSData *)receiptData sharedSecret:(NSString *)secretKey {
    NSString *receiptBase64 = [receiptData base64EncodedStringWithOptions:0];
    
    // Create the JSON object that describes the request.
    NSError *error = nil;
    if(secretKey && secretKey.length > 0) {
        NSMutableDictionary *requestContents = [NSMutableDictionary dictionaryWithCapacity:0];
        [requestContents setValue:receiptBase64 forKey:@"receipt-data"];
        [requestContents setValue:secretKey forKey:@"password"];
        self.storeRequestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    } else {
        NSMutableDictionary *requestContents = [NSMutableDictionary dictionaryWithCapacity:0];
        [requestContents setValue:receiptBase64 forKey:@"receipt-data"];
        self.storeRequestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    }
    
    if (!error) {
        [self connectionWithURL:DYFDecodeCString(__68C346B47CD9834D)];
    } else {
        if ([self.delegate respondsToSelector:@selector(verifyReceiptDidCompleteWithData:error:)]) {
            [self.delegate verifyReceiptDidCompleteWithData:nil error:error];
        }
    }
}

- (void)connectionWithURL:(NSString *)urlString {
    // Create a POST request with the receipt data.
    NSURL *requstURL = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requstURL];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:self.storeRequestData];
    
    // Make a connection to the iTunes Store on a background queue.
    __weak __typeof(self) weakSelf = self;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        [weakSelf connectionDidReceiveData:data response:response error:error];
    }];
    [dataTask resume];
}

- (void)connectionDidReceiveData:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!error) {
            NSError *m_error = nil;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&m_error];
            if (!m_error) {
                NSInteger status = [[jsonResponse objectForKey:@"status"] integerValue];
                if (status == 21007) {
                    [self connectionWithURL:DYFDecodeCString(__6FD0F31B976A325E)];
                } else {
                    weakSelf.storeRequestData = nil;
                    if ([weakSelf.delegate respondsToSelector:@selector(verifyReceiptDidCompleteWithData:error:)]) {
                        [weakSelf.delegate verifyReceiptDidCompleteWithData:data error:nil];
                    }
                }
            } else {
                if ([weakSelf.delegate respondsToSelector:@selector(verifyReceiptDidCompleteWithData:error:)]) {
                    [weakSelf.delegate verifyReceiptDidCompleteWithData:nil error:m_error];
                }
            }
        } else {
            if ([weakSelf.delegate respondsToSelector:@selector(verifyReceiptDidCompleteWithData:error:)]) {
                [weakSelf.delegate verifyReceiptDidCompleteWithData:nil error:error];
            }
        }
    });
}

- (void)dealloc {
    [self removeTransactionObserver];
}

@end
