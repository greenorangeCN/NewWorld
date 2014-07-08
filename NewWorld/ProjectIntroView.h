//
//  ProjectIntroView.h
//  NewWorld
//
//  Created by Seven on 14-7-5.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"
#import "MapDetailView.h"

@interface ProjectIntroView : UIViewController<SGFocusImageFrameDelegate>
{
    UIWebView *phoneCallWebView;
    SGFocusImageFrame *bannerView;
}
@property (strong, nonatomic) IBOutlet UIImageView *logoIv;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UILabel *summaryLb;
@property (strong, nonatomic) IBOutlet UIImageView *topImage;
@property (strong, nonatomic) HousesProject *project;

@end
