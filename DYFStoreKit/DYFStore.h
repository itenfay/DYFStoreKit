//
//  DYFStore.h
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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef NS_ENUM(NSInteger, DYFIAPProductRequestStatus) {
    DYFIAPProductFound, // Indicates that there are a valid product.
    DYFIAPProductsFound, // Indicates that there are some valid products.
    DYFIAPIdentifiersNotFound, // indicates that are some invalid product identifiers.
    DYFIAPProductRequestResponse, // Returns valid products and invalid product identifiers.
    DYFIAPRequestFailed // Indicates that the product request failed.
};

typedef NS_ENUM(NSInteger, DYFIAPPurchaseNotificationStatus) {
    DYFIAPStatusPurchasing, // Indicates that the status is purchasing.
    DYFIAPPurchaseFailed, // Indicates that the purchase was unsuccessful.
    DYFIAPPurchaseSucceeded, // Indicates that the purchase was successful.
    DYFIAPRestoredFailed, // Indicates that restoring products was unsuccessful.
    DYFIAPRestoredSucceeded, // Indicates that restoring products was successful.
    DYFIAPDownloadStarted, // Indicates that downloading a hosted content has started.
    DYFIAPDownloadInProgress, // Indicates that a hosted content is currently being downloaded.
    DYFIAPDownloadFailed, // Indicates that downloading a hosted content failed.
    DYFIAPDownloadSucceeded // Indicates that a hosted content was successfully downloaded.
};

// Provides notification about the purchase.
FOUNDATION_EXPORT NSString * __nonnull const DYFIAPPurchaseNotification;

@interface DYFIAPPurchaseNotificationObject : NSObject

// Keeps track of the purchase's status.
@property (nonatomic, assign) DYFIAPPurchaseNotificationStatus status;

// The message indicates an error that occurred.
@property (nonatomic, copy, nullable) NSString *message;

// A value that indicates how much of the file has been downloaded.
@property (nonatomic, assign) float downloadProgress;

// Keeps track of the purchase's transactionIdentifier.
@property (nonatomic, copy, nullable) NSString *transactionId;

@end

@interface DYFStore : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

// The delegate that receives the response of the request.
@property (nonatomic, weak, nullable) id<DYFStoreDelegate> delegate;

// Provides the status of the product request.
@property (nonatomic, assign) DYFIAPProductRequestStatus productRequestStatus;

// Provides an `NSError` object of the product request. The error that caused the request to fail.
@property (nonatomic, strong, nullable) NSError *productRequestError;

// Keeps track of all valid products. These products are available for sale in the App Store.
@property (nonatomic, strong, nullable) NSMutableArray *availableProducts;

// Keeps track of all invalid product identifiers.
@property (nonatomic, strong, nullable) NSMutableArray *invalidProductIds;

// Keeps track of all purchases.
@property (nonatomic, strong, nullable) NSMutableArray *purchasedProducts;

// Keeps track of all restored purchases.
@property (nonatomic, strong, nullable) NSMutableArray *restoredProducts;

// Returns an `DYFStore` instance.
+ (nullable instancetype)helper;

// Queries the App Store about the given product identifier.
- (void)requestProductForId:(nullable NSString *)productId;

// Queries the App Store about the given product identifiers.
- (void)requestProductForIds:(nullable NSArray *)productIds;

// Returns the product by matching a given product identifier.
- (nullable id)getProduct:(nullable NSString *)productId;

// Returns the localized price of product by matching a given product identifier.
- (nullable NSString *)getLocalePrice:(nullable NSString *)productId;

// NO if this device is not able or allowed to make payments.
- (BOOL)canMakePayments;

// Returns whether there are purchased products.
- (BOOL)hasPurchasedProducts;

// Returns whether there are restored products.
- (BOOL)hasRestoredProducts;

// Implements the purchase of a product.
- (void)buyProduct:(nullable SKProduct *)product;

// Implements the purchase of more products.
- (void)buyProduct:(nullable SKProduct *)product quantity:(NSInteger)quantity;

// Implements the restoration of previously completed purchases.
- (void)restoreProducts;

// Removes the transaction from the queue for purchased and restored statuses.
- (void)finishTransaction:(nullable SKPaymentTransaction *)transaction;

// Verifies receipt but recommend to use in server side instead of using this function.
- (void)verifyReceipt:(nonnull NSData *)receiptData;

// Verifies receipt but recommend to use in server side instead of using this function.
// Only used for receipts that contain auto-renewable subscriptions.
// Your app’s shared secret (a hexadecimal string).
- (void)verifyReceipt:(nonnull NSData *)receiptData sharedSecret:(nullable NSString *)secretKey;

@end
