//
//  SKStoreViewController.h
//
//  Created by Teng Fei on 2014/11/4.
//  Copyright © 2014 Teng Fei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKStoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *storeTableView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end
