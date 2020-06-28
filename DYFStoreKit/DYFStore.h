//
//  DYFStore.h
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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "DYFStoreKeychainPersistence.h"

/** Outputs log to the console in the process of purchasing the `SKProduct` product.
 */
#ifndef DYFStoreLog
#if DEBUG
#define DYFStoreLog(format, ...) NSLog((@"%s [Line: %d] [DYFStore] " format), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define DYFStoreLog(format, ...) while(0){}
#endif
#endif

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

/** The keychain persister that supervises the `DYFStoreTransaction` transactions.
 */
@property (nonatomic, strong) DYFStoreKeychainPersistence *keychainPersister;

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

/** Requests localized information about a product from the Apple App Store. `success` will be called if the products request is successful, `failure` if it isn't.
 
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

/** Requests payment of the product with the given product identifier.
 
 @param productIdentifier The identifier of the product whose payment will be requested.
 */
- (void)purchaseProduct:(NSString *)productIdentifier;

/** Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system.
 
 @param productIdentifier The identifier of the product whose payment will be requested.
 @param userIdentifier An opaque identifier for the user’s account on your system. The recommended implementation is to use a one-way hash of the user’s account name to calculate the value for this property.
 */
- (void)purchaseProduct:(NSString *)productIdentifier
         userIdentifier:(NSString *)userIdentifier;

/** Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system and the number of items the user wants to purchase.
 
 @param productIdentifier The identifier of the product whose payment will be requested.
 @param userIdentifier An opaque identifier for the user’s account on your system. The recommended implementation is to use a one-way hash of the user’s account name to calculate the value for this property.
 @param quantity The number of items the user wants to purchase. The default value is 1.
 */
- (void)purchaseProduct:(NSString *)productIdentifier
         userIdentifier:(NSString *)userIdentifier
               quantity:(NSInteger)quantity;

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

/** Extracts a purchased transaction with a given transaction identifier.
 
 @param transactionIdentifier The unique server-provided identifier.
 @return A purchased `SKPaymentTransaction` object.
 */
- (SKPaymentTransaction *)extractPurchasedTransaction:(NSString *)transactionIdentifier;

/** Extracts a restored transaction with a given transaction identifier.
 
 @param transactionIdentifier The unique server-provided identifier.
 @return A restored `SKPaymentTransaction` object.
 */
- (SKPaymentTransaction *)extractRestoredTransaction:(NSString *)transactionIdentifier;

/** Requests to restore previously completed purchases.
 
 The usage scenes are as follows:
 The apple users log in to other devices and install app.
 The app corresponding to in-app purchase has been uninstalled and reinstalled.
 */
- (void)restoreTransactions;

/** Requests to restore previously completed purchases.
 
 The usage scenes are as follows:
 The apple users log in to other devices and install app.
 The app corresponding to in-app purchase has been uninstalled and reinstalled.
 
 @param userIdentifier An opaque identifier for the user’s account on your system.
 */
- (void)restoreTransactions:(NSString *)userIdentifier;

/** Completes a pending transaction.
 
 A transaction can be finished only after the receipt verification passed under the client and the server can adopt the communication of security and data encryption. In this way, we can avoid refreshing orders and cracking in-app purchase. If we were unable to complete the verification we want StoreKit to keep reminding us of the transaction.
 
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

/** Returns a time interval between the date object and 00:00:00 UTC on 1 January 1970.
 
 @return A time interval between the date object and 00:00:00 UTC on 1 January 1970.
 */
- (NSString *)timestamp;

@end

@interface NSData (DYFStore)

/** Creates a Base64, UTF-8 encoded data object from the data object.
 
 @return A Base64, UTF-8 encoded data object.
 */
- (NSData *)base64Encode;

/** Creates a Base64 encoded string from the data object.
 
 @return A Base64 encoded string.
 */
- (NSString *)base64EncodedString;

/** Creates a data object with the given Base64 encoded data.
 
 @return A data object containing the Base64 decoded data. Returns nil if the data object could not be decoded.
 */
- (NSData *)base64Decode;

/**
 Creates a string object with the given Base64 encoded data.
 
 @return A string object containing the Base64 decoded data. Returns nil if the data object could not be decoded.
 */
- (NSString *)base64DecodedString;

@end

@interface NSString (DYFStore)

/** Creates and returns a date object set to the given number of seconds from 00:00:00 UTC on 1 January 1970.
 
 @return An NSDate object set to seconds seconds from the reference date.
 */
- (NSDate *)timestampToDate;

/** Creates a Base64 encoded string from the string.
 
 @return A Base64 encoded string.
 */
- (NSString *)base64Encode;

/** Creates a Base64, UTF-8 encoded data object from the string.
 
 @return A Base64, UTF-8 encoded data object.
 */
- (NSData *)base64EncodedData;

/** Creates a string object with the given Base64 encoded string.
 
 @return A string object built by Base64 decoding the provided string. Returns nil if the string object could not be decoded.
 */
- (NSString *)base64Decode;

/** Creates a data object with the given Base64 encoded string.
 
 @return A data object built by Base64 decoding the provided string. Returns nil if the string object could not be decoded.
 */
- (NSData *)base64DecodedData;

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

/** A string used to identify a product that can be purchased from within your app.
 */
@property (nonatomic, copy) NSString *productIdentifier;

/** An opaque identifier for the user’s account on your system.
 */
@property (nonatomic, copy) NSString *userIdentifier;

/** When a transaction is restored, the current transaction holds a new transaction date. Your app will read this property to retrieve the restored transaction date.
 */
@property (nonatomic, copy) NSDate *originalTransactionDate;

/** When a transaction is restored, the current transaction holds a new transaction identifier. Your app will read this property to retrieve the restored transaction identifier.
 */
@property (nonatomic, copy) NSString *originalTransactionIdentifier;

/** The date when the transaction was added to the server queue. Only valid if state is SKPaymentTransactionState.purchased or SKPaymentTransactionState.restored.
 */
@property (nonatomic, copy) NSDate *transactionDate;

/** The unique server-provided identifier. Only valid if state is SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored.
 */
@property (nonatomic, copy) NSString *transactionIdentifier;

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
- (void)didReceiveAppStorePurchaseRequest:(SKPaymentQueue *)queue
                                  payment:(SKPayment *)payment
                               forProduct:(SKProduct *)product;

@end
