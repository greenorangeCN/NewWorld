//
//  OnlineChatView.h
//  NewWorld
//
//  Created by Seven on 14-7-23.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnlineChatView : UIViewController<UIWebViewDelegate>
{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
