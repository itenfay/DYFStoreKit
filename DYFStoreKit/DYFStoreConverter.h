//
//  DYFStoreConverter.h
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

/**
 The converter is used to convert json and json object to each other, convert an object and a data object to each other.
 */
@interface DYFStoreConverter : NSObject

/**
 Encodes an object.
 
 @param object An object you want to encode.
 @return The data object into which the archive is written.
 */
+ (NSData *)encodeObject:(id)object;

/**
 Returns an object initialized for decoding data.
 
 @param data An archive previously encoded by NSKeyedArchiver.
 @return An object initialized for decoding data.
 */
+ (id)decodeObject:(NSData *)data;

/**
 Returns JSON data from a Foundation object. The Options for writing JSON data is equivalent to kNilOptions in Objective-C.
 
 @param obj The object from which to generate JSON data. Must not be nil.
 @return JSON data for obj, or nil if an internal error occurs.
 */
+ (NSData *)jsonWithObject:(id)obj;

/**
 Returns JSON data from a Foundation object.
 
 @param obj The object from which to generate JSON data. Must not be nil.
 @param options Options for writing JSON data. The default value is equivalent to kNilOptions in Objective-C.
 @return JSON data for obj, or nil if an internal error occurs.
 */
+ (NSData *)jsonWithObject:(id)obj options:(NSJSONWritingOptions)options;

/**
 Returns JSON string from a Foundation object. The Options for writing JSON data is equivalent to kNilOptions in Objective-C.
 
 @param obj The object from which to generate JSON string. Must not be nil.
 @return JSON string for obj, or nil if an internal error occurs.
 */
+ (NSString *)jsonStringWithObject:(id)obj;

/**
 Returns JSON string from a Foundation object.
 
 @param obj The object from which to generate JSON string. Must not be nil.
 @param options Options for writing JSON data. The default value is equivalent to kNilOptions in Objective-C.
 @return JSON string for obj, or nil if an internal error occurs.
 */
+ (NSString *)jsonStringWithObject:(id)obj options:(NSJSONWritingOptions)options;

/**
 Returns a Foundation object from given JSON data. The options used when creating Foundation objects from JSON data is equivalent to kNilOptions in Objective-C.
 
 @param data A data object containing JSON data.
 @return A Foundation object from the JSON data in data, or nil if an error occurs.
 */
+ (id)jsonObjectWithData:(NSData *)data;

/**
 Returns a Foundation object from given JSON data.
 
 @param data A data object containing JSON data.
 @param options Options used when creating Foundation objects from JSON data. The default value is equivalent to kNilOptions in Objective-C.
 @return A Foundation object from the JSON data in data, or nil if an error occurs.
 */
+ (id)jsonObjectWithData:(NSData *)data options:(NSJSONReadingOptions)options;

/**
 Returns a Foundation object from given JSON string. The options used when creating Foundation objects from JSON data is equivalent to kNilOptions in Objective-C.
 
 @param json A string object containing JSON string.
 @return A Foundation object from the JSON data in data, or nil if an error occurs.
 */
+ (id)jsonObjectWithJSON:(NSString *)json;

/**
 Returns a Foundation object from given JSON string.
 
 @param json A string object containing JSON string.
 @param options Options used when creating Foundation objects from JSON data. The default value is equivalent to kNilOptions in Objective-C.
 @return A Foundation object from the JSON data in data, or nil if an error occurs.
 */
+ (id)jsonObjectWithJSON:(NSString *)json options:(NSJSONReadingOptions)options;

@end
