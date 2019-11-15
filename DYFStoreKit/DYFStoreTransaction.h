//
//  DYFStoreTransaction.h
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

/**
 Used to represent the state of a transaction.
 
 - DYFStoreTransactionStateCancelled: Indicates that the transaction has been cancelled.
 - DYFStoreTransactionStateFailed: Indicates that the transaction failed.
 - DYFStoreTransactionStatePurchased: Indicates that the transaction has been purchased.
 */
typedef NS_ENUM(NSUInteger, DYFStoreTransactionState) {
    DYFStoreTransactionStateCancelled,
    DYFStoreTransactionStateFailed,
    DYFStoreTransactionStatePurchased
};

@interface DYFStoreTransaction : NSObject <NSCoding>

/**
 The state of this transaction. 0: cancelled, 1: failed, 2: purchased.
 */
@property (nonatomic, assign) NSUInteger state;

/**
 A string used to identify a product that can be purchased from within your app.
 */
@property (nonatomic, copy) NSString *productIdentifier;

/**
 The unique server-provided identifier. Only valid if state is SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored.
 */
@property (nonatomic, copy) NSString *transactionIdentifier;

/**
 The date when the transaction was added to the server queue. Only valid if state is SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored.
 */
@property (nonatomic, strong) NSDate *transactionDate;

/**
 A signed receipt that records all information about a successful payment transaction.
 
 The contents of this property are undefined except when transactionState is set to SKPaymentTransactionStatePurchased.
 
 The receipt is a signed chunk of data that can be sent to the App Store to verify that the payment was successfully processed. This is most useful when designing a store that uses a server separate from the iPhone to verify that payment was processed. For more information on verifying receipts, see [Receipt Validation Programming Guide](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573).
 */
@property (nonatomic, copy) NSData *transactionReceipt;

@end

// The key UserDefaults and Keychain used.
FOUNDATION_EXPORT NSString *const DYFStoreTransactionsKey;
