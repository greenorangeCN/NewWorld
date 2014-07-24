//
//  MyCouponView.h
//  NewWorld
//
//  Created by Seven on 14-7-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyCoupon.h"
#import "MyCouponCell.h"
#import "EGOImageView.h"
#import "CouponDetailView.h"

@interface MyCouponView : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *myCoupons;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UITableView *myCouponTable;
@end
