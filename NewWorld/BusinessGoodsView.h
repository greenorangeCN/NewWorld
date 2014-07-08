//
//  BusinessGoodsView.h
//  NewWorld
//
//  Created by Seven on 14-7-7.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TQImageCache.h"
#import "BusinessGoods.h"
#import "BusinessGoodsCell.h"
#import "Coupons.h"
#import "Goods.h"
#import "EGOImageView.h"
#import "StrikeThroughLabel.h"

@interface BusinessGoodsView : UIViewController<UITableViewDelegate,UITableViewDataSource,IconDownloaderDelegate>
{
    UIWebView *phoneCallWebView;
    NSMutableArray *goods;
    Coupons *coupon;
    TQImageCache * _iconCache;
    MBProgressHUD *hud;
    NSString *orderByStr;
}

@property (strong, nonatomic) Bussiness *store;

@property (strong, nonatomic) IBOutlet UIImageView *couponIv;
@property (strong, nonatomic) IBOutlet UISegmentedControl *orderSegmented;
@property (strong, nonatomic) IBOutlet UITableView *goodsTable;
- (IBAction)segnebtedChangeAction:(id)sender;

//异步加载图片专用
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath;

@end
