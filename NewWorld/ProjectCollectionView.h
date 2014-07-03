//
//  ProjectCollectionView.h
//  NewWorld
//
//  Created by Seven on 14-7-3.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectCollectionCell.h"
#import "HousesProject.h"
#import "TQImageCache.h"

@interface ProjectCollectionView : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, IconDownloaderDelegate>
{
    NSMutableArray *projects;
    TQImageCache * _iconCache;
}

@property (strong, nonatomic) IBOutlet UICollectionView *projectCollection;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

@end
