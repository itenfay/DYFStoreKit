//
//  DYFKeychain.h
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
#import <Security/Security.h>

/** Used to represent accessible access options.
 */
typedef NS_ENUM(NSUInteger, DYFKeychainAccessOptions) {
    /**
     The data in the keychain item can be accessed only while the device is unlocked by the user.
     
     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute migrate to a new device when using encrypted backups.
     This is the default value for keychain items added without explicitly setting an accessibility constant.
     */
    DYFKeychainAccessOptionsAccessibleWhenUnlocked,
    /**
     The data in the keychain item can be accessed only while the device is unlocked by the user.
     
     This is recommended for items that need to be accessible only while the application is in the foreground. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     */
    DYFKeychainAccessOptionsAccessibleWhenUnlockedThisDeviceOnly,
    
    /**
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
     
     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute migrate to a new device when using encrypted backups.
     */
    DYFKeychainAccessOptionsAccessibleAfterFirstUnlock,
    /**
     The data in the keychain item cannot be accessed after a restart until the device has been unlocked once by the user.
     
     After the first unlock, the data remains accessible until the next restart. This is recommended for items that need to be accessed by background applications. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     */
    DYFKeychainAccessOptionsAccessibleAfterFirstUnlockThisDeviceOnly,
    
    /**
     The data in the keychain can only be accessed when the device is unlocked. Only available if a passcode is set on the device.
     
     This is recommended for items that only need to be accessible while the application is in the foreground. Items with this attribute never migrate to a new device. After a backup is restored to a new device, these items are missing. No items can be stored in this class on devices without a passcode. Disabling the device passcode causes all items in this class to be deleted.
     */
    DYFKeychainAccessOptionsAcessibleWhenPasscodeSetThisDeviceOnly,
    
    /**
     The data in the keychain item can always be accessed regardless of whether the device is locked.
     
     This is not recommended for application use. Items with this attribute migrate to a new device when using encrypted backups.
     */
    DYFKeychainAccessOptionsAccessibleAlways,
    /**
     The data in the keychain item can always be accessed regardless of whether the device is locked.
     
     This is not recommended for application use. Items with this attribute do not migrate to a new device. Thus, after restoring from a backup of a different device, these items will not be present.
     */
    DYFKeychainAccessOptionsAccessibleAlwaysThisDeviceOnly
};

@interface DYFKeychain : NSObject

/** Specifies an access group which is used to share keychain items between applications.
 */
@property (nonatomic, copy) NSString *accessGroup;

/** Specifies whether the item is synchronized to other devices through iCloud.
 */
@property (nonatomic, assign) BOOL synchronizable;

/** The identifierfor for kSecAttrService.
 */
@property (nonatomic, copy) NSString *serviceIdentifier;

/** Records the query parameters of the last operation.
 */
@property (nonatomic, strong) NSMutableDictionary *queryDictionary;

/** Records the status of the last operation result.
 */
@property (nonatomic, assign) OSStatus osStatus;

/**
 Creates an instance of DYFKeychain with the class method.
 
 @return An instance of DYFKeychain.
 */
+ (DYFKeychain *)createKeychain;

/**
 Instantiates a DYFKeychain object.
 
 @param serviceIdentifier The identifier for service.
 @return A DYFKeychain object.
 */
- (instancetype)initWithServiceIdentifier:(NSString *)serviceIdentifier;

/**
 The default value is DYFKeychainAccessOptionsAccessibleWhenUnlocked
 
 @return A DYFKeychainAccessOptions value that is DYFKeychainAccessOptionsAccessibleWhenUnlocked.
 */
- (DYFKeychainAccessOptions)defaultOptions;

/**
 Stores or updates the text value in the keychain item by the given key.
 
 @param value The text value to be written to the keychain.
 @param key The key which the text is stored in the keychain.
 @return True if the text was successfully written to the keychain, false otherwise.
 */
- (BOOL)add:(NSString *)value forKey:(NSString *)key;

/**
 Stores or updates the text value in the keychain item by the given key.
 
 @param value The text value to be written to the keychain.
 @param key The key which the text is stored in the keychain.
 @param options The options indicates when you app needs access to the text in the keychain. By the default DYFKeychainAccessOptionsAccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
 @return True if the text was successfully written to the keychain, false otherwise.
 */
- (BOOL)add:(NSString *)value forKey:(NSString *)key options:(DYFKeychainAccessOptions)options;

/**
 Stores or updates the data in the keychain item by the given key.
 
 @param value The data to be written to the keychain.
 @param key The key which the data is stored in the keychain.
 @return True if the data was successfully written to the keychain, false otherwise.
 */
- (BOOL)addData:(NSData *)value forKey:(NSString *)key;

/**
 Stores or updates the data in the keychain item by the given key.
 
 @param value The data to be written to the keychain.
 @param key The key which the data is stored in the keychain.
 @param options The options indicates when you app needs access to the text in the keychain. By the default DYFKeychainAccessOptionsAccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
 @return True if the data was successfully written to the keychain, false otherwise.
 */
- (BOOL)addData:(NSData *)value forKey:(NSString *)key options:(DYFKeychainAccessOptions)options;

/**
 Stores or updates the boolean value in the keychain item by the given key.
 
 @param value The boolean value to be written to the keychain.
 @param key The key which the boolean value is stored in the keychain.
 @return True if the boolean value was successfully written to the keychain, false otherwise.
 */
- (BOOL)addBool:(BOOL)value forKey:(NSString *)key;

/**
 Stores or updates the boolean value in the keychain item by the given key.
 
 @param value The boolean value to be written to the keychain.
 @param key The key which the boolean value is stored in the keychain.
 @param options The options indicates when you app needs access to the text in the keychain. By the default DYFKeychainAccessOptionsAccessibleWhenUnlocked option is used that permits the data to be accessed only while the device is unlocked by the user.
 @return True if the boolean value was successfully written to the keychain, false otherwise.
 */
- (BOOL)addBool:(BOOL)value forKey:(NSString *)key options:(DYFKeychainAccessOptions)options;

/**
 Retrieves the text value from the keychain by the given key.
 
 @param key The key that is used to read the keychain item.
 @return The text value from the keychain. Nil if unable to read the item.
 */
- (NSString *)get:(NSString *)key;

/**
 Retrieves the data from the keychain by the given key.
 
 @param key The key that is used to read the keychain item.
 @return The data from the keychain. Nil if unable to read the item.
 */
- (NSData *)getData:(NSString *)key;

/**
 Retrieves the data from the keychain by the given key.
 
 @param key The key that is used to read the keychain item.
 @param asReference If true, returns the data as reference (needed for things like NEVPNProtocol).
 @return The data from the keychain. Nil if unable to read the item.
 */
- (NSData *)getData:(NSString *)key asReference:(BOOL)asReference;

/**
 Retrieves the boolean value from the keychain by the given key.
 
 @param key The key that is used to read the keychain item.
 @return The boolean value from the keychain. False if unable to read the item.
 */
- (BOOL)getBool:(NSString *)key;

/**
 Deletes the single keychain item by the specified key.
 
 @param key The key which is used to delete the keychain item.
 @return True if the item was successfully deleted, false otherwise.
 */
- (BOOL)delete:(NSString *)key;

/**
 Deletes all keychain items used by the app. Note that this method deletes all items regardless of those used keys.
 
 @return True if all keychain items was successfully deleted, false otherwise.
 */
- (BOOL)clear;

@end

@interface DYFKeychainConstants : NSObject

/** Specifies an access group which is used to share keychain items between apps.
 */
+ (NSString *)accessGroup;

/** The value indicates when your app needs access to the data in a keychain item.
 */
+ (NSString *)accessible;

/** The value indicates whether the item is synchronized to other devices through iCloud. Indicates whether the item in question is synchronized to other devices through iCloud. To add a new synchronizable item, or to obtain synchronizable results from a query, supply this key with a value of kCFBooleanTrue. If the key is not supplied, or has a value of kCFBooleanFalse, then no synchronizable items are added or returned. Use kSecAttrSynchronizableAny to query for both synchronizable and non-synchronizable results.
 */
+ (NSString *)synchronizable;

/** A value is a string indicating the item's account name.
 */
+ (NSString *)account;

/** A key whose value is a string indicating the item's service. Represents the service associated with this item. Items of class kSecClassGenericPassword have this attribute.
 */
+ (NSString *)service;

/** A value is the item's class.
 */
+ (NSString *)kClass;

/** A value indicates the match limit.
 */
+ (NSString *)matchLimit;

/** A value is the item's data.
 */
+ (NSString *)valueData;

/** A value is a Boolean indicating whether or not to return item data.
 */
+ (NSString *)returnData;

/** A value is a Boolean indicating whether or not to return a persistent reference to an item.
 */
+ (NSString *)returnReference;

@end
