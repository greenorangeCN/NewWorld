//
//  ActivityTableView.h
//  NewWorld
//
//  Created by Seven on 14-6-26.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"
#import "ActivityCell.h"

@interface ActivityTableView : UIViewController<UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,EGORefreshTableHeaderDelegate,UISearchBarDelegate>
{
    NSMutableArray *activities;
    
    BOOL isLoadOver;
    BOOL isLoading;
    int allCount;
    NSString *keyword;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
    BOOL _reloading;
    
    BOOL isInitialize;
    TQImageCache * _iconCache;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *activityTable;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

//重新加载
- (void)reload:(BOOL)noRefresh;
@property int catalog;

//下拉刷新
- (void)clear;
- (void)refresh;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
