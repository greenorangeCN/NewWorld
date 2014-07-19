//
//  HomePageView.h
//  NewWorld
//
//  Created by Seven on 14-6-25.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"
#import "MapViewController.h"
#import "ProjectCollectionView.h"
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"
#import "ActivityCollectionView.h"

@interface HomePageView : UIViewController<SGFocusImageFrameDelegate>
{
    NSMutableArray *activities;
    SGFocusImageFrame *bannerView;
    int activityIndex;
}

@property (strong, nonatomic) IBOutlet UIImageView *topImage;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *housesNavi;
@property (strong, nonatomic) IBOutlet UIImageView *projectShow;
- (IBAction)seeHouseAction:(id)sender;
- (IBAction)newsActivityAction:(id)sender;
- (IBAction)praiseAction:(id)sender;
- (IBAction)showDetailAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)clubAction:(id)sender;

@end
