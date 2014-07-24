//
//  MyOrderTableView.h
//  NewWorld
//
//  Created by Seven on 14-7-22.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyOrder.h"
#import "MyOrderCell.h"
#import "EGOImageView.h"

@interface MyOrderTableView : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *myOrders;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UITableView *myOrderTable;
@end
