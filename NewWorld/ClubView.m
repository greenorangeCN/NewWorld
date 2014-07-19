//
//  ClubView.m
//  NewWorld
//
//  Created by Seven on 14-7-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "ClubView.h"

@interface ClubView ()

@end

@implementation ClubView

@synthesize communityId;
@synthesize clubInfoIv;
@synthesize clubItemTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"名仕会所";
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
    self.clubItemTable.delegate = self;
    self.clubItemTable.dataSource = self;
    self.clubItemTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self reload];
}

//取数方法
- (void)reload
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
        NSString *url = [NSString stringWithFormat:@"%@%@?id=%@", api_base_url, api_community_club, communityId];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           club = [Tool readJsonStrToClub:operation.responseString];
                                           if (club.club_info != nil) {
                                               //图片加载
                                               EGOImageView *picView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic1.png"]];
                                               picView.imageURL = [NSURL URLWithString:club.club_info.thumb];
                                               picView.frame = CGRectMake(0.0f, 0.0f, 320.0f, 170.0f);
                                               [self.clubInfoIv addSubview:picView];
                                           }
                                           if (club.club_items != nil && [club.club_items count] > 0) {
                                               clubItems = club.club_items;
                                               [self.clubItemTable reloadData];
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
    int rowCount = [clubItems count]/3;
    if ([clubItems count]%3 > 0) {
        rowCount += 1;
    }
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 113;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor clearColor];
}

//列表数据渲染
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ClubCell *cell = [tableView dequeueReusableCellWithIdentifier:ClubCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ClubCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[ClubCell class]]) {
                cell = (ClubCell *)o;
                break;
            }
        }
    }
    int rowIndex = [indexPath row];
    if (rowIndex *3 < [clubItems count]) {
        ClubItem *clubItem = [clubItems objectAtIndex:rowIndex *3];
        //图片加载
        EGOImageView *picView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic2.png"]];
        picView.imageURL = [NSURL URLWithString:clubItem.logo];
        picView.frame = CGRectMake(0.0f, 0.0f, 70.0f, 70.0f);
        [cell.pic1Iv addSubview:picView];
        cell.title1Lb.text = clubItem.title;
        
        UITap *clubItemTap = [[UITap alloc] initWithTarget:self action:@selector(clubItemAction:)];
        [cell.pic1Iv addGestureRecognizer:clubItemTap];
        clubItemTap.tag = rowIndex *3;
    }
    if (rowIndex *3 + 1 < [clubItems count]) {
        ClubItem *clubItem = [clubItems objectAtIndex:rowIndex *3 + 1];
        //图片加载
        EGOImageView *picView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic2.png"]];
        picView.imageURL = [NSURL URLWithString:clubItem.logo];
        picView.frame = CGRectMake(0.0f, 0.0f, 70.0f, 70.0f);
        [cell.pic2Iv addSubview:picView];
        cell.title2Lb.text = clubItem.title;
        
        UITap *clubItemTap = [[UITap alloc] initWithTarget:self action:@selector(clubItemAction:)];
        [cell.pic2Iv addGestureRecognizer:clubItemTap];
        clubItemTap.tag = rowIndex *3 + 1;
    }
    if (rowIndex *3 + 2 < [clubItems count]) {
        ClubItem *clubItem = [clubItems objectAtIndex:rowIndex *3 + 2];
        //图片加载
        EGOImageView *picView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic2.png"]];
        picView.imageURL = [NSURL URLWithString:clubItem.logo];
        picView.frame = CGRectMake(0.0f, 0.0f, 70.0f, 70.0f);
        [cell.pic3Iv addSubview:picView];
        cell.title3Lb.text = clubItem.title;
        
        UITap *clubItemTap = [[UITap alloc] initWithTarget:self action:@selector(clubItemAction:)];
        [cell.pic3Iv addGestureRecognizer:clubItemTap];
        clubItemTap.tag = rowIndex *3 + 2;
    }
    return cell;
}

//表格行点击事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)clubItemAction:(id)sender
{
    UITap *tap = (UITap *)sender;
    if (tap) {
        ClubItem *clubItem = [clubItems objectAtIndex:tap.tag];
        ClubDetailView *detailView = [[ClubDetailView alloc] init];
        detailView.item = clubItem;
        [self.navigationController pushViewController:detailView animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    club = nil;
}

@end
