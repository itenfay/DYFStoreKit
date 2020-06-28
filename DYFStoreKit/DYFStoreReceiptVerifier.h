//
//  DYFStoreReceiptVerifier.h
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

@protocol DYFStoreReceiptVerifierDelegate;

/**
 The class is used to verify in-app purchase receipts.
 */
@interface DYFStoreReceiptVerifier : NSObject

/**
 Callbacks the result of the request that verifies the in-app purchase receipt.
 */
@property (nonatomic, weak, nullable) id<DYFStoreReceiptVerifierDelegate> delegate;

/**
 Cancels the task.
 */
- (void)cancel;

/**
 Cancels all outstanding tasks and then invalidates the session.
 */
- (void)invalidateAndCancel;

/**
 Verifies the in-app purchase receipt, but it is not recommended to use. It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C).
 
 If the receipts are verified by your own server, the client needs to upload these parameters, such as: "transaction identifier, bundle identifier, product identifier, user identifier, shared sceret(Subscription), receipt(Safe URL Base64), original transaction identifier(Optional), original transaction time(Optional) and the device information, etc.".
 
 @param receiptData A signed receipt that records all information about a successful payment transaction.
 */
- (void)verifyReceipt:(nullable NSData *)receiptData;

/**
 Verifies the in-app purchase receipt, but it is not recommended to use. It is better to use your own server to obtain the parameters uploaded from the client to verify the receipt from the app store server (C -> Uploaded Parameters -> S -> App Store S -> S -> Receive And Parse Data -> C).
 
 If the receipts are verified by your own server, the client needs to upload these parameters, such as: "transaction identifier, bundle identifier, product identifier, user identifier, shared sceret(Subscription), receipt(Safe URL Base64), original transaction identifier(Optional), original transaction time(Optional) and the device information, etc.".
 
 @param receiptData A signed receipt that records all information about a successful payment transaction.
 @param secretKey Your app’s shared secret (a hexadecimal string). Only used for receipts that contain auto-renewable subscriptions.
 */
- (void)verifyReceipt:(nullable NSData *)receiptData sharedSecret:(nullable NSString *)secretKey;

/**
 Matches the message with the status code.
 
 @param status The status code of the request response. More, please see [Receipt Validation Programming Guide](https://developer.apple.com/library/archive/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateRemotely.html#//apple_ref/doc/uid/TP40010573-CH104-SW1)
 @return A string that contains the description of status code.
 */
- (NSString *_Nonnull)matchMessageWithStatus:(NSInteger)status;

@end

/**
 The delegate is used to callback the result of verifying the in-app purchase receipt.
 */
@protocol DYFStoreReceiptVerifierDelegate <NSObject>

/**
 Tells the delegate that an in-app purchase receipt verification has completed.
 
 @param verifier A `DYFStoreReceiptVerifier` object.
 @param data The data received from the server, is converted to a dictionary of key-value pairs.
 */
- (void)verifyReceiptDidFinish:(nonnull DYFStoreReceiptVerifier *)verifier didReceiveData:(nullable NSDictionary *)data;

/**
 Tells the delegate that an in-app purchase receipt verification occurs an error.
 
 @param verifier  A `DYFStoreReceiptVerifier` object.
 @param error The error that caused the receipt validation to fail.
 */
- (void)verifyReceipt:(nonnull DYFStoreReceiptVerifier *)verifier didFailWithError:(nonnull NSError *)error;

@end
