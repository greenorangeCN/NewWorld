//
//  PanoramaView.m
//  NewWorld
//
//  Created by Seven on 14-7-30.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "PanoramaView.h"

@interface PanoramaView ()

@end

@implementation PanoramaView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {  

    }
    return self;
}

- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showMenuAction:(UIButton *)sender
{
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    KxMenuItem *first = [KxMenuItem menuItem:@"场景选择"
                                       image:nil
                                      target:nil
                                         tag:nil
                                      action:NULL];
    [menuItems addObject:first];
    for (int i = 0; i < [scenes count]; i++) {
        Panorama *p = [scenes objectAtIndex:i];
        KxMenuItem *item = [KxMenuItem menuItem:p.name
                                          image:nil
                                         target:self
                                            tag:[NSString stringWithFormat:@"%d", i]
                                         action:@selector(pushMenuItem:)];
        [menuItems addObject:item];
    }
    KxMenuItem *first1 = menuItems[0];
    first1.foreColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0];
    first1.alignment = NSTextAlignmentCenter;
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    [Tool showHUD:@"加载中" andView:self.view andHUD:hud];
    KxMenuItem *item = sender;
    int tag = [item.tag intValue];
    Panorama *p = [scenes objectAtIndex:tag];
    NSURL *url=[NSURL URLWithString:p.url];
//    NSURL *url=[NSURL URLWithString:@"http://www.sina.com"];
    NSURLRequest *urlRequest=[[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:urlRequest];
    self.titleLb.text = p.name;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (!IS_IOS7) {
        self.naviView.frame = CGRectMake(0, 0, self.naviView.frame.size.width, self.naviView.frame.size.height - 20);
        self.webView.frame = CGRectMake(0, self.naviView.frame.size.height, self.webView.frame.size.width, self.webView.frame.size.height + 20);
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"加载中" andView:self.view andHUD:hud];
    
    NSURL *panoramaUrl = [ NSURL URLWithString : [NSString stringWithFormat:@"%@%@?rid=%@", api_base_url, api_fullview_list, self.roomId]];
    // 构造 ASIHTTPRequest 对象
    ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :panoramaUrl];
    // 开始同步请求
    [request startSynchronous ];
    NSError *error = [request error ];
    assert (!error);
    scenes = [Tool readJsonStrToPanoramaArray:[request responseString]];
    
 
    //直接加载网页
    self.webView.delegate = self;
    self.webView.opaque = NO;
    //不让UIWEBVIEW滚动
    for (UIView *subView in [self.webView subviews])
    {
        if ([subView isKindOfClass:[UIScrollView class]])
        {
            ((UIScrollView *)subView).bounces = NO; //去掉UIWebView的底图
        }
    }
    if ([scenes count] > 0) {
        Panorama *p = [scenes objectAtIndex:0];
        NSURL *url=[NSURL URLWithString:p.url];
        NSURLRequest *urlRequest=[[NSURLRequest alloc] initWithURL:url];
        [self.webView loadRequest:urlRequest];
        self.titleLb.text = p.name;
    }
    else
    {
        if (hud != nil) {
            [hud hide:YES];
        }
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webViewP
{
    if (hud != nil) {
        [hud hide:YES];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //    [self.webView stopLoading];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
