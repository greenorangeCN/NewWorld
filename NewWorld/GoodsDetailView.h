//
//  GoodsDetailView.h
//  NewWorld
//
//  Created by Seven on 14-7-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "StrikeThroughLabel.h"

@interface GoodsDetailView : UIViewController<UIWebViewDelegate>
{
    UIWebView *phoneCallWebView;
    MBProgressHUD *hud;
    GoodsDetail *detail;
}
@property (strong, nonatomic) NSString *goodsId;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *picIv;
@property (strong, nonatomic) IBOutlet UILabel *priceLb;
@property (strong, nonatomic) IBOutlet UILabel *marketPriceLb;
@property (strong, nonatomic) IBOutlet UILabel *buysLb;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
