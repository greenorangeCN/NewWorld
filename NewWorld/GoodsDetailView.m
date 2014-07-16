//
//  GoodsDetailView.m
//  NewWorld
//
//  Created by Seven on 14-7-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "GoodsDetailView.h"

@interface GoodsDetailView ()

@end

@implementation GoodsDetailView

@synthesize goodsId;
@synthesize scrollView;
@synthesize picIv;
@synthesize priceLb;
@synthesize marketPriceLb;
@synthesize buysLb;
@synthesize webView;
@synthesize deliveryBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"商品详情";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        
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
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", detail.phone]];
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
    //适配iOS7  scrollView计算uinavigationbar高度的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    NSString *detailUrl = [NSString stringWithFormat:@"%@%@?id=%@", api_base_url, api_goods_detail, self.goodsId];
    NSURL *url = [ NSURL URLWithString : detailUrl];
    // 构造 ASIHTTPRequest 对象
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    // 开始同步请求
    [request startSynchronous ];
    NSError *error = [request error ];
    assert (!error);
    detail = [Tool readJsonStrToGoodsDetail:[request responseString]];
    
    //图片加载
    EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic1.png"]];
    imageView.imageURL = [NSURL URLWithString:detail.thumb];
    imageView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 187.0f);
    [self.picIv addSubview:imageView];
    //带删除线价格加载
    StrikeThroughLabel *slabel = [[StrikeThroughLabel alloc] initWithFrame:CGRectMake(0, 0, 72, 21)];
    slabel.text = [NSString stringWithFormat:@"￥%@", detail.market_price];
    slabel.font = [UIFont italicSystemFontOfSize:12.0f];
    slabel.textColor = [UIColor whiteColor];
    slabel.textAlignment = UITextAlignmentCenter;
    slabel.strikeThroughEnabled = YES;
    [self.marketPriceLb addSubview:slabel];
    self.priceLb.text = [NSString stringWithFormat:@"￥%@", detail.price];
    self.buysLb.text = [NSString stringWithFormat:@"已售%@", detail.buys];
    
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    self.webView.delegate = self;
    NSString *html = [NSString stringWithFormat:@"<body>%@<div id='web_summary'>%@</div><div id='web_column'>%@</div><div id='web_body'>%@</div></body>", HTML_Style, detail.summary, @"商品详情", detail.content];
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

- (IBAction)deliveryAction:(id)sender {
    OrderView *orderView = [[OrderView alloc] init];
    orderView.goodsDetail = detail;
    [self.navigationController pushViewController:orderView animated:YES];
}
@end
