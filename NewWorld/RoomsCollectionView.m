//
//  RoomsCollectionView.m
//  NewWorld
//
//  Created by Seven on 14-7-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RoomsCollectionView.h"

@interface RoomsCollectionView ()

@end

@implementation RoomsCollectionView

@synthesize projectId;
@synthesize projectName;
@synthesize roomsCollection;
@synthesize pageControl;
@synthesize photos = _photos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"在线看房";
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
    self.roomsCollection.delegate = self;
    self.roomsCollection.dataSource = self;
    //注册CELL类
    if (IS_IPHONE_5) {
        [self.roomsCollection registerClass:[RoomsCollectionCell class] forCellWithReuseIdentifier:RoomsCollectionCellIdentifier];
    }
    else
    {
        [self.roomsCollection registerClass:[Rooms_35CollectionCell class] forCellWithReuseIdentifier:Rooms_35CollectionCellIdentifier];
    }
    
    
    self.roomsCollection.backgroundColor = [Tool getBackgroundColor];
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
        NSString *url = [NSMutableString stringWithFormat:@"%@%@?cid=%@", api_base_url, api_rooms_list, projectId];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           rooms = [Tool readJsonStrToRoomsArray:operation.responseString];
                                           if (rooms != nil && [rooms count] > 0) {
                                               self.pageControl.numberOfPages = [rooms count];
                                               [self.roomsCollection reloadData];
                                           }    
                                           else
                                           {
                                               self.pageControl.numberOfPages = 0;
                                               UILabel *noDataLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height/2-100, 320, 44)];
                                               noDataLabel.font = [UIFont boldSystemFontOfSize:18];
                                               noDataLabel.text = @"暂无数据";
                                               noDataLabel.textColor = [UIColor blackColor];
                                               noDataLabel.backgroundColor = [UIColor clearColor];
                                               noDataLabel.textAlignment = UITextAlignmentCenter;
                                               [self.view addSubview:noDataLabel];
                                           }
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
    return [rooms count];
}

//定义展示的Section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个UICollectionView展示的内容
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    int indexRow = [indexPath row];
    Rooms *room = [rooms objectAtIndex:indexRow];
    self.pageControl.currentPage = indexRow;
    if (IS_IPHONE_5) {
        RoomsCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:RoomsCollectionCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"RoomsCollectionCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[RoomsCollectionCell class]]) {
                    cell = (RoomsCollectionCell *)o;
                    break;
                }
            }
        }
        [Tool roundView:cell.bg andCornerRadius:5.0f];
        
        //注册Cell按钮点击事件
        UITap *praiseTap = [[UITap alloc] initWithTarget:self action:@selector(praiseAction:)];
        [cell.praiseBtn addGestureRecognizer:praiseTap];
        praiseTap.tag = indexRow;
        
        [cell.shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareBtn.tag = indexRow;
        
        cell.titleLb.text = [NSString stringWithFormat:@"%@：%@", projectName, room.title];
        cell.introTv.text = room.intro;
        
        cell.praiseBtn.titleLabel.text = [NSString stringWithFormat:@"( %@ )", room.points];
        
        EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic4.png"]];
        imageView.imageURL = [NSURL URLWithString:room.thumb];
        imageView.frame = CGRectMake(0.0f, 0.0f, 300.0f, 304.0f);
        [cell.imageIv addSubview:imageView];
        
        return cell;
    }
    else
    {
        Rooms_35CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Rooms_35CollectionCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"Rooms_35CollectionCell" owner:self options:nil];
            for (NSObject *o in objects) {
                if ([o isKindOfClass:[Rooms_35CollectionCell class]]) {
                    cell = (Rooms_35CollectionCell *)o;
                    break;
                }
            }
        }
        [Tool roundView:cell.bg andCornerRadius:5.0f];
        
        //注册Cell按钮点击事件
        UITap *praiseTap = [[UITap alloc] initWithTarget:self action:@selector(praiseAction:)];
        [cell.praiseBtn addGestureRecognizer:praiseTap];
        praiseTap.tag = indexRow;
        
        [cell.shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareBtn.tag = indexRow;
        
        cell.titleLb.text = [NSString stringWithFormat:@"%@：%@", projectName, room.title];
        cell.introTv.text = room.intro;
        
        cell.praiseBtn.titleLabel.text = [NSString stringWithFormat:@"( %@ )", room.points];
        
        EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic4.png"]];
        imageView.imageURL = [NSURL URLWithString:room.thumb];
        imageView.frame = CGRectMake(0.0f, 0.0f, 241.0f, 229);
        [cell.imageIv addSubview:imageView];
        
        return cell;
    }
}

- (void)praiseAction:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        HouseType *house = [rooms objectAtIndex:tap.tag];
        NSString *detailUrl = [NSString stringWithFormat:@"%@%@?model=Rooms&id=%@", api_base_url, api_praise, house.id];
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
                [self.roomsCollection reloadData];
            }
        }
    }
}

- (void)shareAction:(id)sender
{
    UIButton *tap = (UIButton *)sender;
    if (tap) {
        Rooms *room = [rooms objectAtIndex:tap.tag];
        NSDictionary *contentDic = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSString stringWithFormat:@"%@：%@", projectName, room.title], @"title",
                                    room.intro, @"summary",
                                    room.thumb, @"thumb",
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
    Rooms *room = [rooms objectAtIndex:[indexPath row]];
    if (room) {
        if (room.images && [room.images count] > 0) {
            NSMutableArray *photos = [[NSMutableArray alloc] init];
            for (NSString *imageUrl in room.images) {
                [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageUrl]]];
            }
            self.photos = photos;
            MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
            browser.displayActionButton = YES;
            self.navigationController.navigationBar.hidden = NO;
            [self.navigationController pushViewController:browser animated:YES];
        }
    }
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)viewDidUnload {
    [self setRoomsCollection:nil];
    [rooms removeAllObjects];
    rooms = nil;
    [super viewDidUnload];
}

//MWPhotoBrowserDelegate委托事件
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

@end
