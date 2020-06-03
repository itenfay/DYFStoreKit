//
//  DYFRuntimeProvider.h
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
 The class for runtime wrapper that provides some common practical applications.
 */
@interface DYFRuntimeProvider : NSObject

/**
 Describes the instance methods implemented by a class.
 
 @param cls The class you want to inspect.
 @return String array of the instance methods.
 */
+ (NSArray *)methodListWithClass:(Class)cls;

/**
 To get the class methods of a class.
 
 @param obj The object you want to inspect.
 @return String array of the class methods.
 */
+ (NSArray *)classMethodList:(id)obj;

/**
 Describes the instance variables declared by a class.
 
 @param cls The class you want to inspect.
 @return String array of the instance variables.
 */
+ (NSArray *)ivarListWithClass:(Class)cls;

/**
 Adds a new method to a class with a given selector and implementation.
 
 @param cls The class to which to add a method.
 @param sel A selector that specifies the name of the method being added.
 @param impCls The class you want to inspect.
 @param impSel The selector of the method you want to retrieve.
 @return A Bool value.
 */
+ (BOOL)addMethodWithClass:(Class)cls selector:(SEL)sel impClass:(Class)impCls impSelector:(SEL)impSel;

/**
 Adds a new method to a class with a given selector and implementation.
 
 @param cls The class to which to add a method.
 @param sel A selector that specifies the name of the method being added.
 @param impCls The class you want to inspect.
 @param impSel The selector of the method you want to retrieve.
 @param types A string describing a method's parameter and return types. e.g.: "v@:"
 @return A Bool value.
 */
+ (BOOL)addMethodWithClass:(Class)cls selector:(SEL)sel impClass:(Class)impCls impSelector:(SEL)impSel types:(NSString *)types;

/**
 Exchanges the implementations of two methods.
 
 @param cls The class you want to modify.
 @param sel A selector that identifies the method whose implementation you want to exchange.
 @param targetCls The class you want to specify.
 @param targetSel The selector of the method you want to retrieve.
 */
+ (void)exchangeMethodWithClass:(Class)cls selector:(SEL)sel targetClass:(Class)targetCls targetSelector:(SEL)targetSel;

/**
 Replaces the implementation of a method for a given class.
 
 @param cls The class you want to modify.
 @param sel A selector that identifies the method whose implementation you want to replace.
 @param targetCls The class you want to specify.
 @param targetSel The selector of the method you want to retrieve.
 */
+ (void)replaceMethodWithClass:(Class)cls selector:(SEL)sel targetClass:(Class)targetCls targetSelector:(SEL)targetSel;

/**
 Describes the properties declared by a class.
 
 @param cls The class you want to inspect.
 @return String array of the properties.
 */
+ (NSArray *)propertyListWithClass:(Class)cls;

/**
 Converts a dictionary whose elements are key-value pairs to a corresponding object.
 
 @param dictionary A collection whose elements are key-value pairs.
 @param cls A class that inherits the NSObject class.
 @return A corresponding object.
 */
+ (id)modelWithDictionary:(NSDictionary *)dictionary forClass:(Class)cls;

/**
 Converts a object to a corresponding dictionary whose elements are key-value pairs.
 
 @param model A NSObject object.
 @return A corresponding dictionary.
 */
+ (NSDictionary *)dictionaryWithModel:(id)model;

/**
 Encodes an object using a given archiver.
 
 @param encoder An archiver object.
 @param obj An object you want to encode.
 */
+ (void)encode:(NSCoder *)encoder forObject:(NSObject *)obj;

/**
 Decodes an object initialized from data in a given unarchiver.
 
 @param decoder An unarchiver object.
 @param obj An object you want to decode.
 */
+ (void)decode:(NSCoder *)decoder forObject:(NSObject *)obj;

/**
 Archives an object by encoding it into a data object, then atomically writes the resulting data object to a file at a given path, and returns a Boolean value that indicates whether the operation was successful.
 
 @param object The object you want to archive.
 @param cls The class you want to inspect.
 @param path The path of the file in which to write the archive.
 @return YES if the operation was successful, otherwise NO.
 */
+ (BOOL)archiveWithObject:(id)object forClass:(Class)cls toFile:(NSString *)path;

/**
 Decodes and returns the object previously encoded by NSKeyedArchiver written to the file at a given path.
 
 @param path A path to a file that contains an object previously encoded by NSKeyedArchiver.
 @param cls The class you want to inspect.
 @return The object previously encoded by NSKeyedArchiver written to the file path. Returns nil if there is no file at path.
 */
+ (id)unarchiveWithFile:(NSString *)path forClass:(Class)cls;

@end
