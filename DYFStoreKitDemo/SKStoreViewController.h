//
//  DYFStoreViewController.h
//
//  Created by Teng Fei on 2014/11/4. ( https://github.com/chenxing640/DYFStoreKit )
//  Copyright © 2014 Teng Fei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DYFStoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *storeTableView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end
