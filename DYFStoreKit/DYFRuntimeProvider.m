//
//  DYFRuntimeProvider.m
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

#import "DYFRuntimeProvider.h"
#import <objc/runtime.h>
#import <objc/message.h>

/** Returns a string containing the bytes in a given C array, interpreted according to a given encoding.
 
 @param cString A C array of bytes. The array must end with a NULL byte.
 @return A string containing the characters described in cString.
 */
static NSString *RTPString(const char *cString) {
    if (cString) {
        return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    }
    return nil;
}

/** An object you want to archive or unarchive.
 */
static id _rtpObject = nil;

/** The class you want to inspect.
 */
static Class _rtpClass = nil;

@implementation DYFRuntimeProvider

+ (NSArray *)methodListWithClass:(Class)cls {
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:0];
    
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(cls, &count);
    
    for (int i = 0; i < count; i++) {
        SEL sel = method_getName(methodList[i]);
        NSString *selName = RTPString(sel_getName(sel));
        [names addObject:selName];
    }
    
    free(methodList);
    
    return names.copy;
}

+ (NSArray *)classMethodList:(id)obj {
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:0];
    
    unsigned int count = 0;
    Method *methodList = class_copyMethodList(object_getClass(obj), &count);
    
    for (int i = 0; i < count; i++) {
        SEL sel = method_getName(methodList[i]);
        NSString *selName = RTPString(sel_getName(sel));
        [names addObject:selName];
    }
    
    free(methodList);
    
    return names.copy;
}

+ (NSArray *)ivarListWithClass:(Class)cls {
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:0];
    
    unsigned int count = 0;
    Ivar *ivarList = class_copyIvarList(cls, &count);
    
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivarList[i];
        NSString *ivarName = RTPString(ivar_getName(ivar));
        if (ivarName) {
            [names addObject:ivarName];
        }
    }
    
    free(ivarList);
    
    return names.copy;
}

+ (BOOL)addMethodWithClass:(Class)cls selector:(SEL)sel impClass:(Class)impCls impSelector:(SEL)impSel {
    
    Method m = class_getInstanceMethod(impCls, impSel);
    const char *types = method_getTypeEncoding(m);
    
    return [self addMethodWithClass:cls selector:sel impClass:impCls impSelector:impSel types:RTPString(types)];
}

+ (BOOL)addMethodWithClass:(Class)cls selector:(SEL)sel impClass:(Class)impCls impSelector:(SEL)impSel types:(NSString *)types {
    
    IMP imp = class_getMethodImplementation(impCls, impSel);
    return class_addMethod(cls, sel, imp, [types UTF8String]);
}

+ (void)exchangeMethodWithClass:(Class)cls selector:(SEL)sel targetClass:(Class)targetCls targetSelector:(SEL)targetSel {
    
    Method m1 = class_getInstanceMethod(cls, sel);
    Method m2 = class_getInstanceMethod(targetCls, targetSel);
    
    method_exchangeImplementations(m1, m2);
}

+ (void)replaceMethodWithClass:(Class)cls selector:(SEL)sel targetClass:(Class)targetCls targetSelector:(SEL)targetSel {
    
    Method m = class_getInstanceMethod(targetCls, targetSel);
    IMP imp = method_getImplementation(m);
    const char *types = method_getTypeEncoding(m);
    
    class_replaceMethod(cls, sel, imp, types);
}

+ (NSArray *)propertyListWithClass:(Class)cls {
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:0];
    
    unsigned int count = 0;
    objc_property_t *propertyList = class_copyPropertyList(cls, &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertyList[i];
        NSString *propertyName = RTPString(property_getName(property));
        [names addObject:propertyName];
    }
    
    free(propertyList);
    
    return names.copy;
}

+ (id)modelWithDictionary:(NSDictionary *)dictionary forClass:(Class)cls {
    id model = [[cls alloc] init];
    
    NSArray *properties = [self propertyListWithClass:cls];
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([properties containsObject:key]) {
            [model setValue:obj forKey:key];
        }
    }];
    
    return model;
}

+ (NSDictionary *)dictionaryWithModel:(id)model {
    NSArray *properties = [self propertyListWithClass:object_getClass(model)];
    
    if (properties.count > 0) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:0];
        
        for (NSString *key in properties) {
            id value = [model valueForKey: key];
            dict[key] = value ?: [NSNull null];
        }
        
        return dict.copy;
    }
    
    return nil;
}

+ (void)encode:(NSCoder *)encoder forObject:(NSObject *)obj {
    
    NSArray *ivarNames = [self ivarListWithClass:obj.classForCoder];

    for (NSString *key in ivarNames) {
        id value = [obj valueForKey:key];
        [encoder encodeObject:value forKey:key];
    }
}

+ (void)decode:(NSCoder *)decoder forObject:(NSObject *)obj {
    
    NSArray *ivarNames = [self ivarListWithClass:obj.classForCoder];

    for (NSString *key in ivarNames) {
        id value = [decoder decodeObjectForKey:key];
        [obj setValue:value forKey:key];
    }
}

+ (BOOL)archiveWithObject:(id)object forClass:(Class)cls toFile:(NSString *)path {
    
    [[self alloc] archiveOrUnarchiveWithObject:object forClass:cls];
    
    if (!object) { return NO; }
    
    if (@available(iOS 11.0, *)) {
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initRequiringSecureCoding:YES];
        [archiver encodeObject:object];
        NSData *data = archiver.encodedData; //[archiver finishEncoding] and return the data.
        
        return [data writeToFile:path atomically:YES];
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:object];
    return [data writeToFile:path atomically:YES];
}

+ (id)unarchiveWithFile:(NSString *)path forClass:(Class)cls {
    
    [[self alloc] archiveOrUnarchiveWithObject:nil forClass:cls];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) { return nil; }
    
    if (@available(iOS 11.0, *)) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingFromData:data error:nil];
        id object = [unarchiver decodeObject];
        [unarchiver finishDecoding];
        
        return object;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

- (void)archiveOrUnarchiveWithObject:(id)obj forClass:(Class)cls {
    _rtpObject = obj;
    _rtpClass  = cls;
    
    [DYFRuntimeProvider replaceMethodWithClass:_rtpClass
                                      selector:@selector(initWithCoder:)
                                   targetClass:self.class
                                targetSelector:@selector(initWithCoder:)];
    
    [DYFRuntimeProvider replaceMethodWithClass:_rtpClass
                                      selector:@selector(encodeWithCoder:)
                                   targetClass:self.class
                                targetSelector:@selector(encodeWithCoder:)];
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    _rtpObject = [super init];
    
    if (_rtpObject) {
        NSArray *ivarNames = [DYFRuntimeProvider ivarListWithClass:_rtpClass];
        
        for (NSString *key in ivarNames) {
            id value = [decoder decodeObjectForKey:key];
            [_rtpObject setValue:value forKey:key];
        }
    }
    
    return _rtpObject;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    NSArray *ivarNames = [DYFRuntimeProvider ivarListWithClass:_rtpClass];
    
    for (NSString *key in ivarNames) {
        id value = [_rtpObject valueForKey:key];
        [encoder encodeObject:value forKey:key];
    }
}

@end
