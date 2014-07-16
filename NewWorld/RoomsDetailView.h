//
//  RoomsDetailView.h
//  NewWorld
//
//  Created by Seven on 14-7-15.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "MWPhotoBrowser.h"

@interface RoomsDetailView : UIViewController<UIWebViewDelegate, MWPhotoBrowserDelegate>
{
    MBProgressHUD *hud;
    HouseType *roomsDetail;
    NSArray *_photos;
}
@property (nonatomic, retain) NSArray *photos;

@property (strong, nonatomic) HouseType *houseType;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UIImageView *picIv;
@property (strong, nonatomic) IBOutlet UILabel *summaryLb;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@end
