//
//  MyOrderTableView.m
//  NewWorld
//
//  Created by Seven on 14-7-22.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "MyOrderTableView.h"

@interface MyOrderTableView ()

@end

@implementation MyOrderTableView

@synthesize myOrderTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"我的送货单";
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
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.myOrderTable.delegate = self;
    self.myOrderTable.dataSource = self;
    self.myOrderTable.backgroundColor = [Tool getBackgroundColor];
    self.myOrderTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self reload];
}

//取数方法
- (void)reload
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
        NSString *url = [NSMutableString stringWithFormat:@"%@%@?username=%@", api_base_url, api_myorder, [[UserModel Instance] getUserValueForKey:@"username"]];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           myOrders = [Tool readJsonStrToMyOrderArray:operation.responseString];
                                           [self.myOrderTable reloadData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [myOrders count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 112;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getBackgroundColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:MyOrderCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyOrderCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[MyOrderCell class]]) {
                cell = (MyOrderCell *)o;
            }
        }
    }
    MyOrder *order = [myOrders objectAtIndex:[indexPath row]];
    
    EGOImageView *egoImage = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic2.png"]];
    egoImage.imageURL = [NSURL URLWithString:order.thumb];
    egoImage.frame = CGRectMake(0, 0, 119, 76);
    [cell.picIv addSubview:egoImage];
    
    cell.titleLb.text = [NSString stringWithFormat:@"%@-￥%@", order.title, order.price];
    cell.quantityLb.text = [NSString stringWithFormat:@"送货数量：%@", order.quantity];
    cell.storeNameLb.text = [NSString stringWithFormat:@"%@负责配送", order.store_name];
    cell.storePhoneLb.text = [NSString stringWithFormat:@"联系电话：%@", order.phone];
    NSString *addTime =order.addtime;
    if ([addTime length] >= 16) {
        addTime = [addTime substringToIndex:16];
    }
    cell.addTimeLb.text = addTime;
    
    [Tool roundView:cell.bgLb andCornerRadius:5.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [myOrders removeAllObjects];
    myOrders = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setMyOrderTable:nil];
    [myOrders removeAllObjects];
    myOrders = nil;
}

@end
