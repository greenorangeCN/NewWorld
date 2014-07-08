//
//  MapDetailView.m
//  NewWorld
//
//  Created by Seven on 14-7-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "MapDetailView.h"

@interface MapDetailView ()

@end

@implementation MapDetailView

@synthesize projectId;
@synthesize projectTitle;
@synthesize dataType;
@synthesize scrollView;
@synthesize topImageIv;
@synthesize webView;
@synthesize typeLb;
@synthesize titleLb;

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
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", supportDetail.telephone]];
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
    titleLabel.text = projectTitle;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    NSString *detailUrl = @"";
    if (dataType == 0) {
        detailUrl = [NSString stringWithFormat:@"%@%@?id=%@", api_base_url, api_project_detail, projectId];
    }
    else
    {
        detailUrl = [NSString stringWithFormat:@"%@%@?id=%@", api_base_url, api_support_detail, projectId];
    }
    NSURL *url = [ NSURL URLWithString : detailUrl];
    // 构造 ASIHTTPRequest 对象
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    // 开始同步请求
    [request startSynchronous ];
    NSError *error = [request error ];
    assert (!error);
    // 开始同步请求
    [request startSynchronous ];
    supportDetail = [Tool readJsonStrToSupport:[request responseString]];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    self.webView.delegate = self;
    
    NSString *html = supportDetail.intro;
    if (html == nil || [html length] == 0) {
        html = @"暂无简介...";
    }
    NSString *result = [Tool getHTMLString:html];
    [self.webView loadHTMLString:result baseURL:nil];
    
    
    NSString *typeInt = supportDetail.type;
    NSString *typeStr = @"";
    if (dataType == 0) {
        typeStr = @"项目展示";
    }
    else
    {
        if ([typeInt isEqualToString:@"1"])
        {
            typeStr = @"教育配套";
        }
        else if ([typeInt  isEqualToString:@"2"])
        {
            typeStr = @"政府机关";
        }
        else if ([typeInt  isEqualToString:@"3"])
        {
            typeStr = @"购物消费";
        }
        else if ([typeInt  isEqualToString:@"4"])
        {
            typeStr = @"服务配套";
        }
    }
    self.typeLb.text = typeStr;
    
    self.titleLb.text = supportDetail.title;
    
    EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic1.png"]];
    if (dataType == 0) {
        imageView.imageURL = [NSURL URLWithString:supportDetail.bigpic];
    }
    else
    {
        imageView.imageURL = [NSURL URLWithString:supportDetail.thumb];
    }
    imageView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 172.0f);
    [self.topImageIv addSubview:imageView];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
