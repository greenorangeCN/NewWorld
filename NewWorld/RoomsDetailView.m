//
//  RoomsDetailView.m
//  NewWorld
//
//  Created by Seven on 14-7-15.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RoomsDetailView.h"

@interface RoomsDetailView ()

@end

@implementation RoomsDetailView

@synthesize picIv;
@synthesize summaryLb;
@synthesize imageScrollView;
@synthesize houseType;
@synthesize scrollView;
@synthesize titleLb;
@synthesize photos = _photos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"户型详情";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        
        UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [lBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [lBtn setImage:[UIImage imageNamed:@"cc_back"] forState:UIControlStateNormal];
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
        self.navigationItem.leftBarButtonItem = btnBack;
    }
    return self;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //适配iOS7  scrollView计算uinavigationbar高度的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    NSString *detailUrl = [NSString stringWithFormat:@"%@%@?id=%@", api_base_url, api_housetype_detail, houseType.id];
    NSURL *url = [ NSURL URLWithString : detailUrl];
    // 构造 ASIHTTPRequest 对象
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    // 开始同步请求
    [request startSynchronous ];
    NSError *error = [request error ];
    assert (!error);
    roomsDetail = [Tool readJsonStrToHouseTypeDetail:[request responseString]];
    
    self.titleLb.text = roomsDetail.title;
    //图片加载
    EGOImageView *picView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic1.png"]];
    picView.imageURL = [NSURL URLWithString:roomsDetail.thumb];
    picView.frame = CGRectMake(0.0f, 0.0f, 118.0f, 92.0f);
    [self.picIv addSubview:picView];
    
    //调整行间距
    NSString *summaryStr = roomsDetail.summary;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:summaryStr];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5];//调整行间距
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [summaryStr length])];
    self.summaryLb.attributedText = attributedString;

    int contentWidth = 0;
    for (NSString *imageUrl in roomsDetail.images) {
        //异步加载无法获取网络图片的高度宽度
        UIImageView *imageView= [[UIImageView alloc] init];
        imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
//        imageView.imageURL = [NSURL URLWithString:imageUrl];
        imageView.frame = CGRectZero;
        [imageView sizeToFit];
        CGRect rect = imageView.frame;
        rect.origin = CGPointMake(contentWidth, 0);
        rect.size.height = self.imageScrollView.bounds.size.height;
        rect.size.width = imageView.frame.size.width/(imageView.frame.size.height/self.imageScrollView.bounds.size.height);
        contentWidth += rect.size.width;
        imageView.frame = rect;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.imageScrollView addSubview:imageView];
    }
    self.imageScrollView.contentSize = CGSizeMake(contentWidth, self.imageScrollView.bounds.size.height);
    //图片事件注册
    UITapGestureRecognizer *imagesTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imagesClick)];
	[self.imageScrollView addGestureRecognizer:imagesTap];
    
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    self.webView.delegate = self;
    NSString *html = @"暂无数据";
    NSString *result = [Tool getHTMLString:html];
    [self.webView loadHTMLString:result baseURL:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    if (hud != nil) {
        [hud hide:YES];
    }
    NSArray *arr = [webViewP subviews];
    UIScrollView *webViewScroll = [arr objectAtIndex:0];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, webViewP.frame.origin.y + [webViewScroll contentSize].height);
    [webViewP setFrame:CGRectMake(webViewP.frame.origin.x, webViewP.frame.origin.y, webViewP.frame.size.width, [webViewScroll contentSize].height)];
}

- (void)imagesClick
{
    if (roomsDetail.images && [roomsDetail.images count] > 0) {
        NSMutableArray *photos = [[NSMutableArray alloc] init];
        for (NSString *imageUrl in roomsDetail.images) {
            [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageUrl]]];
        }
        self.photos = photos;
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        self.navigationController.navigationBar.hidden = NO;
        [self.navigationController pushViewController:browser animated:YES];
    }
}

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [self.webView stopLoading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
}

@end
