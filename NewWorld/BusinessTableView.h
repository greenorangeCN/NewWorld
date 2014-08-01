//
//  BusinessTableView.h
//  NewWorld
//
//  Created by Seven on 14-6-26.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"
#import "BusinessCell.h"
#import "Bussiness.h"
#import "BMapKit.h"
#import "BusinessGoodsView.h"
#import "UITap.h"
#import "StoreMapPointView.h"

@interface BusinessTableView : UIViewController<UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate,UISearchBarDelegate,BMKLocationServiceDelegate>
{
    NSString *keyword;
    BMKMapPoint myPoint;
    NSMutableArray *stores;
    TQImageCache * _iconCache;
    BMKLocationService* _locService;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UITableView *storeTable;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

@end
