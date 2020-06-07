//
//  ViewController.m
//
//  Created by dyf on 2014/11/4. ( https://github.com/dgynfi/DYFStoreKit )
//  Copyright © 2014 dyf. All rights reserved.
//

#import "ViewController.h"
#import "DYFStoreManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"In-app Purchase", @"");
    [self configure];
}

- (void)configure {
    self.fetchesProductAndSubmitsPaymentButton.setCorner(UIRectCornerAllCorners, 20.f);
    self.fetchesProductsAndDisplaysStoreUIButton.setCorner(UIRectCornerAllCorners, 20.f);
}

/// Strategy 1:
///  - Step 1: Requests localized information about a product from the Apple App Store.
///  - Step 2: Adds payment of the product with the given product identifier.
- (IBAction)fetchesProductAndSubmitsPayment:(id)sender {
    [self showLoading:@"Loading..."];
    
    NSString *productId = @"com.hncs.szj.coin48";
    
    [DYFStore.defaultStore requestProductWithIdentifier:productId success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        [self hideLoading];
        
        if (products.count == 1) {
            
            NSString *productId = ((SKProduct *)products[0]).productIdentifier;
            [self addPayment:productId];
            
        } else {
            
            [self showTipsMessage:@"There is no this product for sale!"];
        }
        
    } failure:^(NSError *error) {
        
        [self hideLoading];
        
        NSString *value = error.userInfo[NSLocalizedDescriptionKey];
        NSString *msg = value ?: error.localizedDescription;
        [self sendNotice:[NSString stringWithFormat:@"An error occurs, %zi, %@", error.code, msg]];
    }];
}

- (void)addPayment:(NSString *)productId {
    
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    
    [DYFStoreManager.shared addPayment:productId userIdentifier:userIdentifier];
}

- (NSArray *)fetchProductIdentifiersFromServer {
    
    NSArray *productIds = @[@"com.hncs.szj.coin42",   // 42 gold coins for ￥6.
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

/// Strategy 2:
///  - Step 1: Requests localized information about a set of products from the Apple App Store.
///  - Step 2: After retrieving the localized product list, then display store UI.
///  - Step 3: Adds payment of the product with the given product identifier.
- (IBAction)fetchesProductsFromAppStore:(id)sender {
    [self showLoading:@"Loading..."];
    
    NSArray *productIds = [self fetchProductIdentifiersFromServer];
    
    [DYFStore.defaultStore requestProductWithIdentifiers:productIds success:^(NSArray *products, NSArray *invalidIdentifiers) {
        
        [self hideLoading];
        
        if (products.count > 0) {
            
            [self processData:products];
            
        } else if (products.count == 0 && invalidIdentifiers.count > 0) {
            
            // Please check the product information you set up.
            [self showTipsMessage:@"There are no products for sale!"];
        }
        
    } failure:^(NSError *error) {
        
        [self hideLoading];
        
        NSString *value = error.userInfo[NSLocalizedDescriptionKey];
        NSString *msg = value ?: error.localizedDescription;
        [self sendNotice:[NSString stringWithFormat:@"An error occurs, %zi, %@", error.code, msg]];
    }];
}

- (void)processData:(NSArray *)products {
    
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:0];
    
    for (SKProduct *product in products) {
        
        DYFStoreProduct *p = [[DYFStoreProduct alloc] init];
        p.identifier = product.productIdentifier;
        p.name = product.localizedTitle;
        p.price = [product.price stringValue];
        p.localePrice = [DYFStore.defaultStore localizedPriceOfProduct:product];
        p.localizedDescription = product.localizedDescription;
        
        [modelArray addObject:p];
    }
    
    [self displayStoreUI:modelArray];
}

- (void)displayStoreUI:(NSMutableArray *)dataArray {
    
    if (![DYFStore canMakePayments]) {
        [self showTipsMessage:@"Your device is not able or allowed to make payments!"];
        return;
    }
    
    DYFStoreViewController *storeVC = [[DYFStoreViewController alloc] init];
    storeVC.dataArray = dataArray;
    [self.navigationController pushViewController:storeVC animated:YES];
}

- (void)sendNotice:(NSString *)message {
    [self showAlertWithTitle:NSLocalizedStringFromTable(@"Notification", nil, @"")
                     message:message
           cancelButtonTitle:nil
                      cancel:NULL
          confirmButtonTitle:NSLocalizedStringFromTable(@"I see!", nil, @"")
                     execute:^(UIAlertAction *action) {
        DYFStoreLog(@"Alert action title: %@", action.title);
    }];
}

@end
