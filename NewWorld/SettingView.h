//
//  SettingView.h
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingModel.h"
#import "RegisterView.h"
#import "LoginView.h"
#import "UserModel.h"
#import "UserInfoView.h"
#import "MyOrderTableView.h"
#import "MyCouponView.h"
#import "ChangePwdView.h"

@interface SettingView : UIViewController<UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate>
{
    UIWebView *phoneCallWebView;
    NSArray * settings;
    NSMutableDictionary * settingsInSection;
}

@property (retain,nonatomic) NSString *titleStr;

@property (strong, nonatomic) IBOutlet UITableView *tableSettings;
@property (retain,nonatomic) NSArray * settings;
@property (retain,nonatomic) NSMutableDictionary * settingsInSection;

@end
