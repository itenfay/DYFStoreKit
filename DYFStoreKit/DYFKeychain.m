//
//  DYFKeychain.m
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

#import "DYFKeychain.h"

@interface DYFKeychain ()

/** The lock prevents the code to be run simultaneously from multiple threads which may result in crashing.
 */
@property (nonatomic, strong) NSLock *lock;

@end

@implementation DYFKeychain

+ (DYFKeychain *)createKeychain {
    return [[self.class alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        self.osStatus = errSecSuccess;
    }
    return self;
}

- (instancetype)initWithServiceIdentifier:(NSString *)serviceIdentifier {
    self = [super init];
    if (self) {
        self.lock = [[NSLock alloc] init];
        self.serviceIdentifier = serviceIdentifier;
        self.osStatus = errSecSuccess;
    }
    return self;
}

/**
 Returns a keychain that copies the current DYFKeychain instance.
 
 @return A DYFKeychain object.
 */
- (id)copy {
    DYFKeychain *keychain = [self.class createKeychain];
    keychain.accessGroup       = self.accessGroup;
    keychain.synchronizable    = self.synchronizable;
    keychain.serviceIdentifier = self.serviceIdentifier;
    keychain.queryDictionary   = self.queryDictionary;
    keychain.osStatus          = self.osStatus;
    
    return keychain;
}

- (DYFKeychainAccessOptions)defaultOptions {
    return DYFKeychainAccessOptionsAccessibleWhenUnlocked;
}

- (BOOL)add:(NSString *)value forKey:(NSString *)key {
    return [self add:value forKey:key options:self.defaultOptions];
}

- (BOOL)add:(NSString *)value forKey:(NSString *)key options:(DYFKeychainAccessOptions)options {
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    return [self addData:data forKey:key options:options];
}

- (BOOL)addData:(NSData *)value forKey:(NSString *)key {
    return [self addData:value forKey:key options:self.defaultOptions];
}

- (BOOL)addData:(NSData *)value forKey:(NSString *)key options:(DYFKeychainAccessOptions)options {
    
    // The lock prevents the code to be run simultaneously from multiple threads which may result in crashing.
    [self.lock lock];
    
    NSString *accessible = [self stringWithOptions:options];
    
    NSMutableDictionary *query = [self supplyQueryDictionary:YES];
    query[DYFKeychainConstants.account] = key;
    query[DYFKeychainConstants.accessible] = accessible;
    self.queryDictionary = query;
    
    CFTypeRef ignore = nil;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &ignore);
    if (status != errSecSuccess) {
        
        if (value) {
            query[DYFKeychainConstants.valueData] = value;
            self.queryDictionary[DYFKeychainConstants.valueData] = value;
            self.osStatus = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
        } else {
            self.osStatus = errSecInvalidPointer; // -67675, An invalid pointer was encountered.
        }
        
        return self.osStatus == errSecSuccess;
    }
    
    if (!value) {
        [self deleteWithoutLock:key];
        self.osStatus = errSecInvalidPointer; // -67675, An invalid pointer was encountered.
    } else {
        NSMutableDictionary *updatedDictionary = [NSMutableDictionary dictionary];
        updatedDictionary[DYFKeychainConstants.valueData] = value;
        
        self.osStatus = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updatedDictionary);
    }
    
    [self.lock unlock];
    
    return self.osStatus == errSecSuccess;
}

- (BOOL)addBool:(BOOL)value forKey:(NSString *)key {
    return [self addBool:value forKey:key options:self.defaultOptions];
}

- (BOOL)addBool:(BOOL)value forKey:(NSString *)key options:(DYFKeychainAccessOptions)options {
    NSString *v = value ? @"1" : @"0";
    NSData *data = [v dataUsingEncoding:NSUTF8StringEncoding];
    
    return [self addData:data forKey:key options:options];
}

- (NSString *)get:(NSString *)key {
    
    NSData *data = [self getData:key];
    if (!data) { return nil; }
    
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!s) {
        self.osStatus = errSecInvalidEncoding; // -67853, the encoding was not valid.
        return nil;
    }
    
    return s;
}

- (NSData *)getData:(NSString *)key {
    return [self getData:key asReference:NO];
}

- (NSData *)getData:(NSString *)key asReference:(BOOL)asReference {
    
    [self.lock lock];
    
    NSMutableDictionary *query = [self supplyQueryDictionary:NO];
    query[DYFKeychainConstants.account] = key;
    query[DYFKeychainConstants.matchLimit] = (__bridge id)kSecMatchLimitOne;
    
    if (asReference) {
        query[DYFKeychainConstants.returnReference] = (__bridge id)kCFBooleanTrue;
    } else {
        query[DYFKeychainConstants.returnData] = (__bridge id)kCFBooleanTrue;
    }
    self.queryDictionary = query;
    
    CFDataRef result = nil;
    self.osStatus = SecItemCopyMatching((__bridge CFDictionaryRef)query, (CFTypeRef *)&result);
    
    [self.lock unlock];
    
    if (self.osStatus == errSecSuccess) {
        return (__bridge NSData *)result;
    }
    
    return nil;
}

- (BOOL)getBool:(NSString *)key {
    
    NSData *data = [self getData:key];
    if (!data) { return NO; }
    
    NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [s boolValue];
}

- (BOOL)delete:(NSString *)key {
    
    [self.lock lock];
    BOOL ret = [self deleteWithoutLock:key];
    [self.lock unlock];
    
    return ret;
}

/**
 Same as `delete`, but it is not thread safe.
 
 @param key The key which is used to delete the keychain item.
 @return True if the item was successfully deleted, false otherwise.
 */
- (BOOL)deleteWithoutLock:(NSString *)key {
    
    NSMutableDictionary *query = [self supplyQueryDictionary:NO];
    query[DYFKeychainConstants.account] = key;
    self.queryDictionary = query;
    
    self.osStatus = SecItemDelete((__bridge CFDictionaryRef)query);
    
    return self.osStatus == errSecSuccess;
}

- (BOOL)clear {
    
    [self.lock lock];
    
    NSMutableDictionary *query = [self supplyQueryDictionary:NO];
    self.queryDictionary = query;
    
    self.osStatus = SecItemDelete((__bridge CFDictionaryRef)query);
    
    [self.lock unlock];
    
    return self.osStatus == errSecSuccess; // 0, no error.
}

/**
 Supplies a query dictionary to modify the keychain item.
 
 @param shouldAddItem Use `true` when the dictionary will be used with `SecItemAdd` or `SecItemUpadte` method. For getting and deleting items, use `false`
 @return A query dictionary to modify the keychain item.
 */
- (NSMutableDictionary *)supplyQueryDictionary:(BOOL)shouldAddItem {
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    query[DYFKeychainConstants.kClass] = (__bridge id)kSecClassGenericPassword;
    
    if (self.accessGroup && self.accessGroup.length > 0) {
        query[DYFKeychainConstants.accessGroup] = self.accessGroup;
    }
    
    if (self.synchronizable) {
        NSString *key = DYFKeychainConstants.synchronizable;
        query[key] = shouldAddItem ? (__bridge id)kCFBooleanTrue : (__bridge id)kSecAttrSynchronizableAny;
    }
    
    if (self.serviceIdentifier && self.serviceIdentifier.length > 0) {
        query[DYFKeychainConstants.service] = self.serviceIdentifier;
    }
    
    return query;
}

/** Converts a corresponding enumeration value to a string.
 */
- (NSString *)stringWithOptions:(DYFKeychainAccessOptions)opts {
    
    NSString *options = @"";
    
    switch (opts) {
        case DYFKeychainAccessOptionsAccessibleWhenUnlocked:
            options = (__bridge NSString *)kSecAttrAccessibleWhenUnlocked;
            break;
        case DYFKeychainAccessOptionsAccessibleWhenUnlockedThisDeviceOnly:
            options = (__bridge NSString *)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
            break;
        case DYFKeychainAccessOptionsAccessibleAfterFirstUnlock:
            options = (__bridge NSString *)kSecAttrAccessibleAfterFirstUnlock;
            break;
        case DYFKeychainAccessOptionsAccessibleAfterFirstUnlockThisDeviceOnly:
            options = (__bridge NSString *)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            break;
        case DYFKeychainAccessOptionsAcessibleWhenPasscodeSetThisDeviceOnly:
            options = (__bridge NSString *)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
            break;
        case DYFKeychainAccessOptionsAccessibleAlways:
            options = (__bridge NSString *)kSecAttrAccessibleAlways;
            break;
        case DYFKeychainAccessOptionsAccessibleAlwaysThisDeviceOnly:
            options = (__bridge NSString *)kSecAttrAccessibleAlwaysThisDeviceOnly;
            break;
        default:
            options = (__bridge NSString *)kSecAttrAccessibleWhenUnlocked;
            break;
    }
    
    return options;
}

@end

@implementation DYFKeychainConstants

+ (NSString *)accessGroup {
    return [self toString:kSecAttrAccessGroup];
}

+ (NSString *)accessible {
    return [self toString:kSecAttrAccessible];
}

+ (NSString *)synchronizable {
    return [self toString:kSecAttrSynchronizable];
}

+ (NSString *)account {
    return [self toString:kSecAttrAccount];
}

+ (NSString *)service {
    return [self toString:kSecAttrService];
}

+ (NSString *)kClass {
    return [self toString:kSecClass];
}

+ (NSString *)matchLimit {
    return [self toString:kSecMatchLimit];
}

+ (NSString *)valueData {
    return [self toString:kSecValueData];
}

+ (NSString *)returnData {
    return [self toString:kSecReturnData];
}

+ (NSString *)returnReference {
    return [self toString:kSecReturnPersistentRef];
}

/**
 Converts a CFString object to a string.
 
 @param value A reference to a CFString object.
 @return A string.
 */
+ (NSString *)toString:(CFStringRef)value {
    return (__bridge NSString *)(value);
}

@end
