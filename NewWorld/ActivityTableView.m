//
//  ActivityTableView.m
//  NewWorld
//
//  Created by Seven on 14-6-26.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ActivityTableView.h"

@interface ActivityTableView ()

@end

@implementation ActivityTableView

@synthesize searchBar;
@synthesize activityTable;
@synthesize imageDownloadsInProgress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"tab_activity"];
        self.tabBarItem.title = @"活动";
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"活动信息";
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
    [self.view setBackgroundColor:[Tool getBackgroundColor]];
    [self.activityTable setBackgroundColor:[Tool getBackgroundColor]];
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
    
    allCount = 0;
    //添加的代码
    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, -320.0f, self.view.frame.size.width, 320)];
        view.delegate = self;
        [self.activityTable addSubview:view];
        _refreshHeaderView = view;
    }
    [_refreshHeaderView refreshLastUpdatedDate];
    self.activityTable.delegate = self;
    self.activityTable.dataSource = self;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.activityTable.backgroundColor = [Tool getBackgroundColor];
    activities = [[NSMutableArray alloc] initWithCapacity:20];
    [self reload:YES];
    //    设置无分割线
    self.activityTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //适配iOS7uinavigationbar遮挡tableView的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)doneManualRefresh
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:self.activityTable];
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:self.activityTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    //清空
    for (Activity *a in activities) {
        a.imgData = nil;
    }
}

- (void)viewDidUnload {
    [self setActivityTable:nil];
    _refreshHeaderView = nil;
    [activities removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    activities = nil;
    _iconCache = nil;
    [super viewDidUnload];
}

- (void)clear
{
    allCount = 0;
    [activities removeAllObjects];
    [imageDownloadsInProgress removeAllObjects];
    isLoadOver = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (self.imageDownloadsInProgress != nil) {
        NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
        [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    }
}

//取数方法
- (void)reload:(BOOL)noRefresh
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoading || isLoadOver) {
            return;
        }
        if (!noRefresh) {
            allCount = 0;
        }
        int pageIndex = allCount/20 + 1;
        NSString *url = [NSString stringWithFormat:@"%@%@?p=%d", api_base_url, api_activities, pageIndex];
        
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       isLoading = NO;
                                       if (!noRefresh) {
                                           [self clear];
                                       }
                                       
                                       @try {
                                           NSMutableArray *newActivities = [Tool readJsonStrToActivitiesArray:operation.responseString];
                                           int count = [newActivities count];
                                           allCount += count;
                                           if (count < 20)
                                           {
                                               isLoadOver = YES;
                                           }
                                           [activities addObjectsFromArray:newActivities];
                                           [self.activityTable reloadData];
                                           [self doneLoadingTableViewData];
                                           
                                           //如果是第一页 则缓存下来
                                           if (activities.count <= 20) {
                                               [Tool saveCache:@"activityList" andType:1 andID:self.catalog andString:operation.responseString];
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           [self doneLoadingTableViewData];
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       //如果是刷新
                                       [self doneLoadingTableViewData];
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       isLoading = NO;
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
        isLoading = YES;
        [self.activityTable reloadData];
    }
    //如果没有网络连接
    else
    {
        NSString *value = [Tool getCache:@"activityList" andType:1 andID:self.catalog];
        if (value) {
            NSMutableArray *activityNews = [Tool readJsonStrToActivitiesArray:value];
            [self.activityTable reloadData];
            isLoadOver = YES;
            [activities addObjectsFromArray:activityNews];
            [self.activityTable reloadData];
            [self doneLoadingTableViewData];
        }
    }
}

#pragma TableView的处理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([UserModel Instance].isNetworkRunning) {
        if (isLoadOver) {
            return activities.count == 0 ? 1 : activities.count;
        }
        else
            return activities.count + 1;
    }
    else
        return activities.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 98;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[Tool getBackgroundColor]];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([activities count] > 0) {
        if ([indexPath row] < [activities count])
        {
            ActivityCell *cell = [tableView dequeueReusableCellWithIdentifier:ActivityCellIdentifier];
            if (!cell) {
                NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ActivityCell" owner:self options:nil];
                for (NSObject *o in objects) {
                    if ([o isKindOfClass:[ActivityCell class]]) {
                        cell = (ActivityCell *)o;
                        break;
                    }
                }
            }
            Activity *activity = [activities objectAtIndex:[indexPath row]];
            cell.titleLb.text = activity.title;
            NSString *summary = activity.summary ;
            if ([summary length] > 45) {
                summary = [NSString stringWithFormat:@"%@...", [summary substringToIndex:45]];
            }
            cell.summaryTv.text = summary;
            cell.dateLb.text = [Tool TimestampToDateStr:activity.published andFormatterStr:@"yyyy-MM-dd"];
            [Tool roundView:cell.bg andCornerRadius:5.0f];
            
            //图片显示及缓存
            if (activity.imgData) {
                cell.picIv.image = activity.imgData;
            }
            else
            {
                if ([activity.thumb isEqualToString:@""]) {
                    activity.imgData = [UIImage imageNamed:@"tg-nopic.jpg"];
                }
                else
                {
                    NSData * imageData = [_iconCache getImage:[TQImageCache parseUrlForCacheName:activity.thumb]];
                    if (imageData) {
                        activity.imgData = [UIImage imageWithData:imageData];
                        cell.picIv.image = activity.imgData;
                    }
                    else
                    {
                        IconDownloader *downloader = [imageDownloadsInProgress objectForKey:[NSString stringWithFormat:@"%d", [indexPath row]]];
                        if (downloader == nil) {
                            ImgRecord *record = [ImgRecord new];
                            NSString *urlStr = activity.thumb;
                            record.url = urlStr;
                            [self startIconDownload:record forIndexPath:indexPath];
                        }
                    }
                }
            }
            return cell;
        }
        else
        {
            return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部信息" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
        }
    }
    else
    {
        return [[DataSingleton Instance] getLoadMoreCell:tableView andIsLoadOver:isLoadOver andLoadOverString:@"已经加载全部信息" andLoadingString:(isLoading ? loadingTip : loadNext20Tip) andIsLoading:isLoading];
    }
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int row = [indexPath row];
    if (row >= [activities count]) {
        if (!isLoading) {
            [self performSelector:@selector(reload:)];
        }
    }
    else {
        Activity *activity = [activities objectAtIndex:row];
        if (activity)
        {
//            CCActivityDetailView *activityDetail = [[CCActivityDetailView alloc] init];
//            activityDetail.activity = activity;
//            activityDetail.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:activityDetail animated:YES];
        }
    }
}

#pragma 下提刷新
- (void)reloadTableViewDataSource
{
    _reloading = YES;
}
- (void)doneLoadingTableViewData
{
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.activityTable];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self reloadTableViewDataSource];
    [self refresh];
}
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return _reloading;
}
- (NSDate *)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
    return [NSDate date];
}

- (void)refresh
{
    if ([UserModel Instance].isNetworkRunning) {
        isLoadOver = NO;
        [self reload:NO];
    }
    //无网络连接则读取缓存
    else {
        NSString *value = [Tool getCache:@"activityList" andType:1 andID:self.catalog];
        if (value)
        {
            NSMutableArray *activityNews = [Tool readJsonStrToActivitiesArray:value];
            if (activityNews == nil) {
                [self.activityTable reloadData];
            }
            else if(activityNews.count <= 0){
                [self.activityTable reloadData];
                isLoadOver = YES;
            }
            else if(activityNews.count < 20){
                isLoadOver = YES;
            }
            [activities addObjectsFromArray:activityNews];
            [self.activityTable reloadData];
            [self doneLoadingTableViewData];
        }
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
        if (_index >= [activities count]) {
            return;
        }
        Activity *activity = [activities objectAtIndex:[index intValue]];
        if (activity) {
            activity.imgData = iconDownloader.imgRecord.img;
            // cache it
            NSData * imageData = UIImagePNGRepresentation(activity.imgData);
            [_iconCache putImage:imageData withName:[TQImageCache parseUrlForCacheName:activity.thumb]];
            [self.activityTable reloadData];
        }
    }
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self.searchBar setShowsCancelButton:YES animated:YES];
    
}
    

// 键盘中，搜索按钮被按下，执行的方法
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"---%@",searchBar.text);
//    [self.searchBar resignFirstResponder];// 放弃第一响应者
    
}

//编辑代理(完成编辑触发)
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
//    [self.searchBar setShowsCancelButton:NO animated:YES];
//    searchBar.text = @"";
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [self.searchBar resignFirstResponder];// 放弃第一响应者
}

@end
