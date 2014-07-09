//
//  BusinessGoodsView.m
//  NewWorld
//
//  Created by Seven on 14-7-7.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "BusinessGoodsView.h"

@interface BusinessGoodsView ()

@end

@implementation BusinessGoodsView

@synthesize store;
@synthesize couponIv;
@synthesize orderSegmented;
@synthesize goodsTable;
@synthesize imageDownloadsInProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [lBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [lBtn setImage:[UIImage imageNamed:@"cc_back"] forState:UIControlStateNormal];
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
        self.navigationItem.leftBarButtonItem = btnBack;
        
        UIButton *rBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, 25)];
        [rBtn addTarget:self action:@selector(telAction) forControlEvents:UIControlEventTouchUpInside];
        [rBtn setImage:[UIImage imageNamed:@"top_tel"] forState:UIControlStateNormal];
        UIBarButtonItem *btnTel = [[UIBarButtonItem alloc]initWithCustomView:rBtn];
        self.navigationItem.rightBarButtonItem = btnTel;
    }
    return self;
}

- (void)telAction
{
    NSURL *phoneUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", store.phone]];
    if (!phoneCallWebView) {
        phoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
    }
    [phoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneUrl]];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [Tool getBackgroundColor];
    orderByStr = @"id";
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = store.name;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
    self.goodsTable.delegate = self;
    self.goodsTable.dataSource = self;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.goodsTable.backgroundColor = [Tool getBackgroundColor];
    goods = [[NSMutableArray alloc] init];
    //    设置无分割线
    self.goodsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self reload];
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (Goods *g in goods) {
        g.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setGoodsTable:nil];
    [goods removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    goods = nil;
    _iconCache = nil;
    [super viewDidUnload];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}

- (void)clear
{
    [goods removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
}

//取数方法
- (void)reload
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
        NSMutableString *urlTemp = [NSMutableString stringWithFormat:@"%@%@?id=%@&orderby=%@", api_base_url, api_goods_list, store.id, orderByStr];
        NSString *url = [[NSString stringWithString:urlTemp] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [self clear];
                                       @try {
                                           BusinessGoods *businessGoods = [Tool readJsonStrBusinessGoods:operation.responseString];
                                           
                                           if (coupon == nil) {
                                               if (businessGoods.coupons != nil && [businessGoods.coupons count] > 0) {
                                                   coupon = [businessGoods.coupons objectAtIndex:0];
                                                   EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic1.png"]];
                                                       imageView.imageURL = [NSURL URLWithString:coupon.thumb];
                                                   imageView.frame = CGRectMake(0.0f, 0.0f, 310.0f, 103.0f);
                                                   [self.couponIv addSubview:imageView];
                                                   [Tool roundView:self.couponIv andCornerRadius:5.0f];
                                               }
                                           }
                                           
                                           goods = businessGoods.goodlist;
                                           if (goods != nil) {
                                               [self.goodsTable reloadData];
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           if (hud != nil) {
                                               [hud hide:YES];
                                           }
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [goods count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 98;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getBackgroundColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BusinessGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:BusinessGoodsCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BusinessGoodsCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[BusinessGoodsCell class]]) {
                cell = (BusinessGoodsCell *)o;
                break;
            }
        }
    }
    Goods *good = [goods objectAtIndex:[indexPath row]];
    cell.titleLb.text = good.title;
    cell.priceLb.text = [NSString stringWithFormat:@"￥%@", good.price];
    cell.buysLb.text = [NSString stringWithFormat:@"已售%@", good.buys];
    
    StrikeThroughLabel *slabel = [[StrikeThroughLabel alloc] initWithFrame:CGRectMake(207, 70, 63, 21)];
    slabel.text = [NSString stringWithFormat:@"￥%@", good.market_price];
    slabel.font = [UIFont italicSystemFontOfSize:12.0f];
    slabel.strikeThroughEnabled = YES;
    [cell addSubview:slabel];
    
    [Tool roundView:cell.bg andCornerRadius:5.0f];
    
    //图片显示及缓存
    if (good.imgData) {
        cell.picIv.image = good.imgData;
    }
    else
    {
        if ([good.thumb isEqualToString:@""]) {
            good.imgData = [UIImage imageNamed:@"loadingpic2.png"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:good.thumb]];
            if (imageData) {
                good.imgData = [UIImage imageWithData:imageData];
                cell.picIv.image = good.imgData;
            }
            else
            {
                IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    NSString *urlStr = good.thumb;
                    record.url = urlStr;
                    [self startIconDownload:record forIndexPath:indexPath];
                }
            }
        }
    }
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    Goods *good = [goods objectAtIndex:row];
    if (good)
    {
        GoodsDetailView *goodsDetailView = [[GoodsDetailView alloc] init];
        goodsDetailView.goodsId = good.id;
        [self.navigationController pushViewController:goodsDetailView animated:YES];
    }
    
}

#pragma 下载图片
- (void)startIconDownload:(ImgRecord *)imgRecord forIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [NSString stringWithFormat:@"%d",[indexPath row]];
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:key];
    if (iconDownloader == nil) {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.imgRecord = imgRecord;
        iconDownloader.index = key;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:key];
        [iconDownloader startDownload];
    }
}
- (void)appImageDidLoad:(NSString *)index
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:index];
    if (iconDownloader)
    {
        int _index = [index intValue];
        if (_index >= [goods count]) {
            return;
        }
        Goods *good = [goods objectAtIndex:[index intValue]];
        if (good) {
            good.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(good.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:good.thumb]];
            [self.goodsTable reloadData];
        }
    }
}

- (IBAction)segnebtedChangeAction:(id)sender {
    switch (self.orderSegmented.selectedSegmentIndex) {
        case 0:
            orderByStr = @"id";
            break;
        case 1:
            orderByStr = @"buys";
            break;
        case 2:
            orderByStr = @"price";
            break;
    }
    [self reload];
}
@end
