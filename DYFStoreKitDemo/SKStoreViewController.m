//
//  SKStoreViewController.m
//
//  Created by Teng Fei on 2014/11/4.
//  Copyright © 2014 Teng Fei. All rights reserved.
//

#import "SKStoreViewController.h"
#import "SKStoreTableViewCell.h"
#import "SKIAPManager.h"

@interface SKStoreViewController ()

@end

@implementation SKStoreViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Store", @"");
    [self addRightBarButtonItem];
}

- (void)addRightBarButtonItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"Restore" style:UIBarButtonItemStylePlain target:self action:@selector(restore)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)restore {
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYFCryptoSHA256(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    [SKIAPManager.shared restorePurchases:userIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = @"StoreTableViewCell";
    
    SKStoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass(SKStoreTableViewCell.class) bundle:nil];
        cell = [nib instantiateWithOwner:nil options:nil][0];
    }
    
    SKStoreProduct *product = self.dataArray[indexPath.row];
    cell.nameLabel.text = product.name;
    cell.localePriceLabel.text = product.localePrice;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SKStoreProduct *product = self.dataArray[indexPath.row];
    NSString *productIdentifier = product.identifier;
    DYFStoreLog(@"productIdentifier: %@", productIdentifier);
    
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYFCryptoSHA256(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    [SKIAPManager.shared addPayment:productIdentifier userIdentifier:userIdentifier];
}

- (void)dealloc {
    DYFStoreLog();
}

@end
