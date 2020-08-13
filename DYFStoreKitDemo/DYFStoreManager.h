//
//  DYFStoreManager.h
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

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonCrypto.h>

#import "NSObject+DYFAdd.h"
#import "UIView+DYFAdd.h"

#import "DYFStore.h"
#import "DYFStoreReceiptVerifier.h"
#import "DYFStoreUserDefaultsPersistence.h"

#import "DYFStoreProduct.h"
#import "DYFStoreViewController.h"

/** Custom method to calculate the SHA-256 hash using Common Crypto.
 */
CG_INLINE NSString *DYF_SHA256_HashValue(NSString *string) {
    
    const int digestLength = CC_SHA256_DIGEST_LENGTH; // 32
    unsigned char md[digestLength];
    
    const char *cStr = [string UTF8String];
    size_t cStrLen = strlen(cStr);
    
    // Confirm that the length of C string is small enough
    // to be recast when calling the hash function.
    if (cStrLen > UINT32_MAX) {
        NSLog(@"C string too long to hash: %@", string);
        return nil;
    }
    
    CC_SHA256(cStr, (CC_LONG)cStrLen, md);
    
    // Convert the array of bytes into a string showing its hex represention.
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < digestLength; i++) {
        
        // Add a dash every four bytes, for readability.
        if (i != 0 && i%4 == 0) {
            //[hash appendString:@"-"];
        }
        [hash appendFormat:@"%02x", md[i]];
    }
    
    return hash;
}

@interface DYFStoreManager : NSObject

/** Constructs a store manager singleton with class method.
 */
+ (instancetype)shared;

/** Requests payment of the product with the given product identifier.
 */
- (void)addPayment:(NSString *)productIdentifier;

/** Requests payment of the product with the given product identifier, an opaque identifier for the user’s account on your system.
 */
- (void)addPayment:(NSString *)productIdentifier userIdentifier:(NSString *)userIdentifier;

/** Requests to restore previously completed purchases.
 */
- (void)restorePurchases;

/** Requests to restore previously completed purchases with an opaque identifier for the user’s account on your system.
 */
- (void)restorePurchases:(NSString *)userIdentifier;

@end
