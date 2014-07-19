//
//  ActivityCollectionView.h
//  NewWorld
//
//  Created by Seven on 14-7-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Activity.h"
#import "ActivityCollectionCell.h"
#import "Activity_35CollectionCell.h"
#import "ActivityDetailView.h"
#import "UITap.h"
#import "EGOImageView.h"

@interface ActivityCollectionView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *activities;
}

@property (strong, nonatomic) IBOutlet UICollectionView *activityCollection;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
