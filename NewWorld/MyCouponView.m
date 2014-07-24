//
//  MyCouponView.m
//  NewWorld
//
//  Created by Seven on 14-7-20.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "MyCouponView.h"

@interface MyCouponView ()

@end

@implementation MyCouponView
@synthesize myCouponTable;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"我的优惠券";
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
    self.myCouponTable.delegate = self;
    self.myCouponTable.dataSource = self;
    self.myCouponTable.backgroundColor = [Tool getBackgroundColor];
    self.myCouponTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self reload];
}

//取数方法
- (void)reload
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        [Tool showHUD:@"正在加载" andView:self.view andHUD:hud];
        NSString *url = [NSMutableString stringWithFormat:@"%@%@?username=%@", api_base_url, api_mycoupons, [[UserModel Instance] getUserValueForKey:@"username"]];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           myCoupons = [Tool readJsonStrToMyCouponArray:operation.responseString];
                                           [self.myCouponTable reloadData];
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
    return [myCoupons count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 122;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [Tool getBackgroundColor];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCouponCellIdentifier];
    if (!cell) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"MyCouponCell" owner:self options:nil];
        for (NSObject *o in objects) {
            if ([o isKindOfClass:[MyCouponCell class]]) {
                cell = (MyCouponCell *)o;
            }
        }
    }
    MyCoupon *coupon = [myCoupons objectAtIndex:[indexPath row]];
    
    cell.titleLb.text = coupon.coupons_title;
    cell.validityLb.text = [NSString stringWithFormat:@"有效期："];
    cell.storeNameLb.text = coupon.name;
    cell.storePhoneLb.text = [NSString stringWithFormat:@"联系电话："];
    
    [Tool roundView:cell.bgLb andCornerRadius:5.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyCoupon *coupon = [myCoupons objectAtIndex:[indexPath row]];
    if (coupon) {
        CouponDetailView *couponDetailView = [[CouponDetailView alloc] init];
        couponDetailView.couponsId = coupon.coupons_id;
        [self.navigationController pushViewController:couponDetailView animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [myCoupons removeAllObjects];
    myCoupons = nil;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [self setMyCouponTable:nil];
    [myCoupons removeAllObjects];
    myCoupons = nil;
}

@end
