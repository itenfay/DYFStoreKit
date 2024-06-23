//
//  ViewController.m
//
//  Created by Tenfay on 2014/11/4.
//  Copyright © 2014 Tenfay. All rights reserved.
//

#import "ViewController.h"
#import "SKIAPManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"In-app Purchase", @"");
    [self configure];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //UIWindow *mainWindow = [self mainWindow];
    //NSLog(@"mainWindow: %@", mainWindow);
    //UIViewController *currVC = [self currentViewController];
    //NSLog(@"currVC: %@, self: %@", currVC, self);
}

- (void)configure
{
    self.fetchesProductAndSubmitsPaymentButton.setCorner(UIRectCornerAllCorners, 20.f);
    self.fetchesProductsAndDisplaysStoreUIButton.setCorner(UIRectCornerAllCorners, 20.f);
}

/// Strategy 1:
///  - Step 1: Requests localized information about a product from the Apple App Store.
///  - Step 2: Adds payment of the product with the given product identifier.
- (IBAction)fetchesProductAndSubmitsPayment:(id)sender
{
    // You need to check whether the device is not able or allowed to make payments before requesting product.
    if (![DYFStore canMakePayments]) {
        [self sk_showTipsMessage:@"Your device is not able or allowed to make payments!"];
        return;
    }
    [self sk_showLoading:@"Loading..."];
    
    NSArray *productIds = [self fetchProductIdentifiersFromServer];
    NSUInteger index = arc4random_uniform((uint32_t)productIds.count);
    NSString *productId = productIds[index];
    [DYFStore.defaultStore requestProductWithIdentifier:productId success:^(NSArray *products, NSArray *invalidIdentifiers) {
        [self sk_hideLoading];
        if (products.count == 1) {
            NSString *productId = ((SKProduct *)products[0]).productIdentifier;
            [self addPayment:productId];
        } else {
            [self sk_showTipsMessage:@"There is no this product for sale!"];
            // Test
            //[self displayStoreUI:[self getSampleProducts]];
        }
    } failure:^(NSError *error) {
        [self sk_hideLoading];
        NSString *value = error.userInfo[NSLocalizedDescriptionKey];
        NSString *msg = value ?: error.localizedDescription;
        // This indicates that the product cannot be fetched, because an error was reported.
        [self sendNotice:[NSString stringWithFormat:@"An error occurs, %zi, %@", error.code, msg]];
    }];
}

- (void)addPayment:(NSString *)productId
{
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYFCryptoSHA256(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    [SKIAPManager.shared addPayment:productId userIdentifier:userIdentifier];
}

/// Strategy 2:
///  - Step 1: Requests localized information about a set of products from the Apple App Store.
///  - Step 2: After retrieving the localized product list, then display store UI.
///  - Step 3: Adds payment of the product with the given product identifier.
- (IBAction)fetchesProductsFromAppStore:(id)sender
{
    // You need to check whether the device is not able or allowed to make payments before requesting products.
    if (![DYFStore canMakePayments]) {
        [self sk_showTipsMessage:@"Your device is not able or allowed to make payments!"];
        return;
    }
    [self sk_showLoading:@"Loading..."];
    
    NSArray *productIds = [self fetchProductIdentifiersFromServer];
    [DYFStore.defaultStore requestProductWithIdentifiers:productIds success:^(NSArray *products, NSArray *invalidIdentifiers) {
        [self sk_hideLoading];
        if (products.count > 0) {
            [self processData:products];
        } else if (products.count == 0 && invalidIdentifiers.count > 0) {
            // Please check the product information you set up.
            [self sk_showTipsMessage:@"There are no products for sale!"];
        }
    } failure:^(NSError *error) {
        [self sk_hideLoading];
        NSString *value = error.userInfo[NSLocalizedDescriptionKey];
        NSString *msg = value ?: error.localizedDescription;
        // This indicates that the products cannot be fetched, because an error was reported.
        [self sendNotice:[NSString stringWithFormat:@"An error occurs, %zi, %@", error.code, msg]];
    }];
}

- (void)processData:(NSArray *)products
{
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:0];
    for (SKProduct *product in products) {
        SKStoreProduct *p = [[SKStoreProduct alloc] init];
        p.identifier = product.productIdentifier;
        p.name = product.localizedTitle;
        p.price = [product.price stringValue];
        p.localePrice = [DYFStore.defaultStore localizedPriceOfProduct:product];
        p.localizedDescription = product.localizedDescription;
        [modelArray addObject:p];
    }
    [self displayStoreUI:modelArray];
}

- (void)displayStoreUI:(NSMutableArray *)dataArray
{
    SKStoreViewController *storeVC = [[SKStoreViewController alloc] init];
    storeVC.dataArray = dataArray;
    [self.navigationController pushViewController:storeVC animated:YES];
}

- (void)sendNotice:(NSString *)message
{
    [self sk_showAlertWithTitle:NSLocalizedStringFromTable(@"Notification", nil, @"")
                        message:message
              cancelButtonTitle:nil
                         cancel:NULL
             confirmButtonTitle:NSLocalizedStringFromTable(@"I see!", nil, @"")
                        execute:^(UIAlertAction *action) {
        DYFStoreLog(@"Alert action title: %@", action.title);
    }];
}

- (NSArray *)fetchProductIdentifiersFromServer
{
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

- (NSMutableArray<SKStoreProduct *> *)getSampleProducts {
    NSMutableArray<SKStoreProduct *> *prodArray = [NSMutableArray array];
    SKStoreProduct *p1 = [SKStoreProduct.alloc init];
    p1.identifier = @"com.hncs.szj.coin42";
    p1.name = @"42 gold coins";
    p1.price = @"￥6";
    p1.localePrice = @"LocalePrice: ---";
    p1.localizedDescription = @"42 gold coins for ￥6";
    [prodArray addObject:p1];
    
    SKStoreProduct *p2 = [SKStoreProduct.alloc init];
    p2.identifier = @"com.hncs.szj.coin210";
    p2.name = @"210 gold coins";
    p2.price = @"￥30";
    p2.localePrice = @"LocalePrice: ---";
    p2.localizedDescription = @"210 gold coins for ￥30";
    [prodArray addObject:p2];
    
    SKStoreProduct *p3 = [SKStoreProduct.alloc init];
    p3.identifier = @"com.hncs.szj.coin686";
    p3.name = @"686 gold coins";
    p3.price = @"￥98";
    p3.localePrice = @"LocalePrice: ---";
    p3.localizedDescription = @"686 gold coins for ￥98";
    [prodArray addObject:p3];
    
    SKStoreProduct *p4 = [SKStoreProduct.alloc init];
    p4.identifier = @"com.hncs.szj.coin1386";
    p4.name = @"1386 gold coins";
    p4.price = @"￥198";
    p4.localePrice = @"LocalePrice: ---";
    p4.localizedDescription = @"1386 gold coins for ￥198";
    [prodArray addObject:p4];
    
    SKStoreProduct *p5 = [SKStoreProduct.alloc init];
    p5.identifier = @"com.hncs.szj.coin4886";
    p5.name = @"4886 gold coins";
    p5.price = @"￥698";
    p5.localePrice = @"LocalePrice: ---";
    p5.localizedDescription = @"4886 gold coins for ￥698";
    [prodArray addObject:p5];
    
    SKStoreProduct *p6 = [SKStoreProduct.alloc init];
    p6.identifier = @"com.hncs.szj.vip1";
    p6.name = @"VIP1";
    p6.price = @"￥299";
    p6.localePrice = @"LocalePrice: ---";
    p6.localizedDescription = @"Non-renewable vip subscription for a month";
    [prodArray addObject:p6];
    
    SKStoreProduct *p7 = [SKStoreProduct.alloc init];
    p7.identifier = @"com.hncs.szj.vip2";
    p7.name = @"VIP2";
    p7.price = @"￥699";
    p7.localePrice = @"LocalePrice: ---";
    p7.localizedDescription = @"Auto-renewable vip subscription for three months";
    [prodArray addObject:p7];
    
    return prodArray;
}

@end
