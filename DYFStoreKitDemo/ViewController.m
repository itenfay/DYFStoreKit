//
//  ViewController.m
//
//  Created by dyf on 2014/11/4.
//  Copyright © 2014 dyf. All rights reserved.
//

#import "ViewController.h"
#import "DYFStoreManager.h"

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
    
    if (products.count == 0) {
        [self showTipsMessage:@"There are no products for sale!"];
        return;
    }
    
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
                         NSLog(@"Alert action title: %@", action.title);
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
