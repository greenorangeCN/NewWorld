//
//  HomePageView.m
//  NewWorld
//
//  Created by Seven on 14-6-25.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "HomePageView.h"

@interface HomePageView ()

@end

@implementation HomePageView
@synthesize housesNavi;
@synthesize topImage;
@synthesize projectShow;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"tab_home"];
        self.tabBarItem.title = @"首页";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTopImage];
    
    //楼盘导航事件注册
    UITapGestureRecognizer *naviTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(naviClick)];
	[self.housesNavi addGestureRecognizer:naviTap];
    
    //项目展示事件注册
    UITapGestureRecognizer *showTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(projectShowClick)];
	[self.projectShow addGestureRecognizer:showTap];
}

- (void)naviClick
{
    MapViewController *mapView = [[MapViewController alloc] init];
    mapView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mapView animated:YES];
}

- (void)projectShowClick
{
    ProjectCollectionView *projectView = [[ProjectCollectionView alloc] init];
    projectView.showType = @"projectIntro";
    projectView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:projectView animated:YES];
}

- (void)initTopImage
{
    NSString *url = [NSString stringWithFormat:@"%@%@", api_base_url, api_recommend_activities];
    
    if ([UserModel Instance].isNetworkRunning) {
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           activities = [Tool readJsonStrToActivitiesArray:operation.responseString];
                                           int length = [activities count];
                                           NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
                                           if (length > 1)
                                           {
                                               Activity *activity = [activities objectAtIndex:length-1];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:activity.indexImg tag:-1];
                                               [itemArray addObject:item];
                                           }
                                           for (int i = 0; i < length; i++)
                                           {
                                               Activity *activity = [activities objectAtIndex:i];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:activity.indexImg tag:-1];
                                               [itemArray addObject:item];
                                               
                                           }
                                           //添加第一张图 用于循环
                                           if (length >1)
                                           {
                                               Activity *activity = [activities objectAtIndex:0];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:activity.indexImg tag:-1];
                                               [itemArray addObject:item];
                                           }
                                           bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, 320, 148) delegate:self imageItems:itemArray isAuto:YES];
                                           [bannerView scrollToIndex:0];
                                           [self.topImage addSubview:bannerView];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"地图获取出错");
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
        
    }
    //如果没有网络连接
    else
    {
        
    }
}

//顶部图片滑动点击委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame didSelectItem:(SGFocusImageItem *)item
{
    NSLog(@"%s \n click===>%@",__FUNCTION__,item.title);
}

//顶部图片自动滑动委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;
{
    NSLog(@"%s \n scrollToIndex===>%d",__FUNCTION__,index);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    bannerView.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    bannerView.delegate = nil;
}

- (IBAction)seeHouseAction:(id)sender {
    ProjectCollectionView *projectView = [[ProjectCollectionView alloc] init];
    projectView.showType = @"seeHouse";
    projectView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:projectView animated:YES];
}

- (IBAction)newsActivityAction:(id)sender {
    ActivityCollectionView *activityView = [[ActivityCollectionView alloc] init];
    activityView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityView animated:YES];
}
@end
