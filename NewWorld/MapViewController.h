//
//  MapViewController.h
//  Sjdnbm
//
//  Created by tyh on 13-9-22.
//  Copyright (c) 2013年 tyh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KYBubbleView.h"
#import "KYPointAnnotation.h"
#import <sys/xattr.h>
#import "BMapKit.h"
#import "KxMenu.h"

@interface MapViewController : UIViewController<BMKMapViewDelegate, BMKLocationServiceDelegate, UITabBarDelegate>
{
    IBOutlet BMKMapView* _mapView;
    KYBubbleView *bubbleView;
    BMKAnnotationView *selectedAV;
    
    NSMutableArray *mapsTemp;
    NSMutableArray *mapsAll;
    NSMutableArray *mapsSchool;
    NSMutableArray *mapsGov;
    NSMutableArray *mapsShop;
    NSMutableArray *mapsService;
    
    NSMutableArray *houses;
    
    BOOL isPinSelected;     //用于判断大头针是否被选中
    BMKLocationService* _locService;
}

- (void)showBubble:(BOOL)show;
-(void)cleanMap;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
@property (strong, nonatomic) IBOutlet UITabBar *tabBar;
- (IBAction)backAction:(id)sender;
- (IBAction)showMenuAction:(UIButton *)sender;

@end

