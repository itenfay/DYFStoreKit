//
//  DYFStoreTransaction.h
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

/** Used to represent the state of a transaction.
 
 - DYFStoreTransactionStatePurchased: Indicates that the transaction has been purchased.
 - DYFStoreTransactionStateRestored: Indicates that the transaction has been purchased.
 */
typedef NS_ENUM(NSUInteger, DYFStoreTransactionState) {
    DYFStoreTransactionStatePurchased,
    DYFStoreTransactionStateRestored
};

@interface DYFStoreTransaction : NSObject <NSCoding>

/** The state of this transaction. 0: purchased, 1: restored.
 */
@property (nonatomic, assign) NSUInteger state;

/** A string used to identify a product that can be purchased from within your app.
 */
@property (nonatomic, copy) NSString *productIdentifier;

/** An opaque identifier for the user’s account on your system.
 */
@property (nonatomic, copy) NSString *userIdentifier;

/** When a transaction is restored, the current transaction holds a new transaction timestamp. Your app will read this property to retrieve the restored transaction timestamp.
 */
@property (nonatomic, copy) NSString *originalTransactionTimestamp;

/** When a transaction is restored, the current transaction holds a new transaction identifier. Your app will read this property to retrieve the restored transaction identifier.
 */
@property (nonatomic, copy) NSString *originalTransactionIdentifier;

/** The timestamp when the transaction was added to the server queue. Only valid if state is purchased or restored.
 */
@property (nonatomic, copy) NSString *transactionTimestamp;

/** The unique server-provided identifier. Only valid if state is purchased or restored.
 */
@property (nonatomic, copy) NSString *transactionIdentifier;

/** A base64 signed receipt that records all information about a successful payment transaction.
 
 The contents of this property are undefined except when transactionState is set to purchased.
 
 The receipt is a signed chunk of data that can be sent to the App Store to verify that the payment was successfully processed. This is most useful when designing a store that uses a server separate from the iPhone to verify that payment was processed. For more information on verifying receipts, see [Receipt Validation Programming Guide](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Introduction.html#//apple_ref/doc/uid/TP40010573).
 */
@property (nonatomic, copy) NSString *transactionReceipt;

@end

// The key UserDefaults and Keychain used.
FOUNDATION_EXPORT NSString *const DYFStoreTransactionsKey;
