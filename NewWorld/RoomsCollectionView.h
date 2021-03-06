//
//  RoomsCollectionView.h
//  NewWorld
//
//  Created by Seven on 14-7-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Rooms.h"
#import "RoomsCollectionCell.h"
#import "UITap.h"
#import "EGOImageView.h"
#import "MWPhotoBrowser.h"

@interface RoomsCollectionView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, MWPhotoBrowserDelegate>
{
    NSMutableArray *rooms;
    NSArray *_photos;
}

@property (nonatomic, retain) NSArray *photos;

@property (strong, nonatomic) NSString *projectId;
@property (strong, nonatomic) NSString *projectName;

@property (strong, nonatomic) IBOutlet UICollectionView *roomsCollection;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
