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
    activityIndex = 0;
    [self initTopImage];
    if (!IS_IPHONE_5) {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.bounds.size.width, 500)];
    }
    
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
                                           bannerView = [[SGFocusImageFrame alloc] initWithFrame:CGRectMake(0, 0, 320, 148) delegate:self imageItems:itemArray isAuto:NO];
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
//    NSLog(@"%s \n scrollToIndex===>%d",__FUNCTION__,index);
    activityIndex = index;
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

- (IBAction)newsActivityAction:(id)sender {
    ActivityCollectionView *activityView = [[ActivityCollectionView alloc] init];
    activityView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityView animated:YES];
}

- (IBAction)praiseAction:(id)sender
{
    Activity *activity = [activities objectAtIndex:activityIndex];
    NSString *detailUrl = [NSString stringWithFormat:@"%@%@?model=Activities&id=%@", api_base_url, api_praise, activity._id];
    NSURL *url = [ NSURL URLWithString : detailUrl];
    // 构造 ASIHTTPRequest 对象
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    // 开始同步请求
    [request startSynchronous ];
    NSError *error = [request error ];
    assert (!error);
    // 如果请求成功，返回 Response
    NSString *response = [request responseString ];
    NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSString *status = @"0";
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
    if (json) {
        status = [json objectForKey:@"status"];
        if ([status isEqualToString:@"1"]) {
            [Tool showCustomHUD:@"点赞成功" andView:self.view andImage:@"37x-Checkmark.png" andAfterDelay:1];
        }
        else
        {
            [Tool showCustomHUD:@"点赞失败" andView:self.view andImage:@"37x-Failure.png" andAfterDelay:1];
        }
    }
}

- (IBAction)showDetailAction:(id)sender {
    Activity *activity = [activities objectAtIndex:activityIndex];
    ActivityDetailView *activityDetail = [[ActivityDetailView alloc] init];
    activityDetail.activity = activity;
    activityDetail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:activityDetail animated:YES];
}

- (IBAction)shareAction:(id)sender {
    Activity *activity = [activities objectAtIndex:activityIndex];
    NSDictionary *contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                activity.title , @"title",
                                activity.summary, @"summary",
                                activity.thumb, @"thumb",
                                nil];
    [Tool shareAction:sender andShowView:self.view andContent:contentDic];
}

- (IBAction)clubAction:(id)sender {
    ProjectCollectionView *projectView = [[ProjectCollectionView alloc] init];
    projectView.showType = @"club";
    projectView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:projectView animated:YES];
}

- (IBAction)onlineChatAction:(id)sender {
    OnlineChatView *chatView = [[OnlineChatView alloc] init];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}

- (IBAction)introduceAction:(id)sender {
    GroupIntroduceView *introduceView = [[GroupIntroduceView alloc] init];
    introduceView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:introduceView animated:YES];
}

- (IBAction)myAction:(id)sender {
    if ([UserModel Instance].isLogin == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
        return;
    }
    SettingView *myView = [[SettingView alloc] init];
    myView.titleStr = @"我的";
    myView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:myView animated:YES];
}

- (IBAction)moreAction:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
	hud.labelText = @"更多功能即将推出，敬请期待";
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	
	[hud hide:YES afterDelay:3];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [Tool processLoginNotice:actionSheet andButtonIndex:buttonIndex andNav:self.navigationController andParent:nil];
}

@end
