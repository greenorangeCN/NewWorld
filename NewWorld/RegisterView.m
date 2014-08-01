//
//  RegisterView.m
//  NewWorld
//
//  Created by Seven on 14-7-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "RegisterView.h"

@interface RegisterView ()

@end

@implementation RegisterView
@synthesize nickNameTf;
@synthesize userNameTf;
@synthesize passwordTf;
@synthesize passwordagainTf;
@synthesize projectNameTf;
@synthesize projectPicker;
@synthesize actionSheet;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"用户注册";
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
    pickerData = [[NSMutableArray alloc] init];
    [self getProjectData];
}

//取数方法
- (void)getProjectData
{
    //如果有网络连接
    if ([UserModel Instance].isNetworkRunning) {
        NSString *url = [NSMutableString stringWithFormat:@"%@%@", api_base_url, api_project];
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           projects = [Tool readJsonStrToProjectArray:operation.responseString];
                                           if (projects != nil && [projects count] > 0) {
                                               for(HousesProject *project in projects) {
                                                   [pickerData addObject:project.title];
                                               }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectAreaAction:(id)sender {
    [self setProjectPicker];
    
}

- (IBAction)registerAction:(id)sender {
    NSString *nickName = self.nickNameTf.text;
    NSString *userName = self.userNameTf.text;
    NSString *userPassword = self.passwordTf.text;
    NSString *userPassword2 = self.passwordagainTf.text;
    NSString *projectName = self.projectNameTf.text;
    if (nickName == nil || [nickName length] == 0) {
        [Tool showCustomHUD:@"请输入昵称" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![userName isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (userPassword == nil || [userPassword length] == 0) {
        [Tool showCustomHUD:@"请输入密码" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![userPassword isEqualToString:userPassword2]) {
        [Tool showCustomHUD:@"密码确认不一致" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        self.passwordagainTf.text = @"";
        return;
    }
//    if (projectName == nil || [projectName length] == 0) {
//        [Tool ToastNotification:@"请选择所在小区" andView:self.view andLoading:NO andIsBottom:NO];
//        return;
//    }
    
    NSString *regUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_register];
    request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:regUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:nickName forKey:@"nickname"];
    [request setPostValue:userName forKey:@"tel"];
    [request setPostValue:userName forKey:@"username"];
    [request setPostValue:userPassword forKey:@"pwd"];
//    [request setPostValue:projectId forKey:@"c_id"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestRegister:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在注册" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}
- (void)requestRegister:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    
    [request setUseCookiePersistence:YES];
    NSData *data = [request.responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (!json) {
        NSLog(request.responseString);
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误提示"
                                                     message:request.responseString
                                                    delegate:nil
                                           cancelButtonTitle:@"确定"
                                           otherButtonTitles:nil];
        [av show];
        return;
    }
    NSLog(request.responseString);
    
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
            [[UserModel Instance] saveValue:user.idnum ForKey:@"idnum"];
            [[UserModel Instance] saveValue:user.sex ForKey:@"sex"];
            [[UserModel Instance] saveValue:user.province ForKey:@"province"];
            [[UserModel Instance] saveValue:user.city ForKey:@"city"];
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"注册提醒"
                                                         message:[NSString stringWithFormat:@"%@，%@", errorMessage, @"并已登录"]
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
//            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
    }
    
}

-(void) setProjectPicker
{
    self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                     destructiveButtonTitle:nil
                                          otherButtonTitles:nil];
    [self.actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    // Add the picker
    self.projectPicker = [[UIPickerView alloc] init];
    [self.projectPicker setFrame:CGRectMake(0, 40, 320, 420)];
    self.projectPicker.delegate = self;
    //    显示选中框
    self.projectPicker.showsSelectionIndicator=YES;
    [self.actionSheet addSubview:self.projectPicker];
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0,320, 460)];
    
//    CGRect pickerRect;
//    pickerRect = self.projectPicker.bounds;
////    pickerRect.origin.y = -30;
//    self.projectPicker.bounds = pickerRect;
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(10.0f, 7.0f, 65.0f, 32.0f);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(projectPickerDoneClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 1;
    [self.actionSheet addSubview:cancelButton];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    confirmButton.frame = CGRectMake(245.0f, 7.0f, 65.0f, 32.0f);
    [confirmButton setTitle:@"确定" forState:UIControlStateNormal];
    [confirmButton addTarget:self action:@selector(projectPickerDoneClick:) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.tag = 2;
    [self.actionSheet addSubview:confirmButton];
    
    [self.actionSheet showInView:self.view];
    [self.actionSheet setBounds:CGRectMake(0,0, 320, 460)];
    
}

- (void)projectPickerDoneClick:(id) sender
{
    [self.actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    UIButton *button = (UIButton *)sender;
    if(button.tag == 1)
    {
        self.projectNameTf.text = @"";
    }
    if(button.tag == 2)
    {
        
    }
}

//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [pickerData count];
}

#pragma mark Picker Delegate Methods

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    self.projectNameTf.text = [pickerData objectAtIndex:row];
    projectId = ((HousesProject *)[projects objectAtIndex:row]).id;
    return [pickerData objectAtIndex:row];
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
//    self.projectNameTf.text = [pickerData objectAtIndex:row];
//    projectId = ((HousesProject *)[projects objectAtIndex:row]).id;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

@end
