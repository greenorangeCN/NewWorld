//
//  ClubDetailView.m
//  NewWorld
//
//  Created by Seven on 14-7-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ClubDetailView.h"

@interface ClubDetailView ()

@end

@implementation ClubDetailView

@synthesize item;
@synthesize scrollView;
@synthesize picIv;
@synthesize titleLb;
@synthesize webView;
@synthesize pointBtn;
@synthesize pointLb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"名仕会所";
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
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", detail.telephone]];
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
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
    NSString *detailUrl = [NSString stringWithFormat:@"%@%@?id=%@", api_base_url, api_clubitem_detail, self.item.id];
    NSURL *url = [ NSURL URLWithString : detailUrl];
    // 构造 ASIHTTPRequest 对象
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
    // 开始同步请求
    [request startSynchronous ];
    NSError *error = [request error ];
    assert (!error);
    detail = [Tool readJsonStrToClubDetail:[request responseString]];
    
    //图片加载
    EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic1.png"]];
    imageView.imageURL = [NSURL URLWithString:detail.thumb];
    imageView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 167.0f);
    [self.picIv addSubview:imageView];
    self.pointLb.text = [NSString stringWithFormat:@"( %@ )", detail.points];
    
    self.titleLb.text = detail.title;
    //WebView的背景颜色去除
    [Tool clearWebViewBackground:self.webView];
    //    [self.webView setScalesPageToFit:YES];
    [self.webView sizeToFit];
    self.webView.delegate = self;
    //字符串替换“\n”替换成"< /br>"换行
    NSString *content = [detail.details stringByReplacingOccurrencesOfString:@"\n" withString:@"</br>"];
    NSString *html = [NSString stringWithFormat:@"<body>%@<div id='web_summary'>%@</div><div id='web_column'>%@</div><div id='web_body'>%@</div></body>", HTML_Style, detail.intro, @"服务细则及价格", content];
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
    // Dispose of any resources that can be recreated.
}

- (IBAction)pointAction:(id)sender {
    NSString *detailUrl = [NSString stringWithFormat:@"%@%@?model=Items&id=%@", api_base_url, api_praise, detail.id];
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
            detail.points = [NSString stringWithFormat:@"%d", [detail.points intValue] + 1];
            self.pointLb.text = [NSString stringWithFormat:@"( %@ )", detail.points];
        }
    }
}

- (IBAction)shareAction:(id)sender {
    NSDictionary *contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSString stringWithFormat:@"%@：%@", detail.club_name, detail.title], @"title",
                                detail.intro, @"summary",
                                detail.thumb, @"thumb",
                                nil];
    [Tool shareAction:sender andShowView:self.view andContent:contentDic];
}
@end
