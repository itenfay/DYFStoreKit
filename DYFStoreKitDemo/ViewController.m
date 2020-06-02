//
//  ViewController.m
//
//  Created by dyf on 2014/11/4.
//  Copyright © 2014 dyf. ( https://github.com/dgynfi/DYFStoreKit )
//

#import "ViewController.h"
#import "DYFStoreManager.h"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray *productArrayToDisplay;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"In-app Purchase", @"");
    [self configure];
}

- (void)configure {
    self.productArrayToDisplay = [NSMutableArray array];
    
    self.buyAProductButton.setCorner   (UIRectCornerAllCorners, 20.f);
    self.fetchProductsButton.setCorner (UIRectCornerAllCorners, 20.f);
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

/// Mode 1:
///  - Step 1: Requests localized information about a product identifier from the Apple App Store.
///  - Step 2: Adds payment of the product with the given product identifier.
- (IBAction)buyASingleProductAndPay:(id)sender {
    [self showLoading:@"Loading..."];
    
    NSString *productID = @"com.hncs.szj.coin48";
    
    [DYFStore.defaultStore requestProductWithIdentifier:productID success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        [self hideLoading];
        
        if (products.count == 1) {
            
            NSString *productID = ((SKProduct *)products[0]).productIdentifier;
            [self addPayment:productID];
            
        } else {
            
            [self showTipsMessage:@"There is no this product for sale!"];
        }
        
#if DEBUG
        NSLog(@"%s invalidIdentifiers: %@", __FUNCTION__, invalidIdentifiers);
#endif
    } failure:^(NSError *error) {
        
        [self hideLoading];
        [self sendNotice:[NSString stringWithFormat:@"%zi, %@", error.code, error.localizedDescription]];
    }];
}

- (void)addPayment:(NSString *)productID {
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
#if DEBUG
    NSLog(@"%s userIdentifier: %@", __FUNCTION__, userIdentifier);
#endif
    
    [DYFStoreManager.shared addPayment:productID userIdentifier:userIdentifier];
}

/// Mode 2:
///  - Step 1: Requests localized information about a set of products from the Apple App Store.
///  - Step 2: After obtaining the localized product list, then display the purchase product panel at the right time.
///  - Step 3: Adds payment of the product with the given product identifier.
- (IBAction)fetchProductsFromAppStore:(id)sender {
    [self showLoading:@"Loading..."];
    
    NSArray *productIds = [self fetchProductIdentifiersFromServer];
    
    [DYFStore.defaultStore requestProductWithIdentifiers:productIds success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        [self hideLoading];
        
        if (products.count > 0) {
            [self getData:products];
        } else if (products.count == 0 && invalidIdentifiers.count > 0) {
#if DEBUG
            NSLog(@"%s Please check the product information you set up.", __FUNCTION__);
#endif
        }
        
#if DEBUG
        NSLog(@"%s invalidIdentifiers: %@", __FUNCTION__, invalidIdentifiers);
#endif
    } failure:^(NSError *error) {
        
        [self hideLoading];
        [self sendNotice:[NSString stringWithFormat:@"%zi, %@", error.code, error.localizedDescription]];
    }];
}

- (void)getData:(NSArray *)products {
    for (SKProduct *product in products) {
        
        if (![self hasProduct:product.productIdentifier]) {
            DYFStoreProduct *p = [[DYFStoreProduct alloc] init];
            p.identifier = product.productIdentifier;
            p.name = product.localizedTitle;
            p.price = [product.price stringValue];
            p.localePrice = [DYFStore.defaultStore localizedPriceOfProduct:product];
            p.localizedDescription = product.localizedDescription;
            
            [self.productArrayToDisplay addObject:p];
        }
    }
}

- (IBAction)presentStoreUI:(id)sender {
    if (![DYFStore canMakePayments]) {
        [self showTipsMessage:@"Your device is not able or allowed to make payments!"];
        return;
    }
    
    NSMutableArray *products = self.productArrayToDisplay;
    [self presentStoreUIWithProducts:products];
}

- (void)presentStoreUIWithProducts:(NSMutableArray *)products {
    if (products.count == 0) {
        [self showTipsMessage:@"There are no products for sale!"];
        return;
    }
    
    DYFStoreViewController *storeVC = [[DYFStoreViewController alloc] init];
    storeVC.dataArray = products;
    [self.navigationController pushViewController:storeVC animated:YES];
}

- (void)sendNotice:(NSString *)message {
    [self showAlertWithTitle:NSLocalizedStringFromTable(@"Notification", nil, @"")
                     message:message
           cancelButtonTitle:nil
                      cancel:NULL
          confirmButtonTitle:NSLocalizedStringFromTable(@"I see!", nil, @"")
                     execute:^(UIAlertAction *action) {
#if DEBUG
        NSLog(@"Alert action title: %@", action.title);
#endif
    }];
}

- (BOOL)hasProduct:(NSString *)productIdentifier {
    
    for (SKProduct *product in self.productArrayToDisplay) {
        NSString *id = product.productIdentifier;
        if ([id isEqualToString:productIdentifier]) {
            return YES;
        }
    }
    
    return NO;
}

@end
