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
#import "SGFocusImageFrame.h"
#import "SGFocusImageItem.h"

@interface HomePageView : UIViewController<SGFocusImageFrameDelegate>
{
    NSMutableArray *activities;
}

@property (strong, nonatomic) IBOutlet UILabel *topImage;

@property (strong, nonatomic) IBOutlet UIImageView *housesNavi;

@end
