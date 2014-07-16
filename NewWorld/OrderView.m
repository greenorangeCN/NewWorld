//
//  OrderView.m
//  NewWorld
//
//  Created by Seven on 14-7-15.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "OrderView.h"

@interface OrderView ()

@end

@implementation OrderView

@synthesize goodsDetail;
@synthesize goodsNameLb;
@synthesize nameTf;
@synthesize phoneTf;
@synthesize addressTv;
@synthesize numberTf;
@synthesize moneyLb;
@synthesize subBtn;
@synthesize orderBtn;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"商品订单";
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
    //适配iOS7  scrollView计算uinavigationbar高度的问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.subBtn.enabled = NO;
    UserModel *user = [UserModel Instance];
    self.goodsNameLb.text = [NSString stringWithFormat:@"%@：%@", goodsDetail.store_name, goodsDetail.title];
    self.nameTf.text = [user getUserValueForKey:@"name"];
    self.phoneTf.text = [user getUserValueForKey:@"mobile"];
    self.addressTv.text = [user getUserValueForKey:@"address"];
    self.moneyLb.text = goodsDetail.price;
    
    //图片加载
    EGOImageView *imageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic1.png"]];
    imageView.imageURL = [NSURL URLWithString:goodsDetail.thumb];
    imageView.frame = CGRectMake(0.0f, 0.0f, 117.0f, 84.0f);
    [self.picIv addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)subAction:(id)sender {
    int numInt = [self.numberTf.text intValue];
    numInt --;
    if ( numInt <= 1) {
        self.subBtn.enabled = NO;
    }
    double priceD = [goodsDetail.price doubleValue];
    double moneyD = priceD * numInt;
    self.numberTf.text = [NSString stringWithFormat:@"%d", numInt];
    self.moneyLb.text = [NSString stringWithFormat:@"%.2f", moneyD];
}

- (IBAction)addAction:(id)sender {
    int numInt = [self.numberTf.text intValue];
    numInt ++;
    if ( numInt > 1) {
        self.subBtn.enabled = YES;
    }
    double priceD = [goodsDetail.price doubleValue];
    double moneyD = priceD * numInt;
    self.numberTf.text = [NSString stringWithFormat:@"%d", numInt];
    self.moneyLb.text = [NSString stringWithFormat:@"%.2f", moneyD];
}

- (IBAction)submitOrderAction:(id)sender {
    if ([UserModel Instance].isLogin == NO) {
        [Tool noticeLogin:self.view andDelegate:self andTitle:@""];
        return;
    }
    
    NSString *phoneStr = self.phoneTf.text;
    NSString *addressStr = self.addressTv.text;
    NSString *nameStr = self.nameTf.text;
    
    if (![phoneStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (addressStr == nil || [addressStr length] == 0) {
        [Tool showCustomHUD:@"送货地址为空" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (nameStr == nil || [nameStr length] == 0) {
        [Tool showCustomHUD:@"收货人为空" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    NSString *getUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_send_order];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:getUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:goodsDetail.id forKey:@"goods_id"];
    [request setPostValue:self.numberTf.text forKey:@"quantity"];
    [request setPostValue:goodsDetail.title forKey:@"title"];
    [request setPostValue:goodsDetail.business_id forKey:@"store_id"];
    [request setPostValue:[[UserModel Instance] getUserValueForKey:@"username"] forKey:@"username"];
    [request setPostValue:nameStr forKey:@"receiver"];
    [request setPostValue:phoneStr forKey:@"mobile"];
    [request setPostValue:addressStr forKey:@"address"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSubmit:)];
    [request startAsynchronous];
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在提交" andView:self.view andHUD:request.hud];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}

- (void)requestSubmit:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:YES];
    }
    [request setUseCookiePersistence:YES];
    User *user = [Tool readJsonStrToUser:request.responseString];
    
    int errorCode = [user.status intValue];
    switch (errorCode) {
        case 1:
        {
            self.orderBtn.enabled = NO;
            [Tool showCustomHUD:user.info andView:self.view  andImage:@"37x-Checkmark.png" andAfterDelay:1];
        }
            break;
        case 0:
        {
            [Tool showCustomHUD:user.info andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        }
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [Tool processLoginNotice:actionSheet andButtonIndex:buttonIndex andNav:self.navigationController andParent:nil];
}

@end
