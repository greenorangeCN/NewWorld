//
//  ActivityCollectionView.m
//  NewWorld
//
//  Created by Seven on 14-7-9.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ActivityCollectionView.h"

@interface ActivityCollectionView ()

@end

@implementation ActivityCollectionView

@synthesize activityCollection;
@synthesize pageControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"最新活动";
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
    self.activityCollection.delegate = self;
    self.activityCollection.dataSource = self;
    if (IS_IPHONE_5) {
        [self.activityCollection registerClass:[ActivityCollectionCell class] forCellWithReuseIdentifier:ActivityCollectionCellIdentifier];
    }
    else
    {
        [self.activityCollection registerClass:[Activity_35CollectionCell class] forCellWithReuseIdentifier:Activity_35CollectionCellIdentifier];
    }
    
    self.activityCollection.backgroundColor = [Tool getBackgroundColor];
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
        NSString *url = [NSMutableString stringWithFormat:@"%@%@?p=%d", api_base_url, api_activities, 1];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           NSMutableArray *activitiesPage = [Tool readJsonStrToActivitiesArray:operation.responseString];
                                           if (activitiesPage != nil && [activitiesPage count] > 0) {
//                                               activities = [activitiesPage ]
                                               int endIndex = 0;
                                               if ([activitiesPage count] >= 5) {
                                                   endIndex = 5;
                                               }
                                               else
                                               {
                                                   endIndex = [activitiesPage count] -1;
                                               }
                                               activities = [activitiesPage objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, endIndex)]];
                                               self.pageControl.numberOfPages = [activities count];
                                           }
                                           [self.activityCollection reloadData];
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
    return [activities count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        ActivityCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ActivityCollectionCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ActivityCollectionCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[ActivityCollectionCell class]]) {
                    cell = (ActivityCollectionCell *)o;
                    break;
                }
            }
        }
        int indexRow = [indexPath row];
        Activity *activity = [activities objectAtIndex:indexRow];
        self.pageControl.currentPage = indexRow;
        
        [Tool roundView:cell.bg andCornerRadius:5.0f];
        
        //注册Cell按钮点击事件
        UITap *praiseTap = [[UITap alloc] initWithTarget:self action:@selector(praiseAction:)];
        [cell.praiseBtn addGestureRecognizer:praiseTap];
        praiseTap.tag = indexRow;
        
        [cell.shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareBtn.tag = indexRow;
        
        cell.titleLb.text = activity.title;
        cell.dateLb.text = [NSString stringWithFormat:@"活动时间：%@", activity.validityTime];
        cell.conditionLb.text = [NSString stringWithFormat:@"活动资格：%@", activity.condition];
        cell.telephoneLb.text = [NSString stringWithFormat:@"咨询电话：%@", activity.telephone];
        cell.qqLb.text = [NSString stringWithFormat:@"咨询QQ：%@", activity.qq];
        cell.praiseBtn.titleLabel.text = [NSString stringWithFormat:@"( %@ )", activity.points];
        
        EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic4.png"]];
        imageView.imageURL = [NSURL URLWithString:activity.thumb];
        imageView.frame = CGRectMake(0.0f, 0.0f, 300.0f, 209.0f);
        [cell.imageIv addSubview:imageView];
        return cell;
    }
    else
    {
        Activity_35CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Activity_35CollectionCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Activity_35CollectionCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[Activity_35CollectionCell class]]) {
                    cell = (Activity_35CollectionCell *)o;
                    break;
                }
            }
        }
        int indexRow = [indexPath row];
        Activity *activity = [activities objectAtIndex:indexRow];
        self.pageControl.currentPage = indexRow;
        
        [Tool roundView:cell.bg andCornerRadius:5.0f];
        
        //注册Cell按钮点击事件
        UITap *praiseTap = [[UITap alloc] initWithTarget:self action:@selector(praiseAction:)];
        [cell.praiseBtn addGestureRecognizer:praiseTap];
        praiseTap.tag = indexRow;
        
        [cell.shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareBtn.tag = indexRow;
        
        cell.titleLb.text = activity.title;
        cell.dateLb.text = [NSString stringWithFormat:@"活动时间：%@", activity.validityTime];
        cell.conditionLb.text = [NSString stringWithFormat:@"活动资格：%@", activity.condition];
        cell.telephoneLb.text = [NSString stringWithFormat:@"咨询电话：%@", activity.telephone];
        cell.qqLb.text = [NSString stringWithFormat:@"咨询QQ：%@", activity.qq];
        cell.praiseBtn.titleLabel.text = [NSString stringWithFormat:@"( %@ )", activity.points];
        
        EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic4.png"]];
        imageView.imageURL = [NSURL URLWithString:activity.thumb];
        imageView.frame = CGRectMake(0.0f, 0.0f, 300.0f, 209.0f);
        [cell.imageIv addSubview:imageView];
        return cell;
    }
}

- (void)praiseAction:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        Activity *activity = [activities objectAtIndex:tap.tag];
        NSString *detailUrl = [NSString stringWithFormat:@"%@%@?model=Activities&id=%@", api_base_url, api_praise, activity._id];
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
                activity.points = [NSString stringWithFormat:@"%d", [activity.points intValue] + 1];
                [self.activityCollection reloadData];
            }
        }
    }
}

- (void)shareAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        Activity *activity = [activities objectAtIndex:tap.tag];
        NSDictionary *contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    activity.title , @"title",
                                    activity.summary, @"summary",
                                    activity.thumb, @"thumb",
                                    nil];
        [Tool shareAction:sender andShowView:self.view andContent:contentDic];
    }
}

#pragma mark --UICollectionViewDelegateFlowLayout
//定义每个UICollectionView 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (IS_IPHONE_5) {
        return CGSizeMake(320, 504);
    }
    else
    {
        return CGSizeMake(320, 416);
    }
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
    Activity *activity = [activities objectAtIndex:[indexPath row]];
    if (activity)
    {
        ActivityDetailView *activityDetail = [[ActivityDetailView alloc] init];
        activityDetail.activity = activity;
        activityDetail.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:activityDetail animated:YES];
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    //清空
    for (Activity *a in activities) {
        a.imgData = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidUnload {
    [self setActivityCollection:nil];
    [activities removeAllObjects];
    activities = nil;
    [super viewDidUnload];
}

@end
