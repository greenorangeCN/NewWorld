//
//  SettingView.m
//  oschina
//
//  Created by wangjun on 12-3-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SettingView.h"


@implementation SettingView
@synthesize tableSettings;
@synthesize settings;
@synthesize settingsInSection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.image = [UIImage imageNamed:@"tab_setting"];
        self.tabBarItem.title = @"设置";
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"设置";
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        self.navigationItem.titleView = titleLabel;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.settingsInSection = [[NSMutableDictionary alloc] initWithCapacity:3];
    NSArray *first = [[NSArray alloc] initWithObjects:
                      [[SettingModel alloc] initWith:@"注册" andImg:@"setting_register" andTag:1 andTitle2:nil],
                      [[SettingModel alloc] initWith: @"登录" andImg:@"setting_login" andTag:2 andTitle2:nil],
                      [[SettingModel alloc] initWith: @"个人信息" andImg:@"setting_info" andTag:3 andTitle2:nil],
                      nil];
    NSArray *second = [[NSArray alloc] initWithObjects:
                       [[SettingModel alloc] initWith:@"我的送货单" andImg:@"setting_delivery" andTag:4 andTitle2:nil],
                       [[SettingModel alloc] initWith:@"我的优惠券" andImg:@"setting_coupon" andTag:5 andTitle2:nil],
                       nil];
    NSArray *third = [[NSArray alloc] initWithObjects:
                      [[SettingModel alloc] initWith:@"版本更新" andImg:@"setting_update" andTag:6 andTitle2:nil],
                      [[SettingModel alloc] initWith:@"客户服务" andImg:@"setting_service" andTag:7 andTitle2:nil],
                      [[SettingModel alloc] initWith:@"注销" andImg:@"setting_logout" andTag:8 andTitle2:nil],
                      nil];
    [self.settingsInSection setObject:first forKey:@"帐号"];
    [self.settingsInSection setObject:second forKey:@"我的"];
    [self.settingsInSection setObject:third forKey:@"设置"];
    self.settings = [[NSArray alloc] initWithObjects:@"帐号",@"我的",@"设置",nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableSettings reloadData];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
- (void)viewDidUnload
{
    [self setTableSettings:nil];
    [super viewDidUnload];
}

#pragma TableView的处理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSUInteger section = [indexPath section];
    NSString *key = [settings objectAtIndex:section];
    NSArray *sets = [settingsInSection objectForKey:key];
    SettingModel *action = [sets objectAtIndex:[indexPath row]];
    //开始处理
    switch (action.tag) {
        case 1:
        {
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            
        }
            break;
        case 6:
        {
            
        }
            break;
        case 7:
        {
            
        }
            break;
        case 8:
        {
            
        }
            break;
        default:
            break;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [settings count];
}
//IOS7自带沾滞效果
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];//创建一个视图
//    
//    UIImageView *headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 300, 30)];
//    
//    UIImage *image = [UIImage imageNamed:@"top_bg.png"];
//    
//    [headerImageView setImage:image];
//    
//    [headerView addSubview:headerImageView];
//    
//    
//    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 5, 150, 20)];
//    
//    headerLabel.backgroundColor = [UIColor clearColor];
//    
//    headerLabel.font = [UIFont boldSystemFontOfSize:15.0];
//    
//    headerLabel.textColor = [UIColor blueColor];
//    
//    headerLabel.text = @"Section";
//    
//    [headerView addSubview:headerLabel];
//  
//    return headerView;
//    
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString *key = [settings objectAtIndex:section];
    NSArray *set = [settingsInSection objectForKey:key];
    return [set count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    NSString *key = [settings objectAtIndex:section];
    NSArray *sets = [settingsInSection objectForKey:key];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingTableIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:SettingTableIdentifier];
    }
    SettingModel *model = [sets objectAtIndex:row];
    cell.textLabel.text = model.title;
    [cell.textLabel setFont:[UIFont fontWithName:@"American Typewriter" size:14.0f]];
    cell.imageView.image = [UIImage imageNamed:model.img];
    cell.tag = model.tag;
    return cell;
}


@end
