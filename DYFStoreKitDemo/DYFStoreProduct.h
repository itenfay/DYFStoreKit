//
//  DYFStoreProduct.h
//
//  Created by dyf on 2014/11/4. ( https://github.com/dgynfi/DYFStoreKit )
//  Copyright © 2014 dyf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DYFStoreProduct : NSObject

/** The string that identifies the product.
 */
@property (nonatomic, copy) NSString *identifier;

/** The name of the product.
 */
@property (nonatomic, copy) NSString *name;

/** The cost of the product in the local currency.
 */
@property (nonatomic, copy) NSString *price;

/** The locale price of the product.
 */
@property (nonatomic, copy) NSString *localePrice;

/** A description of the product.
 */
@property (nonatomic, copy) NSString *localizedDescription;

@end
