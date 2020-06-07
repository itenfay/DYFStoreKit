//
//  DYFStoreViewController.m
//
//  Created by dyf on 2014/11/4. ( https://github.com/dgynfi/DYFStoreKit )
//  Copyright © 2014 dyf. All rights reserved.
//

#import "DYFStoreViewController.h"
#import "DYFStoreTableViewCell.h"
#import "DYFStoreManager.h"

@interface DYFStoreViewController ()

@end

@implementation DYFStoreViewController

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
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    
    [DYFStoreManager.shared restorePurchases:userIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"StoreTableViewCell";
    
    DYFStoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        UINib *nib = [UINib nibWithNibName:NSStringFromClass(DYFStoreTableViewCell.class) bundle:nil];
        cell = [nib instantiateWithOwner:nil options:nil][0];
    }
    
    DYFStoreProduct *product = self.dataArray[indexPath.row];
    cell.nameLabel.text = product.name;
    cell.localePriceLabel.text = product.localePrice;
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DYFStoreProduct *product = self.dataArray[indexPath.row];
    NSString *productIdentifier = product.identifier;
    DYFStoreLog(@"productIdentifier: %@", productIdentifier);
    
    // Get account name from your own user system.
    NSString *accountName = @"Handsome Jon";
    
    // This algorithm is negotiated with server developer.
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
    DYFStoreLog(@"userIdentifier: %@", userIdentifier);
    
    [DYFStoreManager.shared addPayment:productIdentifier userIdentifier:userIdentifier];
}

- (void)dealloc {
    DYFStoreLog();
}

@end
