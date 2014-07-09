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
#import "TQImageCache.h"
#import "UITap.h"

@interface HouseTypeCollectionView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, IconDownloaderDelegate>
{
    NSMutableArray *houseTypes;
    TQImageCache * _iconCache;
}

@property (strong, nonatomic) NSString *projectId;

@property (strong, nonatomic) IBOutlet UICollectionView *houseTypeCollection;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

@end
