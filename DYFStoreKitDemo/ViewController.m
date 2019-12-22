//
//  ViewController.m
//
//  Created by dyf on 2014/11/4.
//  Copyright © 2014 dyf. All rights reserved.
//

#import "ViewController.h"
#import "DYFStore.h"
#import "DYFStoreProduct.h"
#import "DYFStoreViewController.h"
#import "UIView+DYFAdd.h"
#import "NSObject+DYFAdd.h"
#import "DYFStoreUserDefaultsPersistence.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *availableProducts;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"In-app Purchase", @"");
    [self initializeAndConfigure];
}

- (void)initializeAndConfigure {
    self.availableProducts = [NSMutableArray array];
    self.fetchProductsButton.setCorner(UIRectCornerAllCorners, 20.f);
    self.presentStoreUIButton.setCorner(UIRectCornerAllCorners, 20.f);
    
    DYFStoreUserDefaultsPersistence *uPersister = [[DYFStoreUserDefaultsPersistence alloc] init];
    [uPersister removeTransactions];
}

- (NSArray *)fetchProductIdentifiersFromServer {
    
    NSArray *productIds = @[@"com.hncs.szj.coin48",   // 42 gold coins for ￥6.
                            @"com.hncs.szj.coin210",  // 210 gold coins for ￥30.
                            @"com.hncs.szj.coin686",  // 686 gold coins for ￥98.
                            @"com.hncs.szj.coin1386", // 1386 gold coins for ￥198.
                            @"com.hncs.szj.coin2086", // 2086 gold coins for ￥298.
                            @"com.hncs.szj.coin4886", // 4886 gold coins for ￥698.
                            @"com.hncs.szj.vip1",     // non-renewable vip subscription for a month.
                            @"com.hncs.szj.vip2"      // Auto-renewable vip subscription for three months.
                            ];
    
    return productIds;
}

- (IBAction)fetchProductsFromAppStore:(id)sender {
    
    [self showLoading:@"Loading..."];
    NSArray *productIds = [self fetchProductIdentifiersFromServer];
    
    [DYFStore.defaultStore requestProductWithIdentifiers:productIds success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        [self hideLoading];
        
        for (SKProduct *product in products) {
            
            if (![self hasProduct:product.productIdentifier]) {
                DYFStoreProduct *p = [[DYFStoreProduct alloc] init];
                p.identifier = product.productIdentifier;
                p.name = product.localizedTitle;
                p.price = [product.price stringValue];
                p.localePrice = [DYFStore.defaultStore localizedPriceOfProduct:product];
                p.localizedDescription = product.localizedDescription;
                
                [self.availableProducts addObject:p];
            }
        }
        
        NSLog(@"invalidIdentifiers: %@", invalidIdentifiers);
        
    } failure:^(NSError *error) {
        
        [self hideLoading];
        [self sendNotice:[NSString stringWithFormat:@"%zi, %@", error.code, error.localizedDescription]];
        
    }];
}

- (IBAction)presentStoreUI:(id)sender {
    
    if (![DYFStore canMakePayments]) {
        [self showTipsMessage:@"Your device is not able or allowed to make payments!"];
        return;
    }
    
    NSMutableArray *products = self.availableProducts;
    [self presentStoreUIWithProducts:products];
}

- (void)presentStoreUIWithProducts:(NSMutableArray *)products {
    
    //    if (products.count == 0) {
    //                [self showTipsMessage:@"There are no products for sale!"];
    //        return;
    //    }
    //
    
    DYFStoreProduct *p = [[DYFStoreProduct alloc] init];
    p.identifier = @"com.hncs.szj.coin48";
    p.name = @"42 gold coins";
    p.price = @"6.00";
    p.localePrice = @"￥6.00";
    p.localizedDescription = @"42 gold coins for ￥6";
    [self.availableProducts addObject:p];
    
    DYFStoreProduct *p1 = [[DYFStoreProduct alloc] init];
    p1.identifier = @"com.hncs.szj.coin210";
    p1.name = @"210 gold coins";
    p1.price = @"30.00";
    p1.localePrice = @"￥30.00";
    p1.localizedDescription = @"210 gold coins for ￥30";
    [self.availableProducts addObject:p1];
    
    DYFStoreProduct *p2 = [[DYFStoreProduct alloc] init];
    p2.identifier = @"com.hncs.szj.coin686";
    p2.name = @"686 gold coins";
    p2.price = @"98.00";
    p2.localePrice = @"￥98.00";
    p2.localizedDescription = @"686 gold coins for ￥98";
    [self.availableProducts addObject:p2];
    
    DYFStoreProduct *p3 = [[DYFStoreProduct alloc] init];
    p3.identifier = @"com.hncs.szj.coin4886";
    p3.name = @"4886 gold coins";
    p3.price = @"698.00";
    p3.localePrice = @"￥698.00";
    p3.localizedDescription = @"4886 gold coins for ￥698";
    [self.availableProducts addObject:p3];
    
    DYFStoreProduct *p5 = [[DYFStoreProduct alloc] init];
    p5.identifier = @"com.hncs.szj.vip2";
    p5.name = @"VIP2";
    p5.price = @"298.00";
    p5.localePrice = @"￥298.00";
    p5.localizedDescription = @"Auto-renewable vip subscription for three months";
    [self.availableProducts addObject:p5];
    
    DYFStoreViewController *svc = [[DYFStoreViewController alloc] init];
    svc.dataArray = products;
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)sendNotice:(NSString *)message {
    [self showAlertWithTitle:NSLocalizedStringFromTable(@"Notification", nil, @"")
                     message:message
           cancelButtonTitle:nil
                      cancel:NULL
          confirmButtonTitle:NSLocalizedStringFromTable(@"I see!", nil, @"")
                     execute:^(UIAlertAction *action) {
                         NSLog(@"action.title: %@", action.title);
                     }];
}

- (BOOL)hasProduct:(NSString *)productIdentifier {
    
    for (SKProduct *product in self.availableProducts) {
        NSString *id = product.productIdentifier;
        if ([id isEqualToString:productIdentifier]) {
            return YES;
        }
    }
    
    return NO;
}

@end
