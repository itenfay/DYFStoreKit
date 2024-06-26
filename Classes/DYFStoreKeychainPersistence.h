//
//  DYFStoreKeychainPersistence.h
//
//  Created by Tenfay on 2014/11/4. ( https://github.com/itenfay/DYFStoreKit )
//  Copyright © 2014 Tenfay. All rights reserved.
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
#import "DYFStoreTransaction.h"
/** Deprecated. */
#if __has_include(<DYFKeychain/DYFKeychain.h>)

/** The transaction persistence using the keychain.
 */
@interface DYFStoreKeychainPersistence : NSObject

/** Returns a Boolean value that indicates whether a transaction is present in the keychain with a given transaction ientifier.
 
 @param transactionIdentifier The unique server-provided identifier.
 @return True if a transaction is present in the keychain, otherwise false.
 */
- (BOOL)containsTransaction:(NSString *)transactionIdentifier;

/** Stores an `DYFStoreTransaction` object in the keychain item.
 
 @param transaction An `DYFStoreTransaction` object.
 */
- (void)storeTransaction:(DYFStoreTransaction *)transaction;

/** Retrieves an array whose elements are the `DYFStoreTransaction` objects from the keychain.
 
 @return An array whose elements are the `DYFStoreTransaction` objects.
 */
- (NSArray<DYFStoreTransaction *> *)retrieveTransactions;

/** Retrieves an `DYFStoreTransaction` object from the keychain with a given transaction ientifier.
 
 @param transactionIdentifier The unique server-provided identifier.
 @return An `DYFStoreTransaction` object from the keychain.
 */
- (DYFStoreTransaction *)retrieveTransaction:(NSString *)transactionIdentifier;

/** Removes an `DYFStoreTransaction` object from the keychain with a given transaction ientifier.
 
 @param transactionIdentifier The unique server-provided identifier.
 */
- (void)removeTransaction:(NSString *)transactionIdentifier;

/** Removes all transactions from the keychain.
 */
- (void)removeTransactions;

@end

#endif
