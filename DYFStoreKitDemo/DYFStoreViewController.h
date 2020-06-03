//
//  DYFStoreViewController.h
//
//  Created by dyf on 2014/11/4. ( https://github.com/dgynfi/DYFStoreKit )
//  Copyright © 2014 dyf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYFStoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *storeTableView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end
