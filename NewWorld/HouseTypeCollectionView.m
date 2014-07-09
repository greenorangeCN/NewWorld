//
//  HouseTypeCollectionView.m
//  NewWorld
//
//  Created by Seven on 14-7-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "HouseTypeCollectionView.h"

@interface HouseTypeCollectionView ()

@end

@implementation HouseTypeCollectionView

@synthesize projectId;
@synthesize houseTypeCollection;
@synthesize imageDownloadsInProgress;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"户型展示";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
        
        UIButton *lBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        [lBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [lBtn setImage:[UIImage imageNamed:@"cc_back"] forState:UIControlStateNormal];
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithCustomView:lBtn];
        self.navigationItem.leftBarButtonItem = btnBack;
    }
    return self;
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.houseTypeCollection.delegate = self;
    self.houseTypeCollection.dataSource = self;
    [self.houseTypeCollection registerClass:[HouseTypeCollectionCell class] forCellWithReuseIdentifier:HouseTypeCollectionCellIdentifier];

    self.houseTypeCollection.backgroundColor = [Tool getBackgroundColor];
    [self reload];
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

//取数方法
- (void)reload
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSString *url = [NSMutableString stringWithFormat:@"%@%@?c_id=%@", api_base_url, api_housetype_list, projectId];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           houseTypes= [Tool readJsonStrToHouseTypeArray:operation.responseString];
                                           if (houseTypes != nil && [houseTypes count] > 0) {
                                               self.pageControl.numberOfPages = [houseTypes count];
                                           }
                                           [self.houseTypeCollection reloadData];
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
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

//定义展示的UICollectionViewCell的个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [houseTypes count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HouseTypeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:HouseTypeCollectionCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"HouseTypeCollectionCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[HouseTypeCollectionCell class]]) {
                cell = (HouseTypeCollectionCell *)o;
                break;
            }
        }
    }
    int indexRow = [indexPath row];
    HouseType *house = [houseTypes objectAtIndex:indexRow];
    self.pageControl.currentPage = indexRow;
    
    [Tool roundView:cell.bg andCornerRadius:5.0f];
    
    //注册Cell按钮点击事件
    UITap *praiseTap = [[UITap alloc] initWithTarget:self action:@selector(praiseAction:)];
    [cell.praiseBtn addGestureRecognizer:praiseTap];
    praiseTap.tag = indexRow;
    
    UITap *shareTap = [[UITap alloc] initWithTarget:self action:@selector(shareAction:)];
    [cell.shareBtn addGestureRecognizer:shareTap];
    shareTap.tag = indexRow;

    
    cell.titleLb.text = [NSString stringWithFormat:@"%@ %@", house.comm_name, house.title];
    cell.webPriceLb.text = [NSString stringWithFormat:@"网售价：%@万元", house.web_price];
    cell.marketPriceLb.text = [NSString stringWithFormat:@"市场价：%@万元", house.market_price];
    cell.noteTv.text = house.note;
    cell.discountLb.text = [NSString stringWithFormat:@"折扣：%@", house.discount];
    cell.unitPriceLb.text = [NSString stringWithFormat:@"单价：%@元/m2", house.unit_price];
    cell.areaLb.text = [NSString stringWithFormat:@"面积：%@m2", house.area];
    cell.houseTypeLb.text = [NSString stringWithFormat:@"户型：%@", house.house_type];

    cell.praiseBtn.titleLabel.text = [NSString stringWithFormat:@"( %@ )", house.points];
    
    //图片显示及缓存
    if (house.imgData) {
        cell.imageIv.image = house.imgData;
    }
    else
    {
        if ([house.thumb isEqualToString:@""]) {
            house.imgData = [UIImage imageNamed:@"loadingpic2.png"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:house.thumb]];
            if (imageData) {
                house.imgData = [UIImage imageWithData:imageData];
                cell.imageIv.image = house.imgData;
            }
            else
            {
                IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    NSString *urlStr = house.thumb;
                    record.url = urlStr;
                    [self startIconDownload:record forIndexPath:indexPath];
                }
            }
        }
    }
    
    return cell;
}

- (void)praiseAction:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        HouseType *house = [houseTypes objectAtIndex:tap.tag];
        NSString *detailUrl = [NSString stringWithFormat:@"%@%@?model=HouseType&id=%@", api_base_url, api_praise, house.id];
        NSURL *url = [ NSURL URLWithString : detailUrl];
        // 构造 ASIHTTPRequest 对象
        ASIHTTPRequest *request = [ ASIHTTPRequest requestWithURL :url];
        // 开始同步请求
        [request startSynchronous ];
        NSError *error = [request error ];
        assert (!error);
        // 如果请求成功，返回 Response
        NSString *response = [request responseString ];
        NSData *data = [response dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSString *status = @"0";
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
        if (json) {
            status = [json objectForKey:@"status"];
            if ([status isEqualToString:@"1"]) {
                house.points = [NSString stringWithFormat:@"%d", [house.points intValue] + 1];
                [self.houseTypeCollection reloadData];
            }
        }
    }
}

- (void)shareAction:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(320, 504);
}

//定义每个UICollectionView 的 margin
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    HousesProject *project = [projects objectAtIndex:[indexPath row]];
//    ProjectIntroView *projectIntro = [[ProjectIntroView alloc] init];
//    projectIntro.project = project;
//    [self.navigationController pushViewController:projectIntro animated:YES];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
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
        if (_index >= [houseTypes count]) {
            return;
        }
        HouseType *houseType = [houseTypes objectAtIndex:[index intValue]];
        if (houseType) {
            houseType.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(houseType.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:houseType.thumb]];
            [self.houseTypeCollection reloadData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
