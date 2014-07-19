//
//  ClubDetailView.h
//  NewWorld
//
//  Created by Seven on 14-7-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface ClubDetailView : UIViewController<UIWebViewDelegate>
{
    UIWebView *phoneCallWebView;
    MBProgressHUD *hud;
    ClubItem *detail;
}

@property (strong, nonatomic) ClubItem *item;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *picIv;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *pointBtn;
@property (strong, nonatomic) IBOutlet UILabel *pointLb;
- (IBAction)pointAction:(id)sender;
- (IBAction)shareAction:(id)sender;

@end
