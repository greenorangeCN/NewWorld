//
//  BusinessTableView.m
//  NewWorld
//
//  Created by Seven on 14-6-26.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "BusinessTableView.h"

@interface BusinessTableView ()

@end

@implementation BusinessTableView

@synthesize searchBar;
@synthesize storeTable;
@synthesize imageDownloadsInProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"tab_shop"];
        self.tabBarItem.title = @"商家服务";
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"商家服务";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在定位" andView:self.view andHUD:hud];
    //初始化定位次数（定位成功后才刷新列表数据）
    updateTime = 0;
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    [self startLocation];
    self.searchBar.delegate = self;
    [self.searchBar setShowsCancelButton:NO animated:YES];
    if ([[[UIDevice currentDevice]systemVersion]floatValue] >=7) {
        UIButton *cancelButton;
        UIView *topView = searchBar.subviews[0];
        for (UIView *subView in topView.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UINavigationButton")]) {
                cancelButton = (UIButton*)subView;
            }
        }
        if (cancelButton) {
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    } else{
        UIButton *cancelButton = nil;
        for (UIView *subView in self.searchDisplayController.searchBar.subviews) {
            if ([subView isKindOfClass:[UIButton class]]) {
                cancelButton = (UIButton*)subView;
            }
        }
        if (cancelButton){
            [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
            [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
    
    self.storeTable.delegate = self;
    self.storeTable.dataSource = self;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.storeTable.backgroundColor = [Tool getBackgroundColor];
    stores = [[NSMutableArray alloc] init];
    //    设置无分割线
    self.storeTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //点击隐藏软键盘
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
}

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    [self.searchBar resignFirstResponder];
    if ([keyword length] == 0) {
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (Bussiness *s in stores) {
        s.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setStoreTable:nil];
    [stores removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    stores = nil;
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
    [stores removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
}

//数组排序
-(void)startArraySort:(NSString *)keystring isAscending:(BOOL)isAscending
{
    NSSortDescriptor* sortByA = [NSSortDescriptor sortDescriptorWithKey:keystring ascending:isAscending];
    stores = [[NSMutableArray alloc]initWithArray:[stores sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByA]]];
}

//取数方法
- (void)reload
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
        NSMutableString *urlTemp = [NSMutableString stringWithFormat:@"%@%@", api_base_url, api_stores];
        if (keyword != nil && [keyword length] > 0) {
            [urlTemp appendString:[NSString stringWithFormat:@"?name=%@", keyword]];
        }
        NSString *url = [[NSString stringWithString:urlTemp] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       [self clear];
                                       @try {
                                           stores = [Tool readJsonStrToStoreArray:operation.responseString];
                                           
                                           //计算当前位置与商家距离
                                           for (int i = 0; i < [stores count]; i++) {
                                               Bussiness *temp =[stores objectAtIndex:(i)];
                                               CLLocationCoordinate2D coor;
                                               coor.longitude = [temp.longitude doubleValue];
                                               coor.latitude = [temp.latitude doubleValue];
                                               BMKMapPoint shopPoint = BMKMapPointForCoordinate(coor);
                                               CLLocationDistance distanceTmp = BMKMetersBetweenMapPoints(myPoint,shopPoint);
                                               temp.distance =(int)distanceTmp;
                                           }
                                           
                                           [self startArraySort:@"distance" isAscending:YES];
                                           [self.storeTable reloadData];
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
    return [stores count];
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
    
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:BusinessCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"BusinessCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[BusinessCell class]]) {
                cell = (BusinessCell *)o;
                break;
            }
        }
    }
    Bussiness *store = [stores objectAtIndex:[indexPath row]];
    cell.nameLb.text = store.name;
    NSString *summary = store.summary ;
    if ([summary length] > 30) {
        summary = [NSString stringWithFormat:@"%@...", [summary substringToIndex:30]];
    }
    cell.summaryTv.text = summary;
    
    if (store.distance > 1000) {
        float disf = ((float)store.distance)/1000;
        cell.distanceLb.text = [NSString stringWithFormat:@"距您%.2f千米", disf];
    }
    else
    {
        cell.distanceLb.text = [NSString stringWithFormat:@"距您%d米", store.distance];
    }
    
    [Tool roundView:cell.bg andCornerRadius:5.0f];
    
    //图片显示及缓存
    if (store.imgData) {
        cell.picIv.image = store.imgData;
    }
    else
    {
        if ([store.logo isEqualToString:@""]) {
            store.imgData = [UIImage imageNamed:@"tg-nopic.jpg"];
        }
        else
        {
            NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:store.logo]];
            if (imageData) {
                store.imgData = [UIImage imageWithData:imageData];
                cell.picIv.image = store.imgData;
            }
            else
            {
                IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                if (downloader == nil) {
                    ImgRecord *record = [ImgRecord new];
                    NSString *urlStr = store.logo;
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
    Bussiness *stroe = [stores objectAtIndex:row];
    if (stroe)
    {
        //            CompanyView *companyView = [[CompanyView alloc] init];
        //            companyView.shop = business;
        //            [self.navigationController pushViewController:companyView animated:YES];
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
        if (_index >= [stores count]) {
            return;
        }
        Bussiness *store = [stores objectAtIndex:[index intValue]];
        if (store) {
            store.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(store.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:store.logo]];
            [self.storeTable reloadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    _locService.delegate = self;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _locService.delegate = nil;
}

-(void)startLocation
{
    NSLog(@"进入定位");
    [_locService startUserLocationService];
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
	NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{

}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    CLLocationCoordinate2D mycoord = userLocation.location.coordinate;
    myPoint = BMKMapPointForCoordinate(mycoord);
    if(updateTime == 0)
    {
        [self reload];
    }
    updateTime ++;
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
}

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self.searchBar resignFirstResponder];// 放弃第一响应者
    keyword = searchBar.text;
    [self reload];
}

//编辑代理(完成编辑触发)
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];// 放弃第一响应者
    keyword = @"";
    [self reload];
}
@end
