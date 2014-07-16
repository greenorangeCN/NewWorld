//
//  LoginView.m
//  NewWorld
//
//  Created by Seven on 14-7-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "LoginView.h"

@interface LoginView ()

@end

@implementation LoginView

@synthesize switchLb;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"登录";
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
    self.view.backgroundColor = [Tool getBackgroundColor];
    
    self.userNameTf.text = [[UserModel Instance] getUserValueForKey:@"username"];
    
    ZJSwitch *myswitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(0, 0, 66, 21)];
    myswitch.backgroundColor = [UIColor clearColor];
    myswitch.onTintColor = [UIColor grayColor];
    myswitch.tintColor = [UIColor colorWithRed:198.0/255.0 green:4.0/255.0 blue:1.0/255.0 alpha:1.0];
    myswitch.onText = @"* * *";
    myswitch.offText = @"abc";
    [myswitch setOn:YES];
    [myswitch addTarget:self action:@selector(handleSwitchEvent:) forControlEvents:UIControlEventValueChanged];
    [self.switchLb addSubview:myswitch];
    
    //适配iOS7uinavigationbar遮挡问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)handleSwitchEvent:(id)sender
{
    ZJSwitch *mys = (ZJSwitch *)sender;
    if (mys.on) {
        self.passwordTf.secureTextEntry = YES;
    }
    else
    {
        self.passwordTf.secureTextEntry = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender {
    NSString *userName = self.userNameTf.text;
    NSString *userPassword = self.passwordTf.text;
    if (userName == nil || [userName length] == 0) {
        [Tool ToastNotification:@"请输用户名" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    if (userPassword == nil || [userPassword length] == 0) {
        [Tool ToastNotification:@"请输入密码" andView:self.view andLoading:NO andIsBottom:NO];
        return;
    }
    
    NSString *loginUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_login];
    request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:loginUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:userName forKey:@"username"];
    [request setPostValue:userPassword forKey:@"pwd"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestLogin:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在登陆" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestLogin:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    User *user = [Tool readJsonStrToUser:request.responseString];
    
    int errorCode = [user.status intValue];
    NSString *errorMessage = user.info;
    switch (errorCode) {
        case 1:
        {
            [[UserModel Instance] saveIsLogin:YES];
            [[UserModel Instance] saveAccount:self.userNameTf.text andPwd:self.passwordTf.text];
            [[UserModel Instance] saveValue:user.id ForKey:@"id"];
            [[UserModel Instance] saveValue:user.username ForKey:@"username"];
            [[UserModel Instance] saveValue:user.nickname ForKey:@"nickname"];
            [[UserModel Instance] saveValue:user.name ForKey:@"name"];
            [[UserModel Instance] saveValue:user.avatar ForKey:@"avatar"];
            [[UserModel Instance] saveValue:user.mobile ForKey:@"mobile"];
            [[UserModel Instance] saveValue:user.email ForKey:@"email"];
            [[UserModel Instance] saveValue:user.address ForKey:@"address"];
            [[UserModel Instance] saveValue:user.id_code ForKey:@"id_code"];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"登陆提醒"
                                                         message:errorMessage
                                                        delegate:nil
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil];
            [av show];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case 0:
        {
            [Tool showCustomHUD:errorMessage andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
    }
    
}
@end
