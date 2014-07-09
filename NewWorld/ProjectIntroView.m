//
//  ProjectIntroView.m
//  NewWorld
//
//  Created by Seven on 14-7-5.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ProjectIntroView.h"

@interface ProjectIntroView ()

@end

@implementation ProjectIntroView

@synthesize project;
@synthesize topImage;
@synthesize logoIv;
@synthesize titleLb;
@synthesize summaryLb;
@synthesize houseTypeLb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [lBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [lBtn setImage:[UIImage imageNamed:@"cc_back"] forState:UIControlStateNormal];
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
        self.navigationItem.leftBarButtonItem = btnBack;
        
        UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
        [rBtn addTarget:self action:@selector(telAction) forControlEvents:UIControlEventTouchUpInside];
        [rBtn setImage:[UIImage imageNamed:@"top_tel"] forState:UIControlStateNormal];
        UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
        self.navigationItem.rightBarButtonItem = btnTel;
    }
    return self;
}

- (void)telAction
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", project.telephone]];
    if (!phoneCallWebView) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //数据加载时设置顶部导航标题
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = project.title;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    [Tool roundView:self.logoIv andCornerRadius:5.0f];
    self.logoIv.image = project.imgData;
    self.titleLb.text = project.title;
    self.summaryLb.text = project.summary;
    
    [self initTopImage];
    
    //楼盘简介事件注册
    UITapGestureRecognizer *summaryTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(summaryClick)];
	[self.summaryLb addGestureRecognizer:summaryTap];
    
    //户型展示事件注册
    UITapGestureRecognizer *houseTypeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(houseTypeClick)];
	[self.houseTypeLb addGestureRecognizer:houseTypeTap];
}

- (void)summaryClick
{
    MapDetailView *mapdetailView = [[MapDetailView alloc] init];
    mapdetailView.projectId = project.id;
    mapdetailView.projectTitle = project.title;
    mapdetailView.dataType = 0;
    [self.navigationController pushViewController:mapdetailView animated:YES];
}

- (void)houseTypeClick
{
    HouseTypeCollectionView *houseTypeView = [[HouseTypeCollectionView alloc] init];
    houseTypeView.projectId = project.id;
    [self.navigationController pushViewController:houseTypeView animated:YES];
}

- (void)initTopImage
{
    NSString *url = [NSString stringWithFormat:@"%@%@?id=%@", api_base_url, api_slider_image, project.id];
    
    if ([UserModel Instance].isNetworkRunning) {
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSMutableArray *images = [Tool readJsonStrToSliderImageArray:operation.responseString];
                                           int length = [images count];
                                           NSMutableArray *itemArray = [NSMutableArray arrayWithCapacity:length+2];
                                           if (length > 1)
                                           {
                                               NSString *imagePath = [images objectAtIndex:length-1];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:imagePath tag:-1];
                                               [itemArray addObject:item];
                                           }
                                           for (int i = 0; i < length; i++)
                                           {
                                               NSString *imagePath = [images objectAtIndex:i];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:imagePath tag:-1];
                                               [itemArray addObject:item];
                                               
                                           }
                                           //添加第一张图 用于循环
                                           if (length >1)
                                           {
                                               NSString *imagePath = [images objectAtIndex:0];
                                               SGFocusImageItem *item = [[SGFocusImageItem alloc] initWithTitle:@"" image:imagePath tag:-1];
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
//    NSLog(@"%s \n click===>%@",__FUNCTION__,item.title);
}

//顶部图片自动滑动委托协议实现事件
- (void)foucusImageFrame:(SGFocusImageFrame *)imageFrame currentItem:(int)index;
{
//    NSLog(@"%s \n scrollToIndex===>%d",__FUNCTION__,index);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    bannerView = nil;
    bannerView.delegate = nil;
}

@end
