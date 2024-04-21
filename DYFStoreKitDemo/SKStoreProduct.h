//
//  SKStoreProduct.h
//
//  Created by Teng Fei on 2014/11/4.
//  Copyright © 2014 Teng Fei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SKStoreProduct : NSObject

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
