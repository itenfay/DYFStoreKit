//
//  DYFStoreViewController.m
//
//  Created by dyf on 2014/11/4.
//  Copyright © 2014 dyf. ( https://github.com/dgynfi/DYFStoreKit )
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

#import "DYFStoreViewController.h"
#import "DYFStoreProduct.h"
#import "DYFStoreTableViewCell.h"
#import "DYFStoreManager.h"

@interface DYFStoreViewController ()

@end

@implementation DYFStoreViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
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
    NSString *accountName = @"Handsome Jon";
    
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
    NSLog(@"%s userIdentifier: %@", __FUNCTION__, userIdentifier);
    
    [DYFStoreManager.shared restorePurchases:userIdentifier];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
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
    NSLog(@"%s productIdentifier: %@", __FUNCTION__, productIdentifier);
    
    NSString *accountName = @"Handsome Jon";
    
    NSString *userIdentifier = DYF_SHA256_HashValue(accountName);
    NSLog(@"%s userIdentifier: %@", __FUNCTION__, userIdentifier);
    
    [DYFStoreManager.shared buyProduct:productIdentifier userIdentifier:userIdentifier];
}

- (void)dealloc {
#if DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
}

@end
