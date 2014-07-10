//
//  HouseTypeCollectionView.h
//  NewWorld
//
//  Created by Seven on 14-7-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HouseType.h"
#import "HouseTypeCollectionCell.h"
#import "UITap.h"
#import "EGOImageView.h"

@interface HouseTypeCollectionView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *houseTypes;
}

@property (strong, nonatomic) NSString *projectId;

@property (strong, nonatomic) IBOutlet UICollectionView *houseTypeCollection;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

@end
