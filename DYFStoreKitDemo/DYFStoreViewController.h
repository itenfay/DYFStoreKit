//
//  DYFStoreViewController.h
//
//  Created by chenxing on 2014/11/4. ( https://github.com/chenxing640/DYFStoreKit )
//  Copyright © 2014 chenxing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYFStoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *storeTableView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end
