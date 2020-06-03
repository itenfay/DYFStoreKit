//
//  DYFStoreTransaction.m
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

#import "DYFStoreTransaction.h"
#import "DYFRuntimeProvider.h"

NSString *const DYFStoreTransactionsKey = @"DYFStoreTransactionsKey";

@implementation DYFStoreTransaction

/** The Secure Coding Guide should be consulted when writing methods that decode data.
 
 @return Must return YES on all classes that allow secure coding.
 */
//+ (BOOL)supportsSecureCoding {
//    return YES;
//}

/** Returns an object initialized from data in a given unarchiver.
 
 @param aDecoder An unarchiver object.
 @return An object initialized from data in a given unarchiver.
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        [DYFRuntimeProvider decode:aDecoder forObject:self];
    }
    return self;
}

/** Encodes the receiver using a given archiver.
 
 @param aCoder An archiver object.
 */
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [DYFRuntimeProvider encode:aCoder forObject:self];
}

@end
