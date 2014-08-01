//
//  PanoramaView.h
//  NewWorld
//
//  Created by Seven on 14-7-30.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KxMenu.h"
#import "Panorama.h"

@interface PanoramaView : UIViewController<UIWebViewDelegate>
{
    MBProgressHUD *hud;
    NSMutableArray *scenes;
}

@property (strong, nonatomic) NSString *roomId;
@property (strong, nonatomic) NSString *roomName;

@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIView *naviView;
- (IBAction)backAction:(id)sender;
- (IBAction)showMenuAction:(UIButton *)sender;

@end
