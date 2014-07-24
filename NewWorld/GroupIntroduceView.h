//
//  GroupIntroduceView.h
//  NewWorld
//
//  Created by Seven on 14-7-24.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupIntroduceView : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end
