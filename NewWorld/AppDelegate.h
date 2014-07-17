//
//  AppDelegate.h
//  NewWorld
//
//  Created by Seven on 14-6-25.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckNetwork.h"
#import "HomePageView.h"
#import "ActivityTableView.h"
#import "BusinessTableView.h"
#import "SettingView.h"
#import "BMapKit.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import "WeiboApi.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) HomePageView *homePage;
@property (strong, nonatomic) ActivityTableView *activityView;
@property (strong, nonatomic) BusinessTableView *businessView;
@property (strong, nonatomic) SettingView *settingView;

@end
