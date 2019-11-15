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

/** Accepts the response from the App Store that contains the requested product information.
 */
typedef void (^DYFStoreProductsRequestDidFinish)(NSArray *products, NSArray *invalidIdentifiers);

/** Tells the user that the request failed to execute.
 */
typedef void (^DYFStoreProductsRequestDidFail)(NSError *error);

/** The block to be called if the refresh receipt request is sucessful.
 */
typedef void (^DYFStoreRefreshReceiptSuccessBlock)(void);

/** The block to be called if the refresh receipt request fails.
 */
typedef void (^DYFStoreRefreshReceiptFailureBlock)(NSError *error);

/** Provides notification about the purchase.
 */
FOUNDATION_EXPORT NSString *const DYFStorePurchasedNotification;

/** Provides notification about the download.
 */
FOUNDATION_EXPORT NSString *const DYFStoreDownloadedNotification;

/** Declares the protocol processes the purchase which was initiated by user from the App Store.
 */
@protocol DYFStoreAppStorePaymentDelegate;

@interface DYFStore : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

/** The valid products that were available for sale in the App Store.
 */
@property (nonatomic, strong) NSMutableArray *availableProducts;

/** The product identifiers were invalid.
 */
@property (nonatomic, strong) NSMutableArray *invalidIdentifiers;

/** Records those transcations that have been purchased.
 */
@property (nonatomic, strong) NSMutableArray *purchasedTranscations;

/** Records those transcations that have been restored.
 */
@property (nonatomic, strong) NSMutableArray *restoredTranscations;

/** The delegate processes the purchase which was initiated by user from the App Store.
 */
@property (nonatomic, weak) id<DYFStoreAppStorePaymentDelegate> delegate;

/** Constructs a store singleton with class method.
 
 @return A store singleton.
 */
+ (instancetype)defaultStore;

/** Disable this method to make sure the class has only one instance.
 */
+ (instancetype)new NS_UNAVAILABLE;

/** Disable this method to make sure the class has only one instance.
 */
- (id)copy NS_UNAVAILABLE;

/** Disable this method to make sure the class has only one instance.
 */
- (id)mutableCopy NS_UNAVAILABLE;

/** Adds an observer to the payment queue. This must be invoked after the app has finished launching.
 */
- (void)addPaymentTransactionObserver;

/** Whether the user is allowed to make payments.
 
 @return NO if this device is not able or allowed to make payments.
 */
+ (BOOL)canMakePayments;

/** Requests localized information about a product identifier from the Apple App Store. `success` will be called if the products request is successful, `failure` if it isn't.
 
 @param identifier The product identifier for the product you wish to retrieve information of.
 @param success The block to be called if the products request is sucessful. Can be `nil`. It takes two parameters: `products`, an array of SKProducts, one product for each valid product identifier provided in the original request, and `invalidProductIdentifiers`, an array of product identifiers that were not recognized by the App Store.
 @param failure The block to be called if the products request fails. Can be `nil`.
 */
- (void)requestProductWithIdentifier:(NSString *)identifier
                             success:(DYFStoreProductsRequestDidFinish)success
                             failure:(DYFStoreProductsRequestDidFail)failure;

/** Requests localized information about a set of products from the Apple App Store. `success` will be called if the products request is successful, `failure` if it isn't.
 
 @param identifiers The array of product identifiers for the products you wish to retrieve information of.
 @param success The block to be called if the products request is sucessful. Can be `nil`. It takes two parameters: `products`, an array of SKProducts, one product for each valid product identifier provided in the original request, and `invalidProductIdentifiers`, an array of product identifiers that were not recognized by the App Store.
 @param failure The block to be called if the products request fails. Can be `nil`.
 */
- (void)requestProductWithIdentifiers:(NSArray *)identifiers
                              success:(DYFStoreProductsRequestDidFinish)success
                              failure:(DYFStoreProductsRequestDidFail)failure;

/** Requests payment of the product with the given product identifier
 
 @param productIdentifier The identifier of the product whose payment will be requested.
 */
- (void)purchaseProduct:(NSString *)productIdentifier;

/** Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system.
 
 @param productIdentifier The identifier of the product whose payment will be requested.
 @param userIdentifier An opaque identifier for the user’s account on your system. The recommended implementation is to use a one-way hash of the user’s account name to calculate the value for this property.
 */
- (void)purchaseProduct:(NSString *)productIdentifier userIdentifier:(NSString *)userIdentifier;

/** Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system and the number of items the user wants to purchase.
 
 @param productIdentifier The identifier of the product whose payment will be requested.
 @param userIdentifier An opaque identifier for the user’s account on your system. The recommended implementation is to use a one-way hash of the user’s account name to calculate the value for this property.
 @param quantity The number of items the user wants to purchase. The default value is 1.
 */
- (void)purchaseProduct:(NSString *)productIdentifier userIdentifier:(NSString *)userIdentifier quantity:(NSInteger)quantity;

/** Fetches the product by matching a given product identifier.
 
 @param productIdentifier A given product identifier.
 @return An `SKProduct` object.
 */
- (SKProduct *)productForIdentifier:(NSString *)productIdentifier;

/** Fetches the localized price of a given product.
 
 @param product A given product.
 @return The localized price of a given product.
 */
- (NSString *)localizedPriceOfProduct:(SKProduct *)product;

/** Whether there are purchases.
 
 @return YES if it contains some items and NO, otherwise.
 */
- (BOOL)hasPurchasedTransactions;

/**
 Whether there are restored purchases.
 
 @return YES if it contains some items and NO, otherwise.
 */
- (BOOL)hasRestoredTransactions;

/** Extracts the transaction with a given transaction identifier.
 
 @param transactionIdentifier The unique server-provided identifier.
 @return A SKPaymentTransaction object.
 */
- (SKPaymentTransaction *)extractTransaction:(NSString *)transactionIdentifier;

/** Requests to restore previously completed purchases.
 */
- (void)restoreTransactions;

/** Requests to restore previously completed purchases.
 
 @param userIdentifier An opaque identifier for the user’s account on your system.
 */
- (void)restoreTransactions:(NSString *)userIdentifier;

/** Completes a pending transaction.
 
 Your application should call this method from a transaction observer that received a notification from the payment queue. Calling finishTransaction(_:) on a transaction removes it from the queue. Your application should call finishTransaction(_:) only after it has successfully processed the transaction and unlocked the functionality purchased by the user.
 Calling finishTransaction(_:) on a transaction that is in the SKPaymentTransactionState.purchasing state throws an exception.
 
 @param transaction The transaction to finish.
 */
- (void)finishTransaction:(SKPaymentTransaction *)transaction;

/** Fetches the url of the bundle’s App Store receipt, or nil if the receipt is missing.
 If this method returns `nil` you should refresh the receipt by calling `refreshReceipt`.
 
 @return The url of the bundle’s App Store receipt.
 */
+ (NSURL *)receiptURL;

/** Requests to refresh the App Store receipt in case the receipt is invalid or missing. `successBlock` will be called if the refresh receipt request is successful, `failureBlock` if it isn't.
 
 @param successBlock The block to be called if the refresh receipt request is sucessful. Can be `nil`.
 @param failureBlock The block to be called if the refresh receipt request fails. Can be `nil`.
 */
- (void)refreshReceiptOnSuccess:(DYFStoreRefreshReceiptSuccessBlock)successBlock
                        failure:(DYFStoreRefreshReceiptFailureBlock)failureBlock;

@end

@interface NSDate (DYFStore)

/** Returns a string representation of a given date formatted using the receiver’s current settings.
 
 @return A string representation of a given date formatted using the receiver’s current settings.
 */
- (NSString *)toString;


/** Returns a string representation of a given date formatted using the receiver’s current settings.
 
 @return A string representation of a given date formatted using the receiver’s current settings.
 */
- (NSString *)toGTMString;

@end

/** Uses enumeration to inicate the state of purchase.
 */
typedef NS_ENUM(NSUInteger, DYFStorePurchaseState) {
    /** Indicates that the state is purchasing. */
    DYFStorePurchaseStatePurchasing,
    /** Indicates the user cancels the purchase. */
    DYFStorePurchaseStateCancelled,
    /** Indicates that the purchase failed. */
    DYFStorePurchaseStateFailed,
    /** Indicates that the purchase was successful. */
    DYFStorePurchaseStateSucceeded,
    /** Indicates that the restoring transaction was successful. */
    DYFStorePurchaseStateRestored,
    /** Indicates that the restoring transaction failed. */
    DYFStorePurchaseStateRestoreFailed,
    /** Indicates that the transaction was deferred. */
    DYFStorePurchaseStateDeferred
};

/** Uses enumeration to inicate the state of download.
 */
typedef NS_ENUM(NSUInteger, DYFStoreDownloadState) {
    /** Indicates that downloading a hosted content has started. */
    DYFStoreDownloadStateStarted,
    /** Indicates that a hosted content is currently being downloaded. */
    DYFStoreDownloadStateInProgress,
    /** Indicates that your app cancelled the download. */
    DYFStoreDownloadStateCancelled,
    /** Indicates that downloading a hosted content failed. */
    DYFStoreDownloadStateFailed,
    /** Indicates that a hosted content was successfully downloaded. */
    DYFStoreDownloadStateSucceeded
};

/** Uses enumeration to inicate the error code of store.
 */
typedef NS_ENUM(NSUInteger, DYFStoreErrorCode) {
    /** Unknown product identifier. */
    DYFStoreErrorCodeUnknownProductIdentifier = 100,
    /** Invalid parameter indicates that the received value is nil or empty. */
    DYFStoreErrorCodeInvalidParameter = 136,
    /** Indicates that your app cancelled the download. */
    DYFStoreErrorCodeDownloadCancelled = 300
};

// The error domain for store.
FOUNDATION_EXPORT NSString *const DYFStoreErrorDomain;

@interface DYFStoreNotificationInfo : NSObject

/** The state of purchase.
 */
@property (nonatomic, assign) DYFStorePurchaseState state;

/** The state of the download. Only valid if downloading a hosted content.
 */
@property (nonatomic, assign) DYFStoreDownloadState downloadState;

/** A value that indicates how much of the file has been downloaded. Only valid if state is DYFStoreDownloadStateInProgress.
 */
@property (nonatomic, assign) float downloadProgress;

/** This indicates an error occurred.
 */
@property (nonatomic, strong) NSError *error;

/** The date when the transaction was added to the server queue. Only valid if state is SKPaymentTransactionState.purchased or SKPaymentTransactionState.restored.
 */
@property (nonatomic, strong) NSDate *transactionDate;

/** The transaction identifier of purchase.
 */
@property (nonatomic, copy) NSString *transactionIdentifiers;

@end

/** Processes the purchase which was initiated by user from the App Store.
 */
@protocol DYFStoreAppStorePaymentDelegate <NSObject>

/**
 A user initiated an in-app purchase from the App Store.

 @param queue The payment queue on which the payment request was made.
 @param payment The payment request.
 @param product The in-app purchase product.
 */
- (void)didReceiveAppStorePurchaseRequest:(SKPaymentQueue *)queue payment:(SKPayment *)payment forProduct:(SKProduct *)product;

@end
