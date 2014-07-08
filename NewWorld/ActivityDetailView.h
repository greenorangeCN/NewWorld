//
//  ActivityDetailView.h
//  NewWorld
//
//  Created by Seven on 14-7-5.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityDetailView : UIViewController
{
    MBProgressHUD *hud;
}

@property (strong, nonatomic) Activity *activity;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
- (IBAction)jionAction:(id)sender;

@end
