//
//  MapDetailView.h
//  NewWorld
//
//  Created by Seven on 14-7-4.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface MapDetailView : UIViewController<UIWebViewDelegate, UIScrollViewDelegate>
{
    UIWebView *phoneCallWebView;
    MBProgressHUD *hud;
    Support *supportDetail;
}

@property (strong, nonatomic) NSString *projectId;
@property (strong, nonatomic) NSString *projectTitle;
@property int dataType;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *topImageIv;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *typeLb;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;

@end
