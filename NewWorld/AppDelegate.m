//
//  AppDelegate.m
//  NewWorld
//
//  Created by Seven on 14-6-25.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "AppDelegate.h"

BMKMapManager* _mapManager;

@implementation AppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize homePage;
@synthesize activityView;
@synthesize businessView;
@synthesize settingView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //检查网络是否存在 如果不存在 则弹出提示
    [UserModel Instance].isNetworkRunning = [CheckNetwork isExistenceNetwork];
    //显示系统托盘
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    //首页
    self.homePage = [[HomePageView alloc] initWithNibName:@"HomePageView" bundle:nil];
    UINavigationController *homePageNav = [[UINavigationController alloc] initWithRootViewController:self.homePage];
    //活动
    self.activityView = [[ActivityTableView alloc] initWithNibName:@"ActivityTableView" bundle:nil];
    UINavigationController *activityNav = [[UINavigationController alloc] initWithRootViewController:self.activityView];
    //商家服务
    self.businessView = [[BusinessTableView alloc] initWithNibName:@"BusinessTableView" bundle:nil];
    UINavigationController *businessNav = [[UINavigationController alloc] initWithRootViewController:self.businessView];
    //设置
    self.settingView = [[SettingView alloc] initWithNibName:@"SettingView" bundle:nil];
    UINavigationController *settingNav = [[UINavigationController alloc] initWithRootViewController:self.settingView];
    
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = [NSArray arrayWithObjects:
                                             homePageNav,
                                             activityNav,
                                             businessNav,
                                             settingNav,
                                             nil];
    // 要使用百度地图，请先启动BaiduMapManager
	_mapManager = [[BMKMapManager alloc]init];
	BOOL ret = [_mapManager start:@"HC0Bk3YCO9T3aoN5iGjbwu5D" generalDelegate:self];
	if (!ret) {
		NSLog(@"manager start failed!");
	}
    
    [[self.tabBarController tabBar] setSelectedImageTintColor:[UIColor colorWithRed:197.0/255 green:36.0/255 blue:42.0/255 alpha:1.0]];
    //设置UINavigationController背景
    if (IS_IOS7) {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bg7"]  forBarMetrics:UIBarMetricsDefault];
    }else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"top_bg"]  forBarMetrics:UIBarMetricsDefault];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.tabBarController ];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
