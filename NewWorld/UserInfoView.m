//
//  UserInfoView.m
//  NewWorld
//
//  Created by Seven on 14-7-13.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "UserInfoView.h"

#define ORIGINAL_MAX_WIDTH 640.0f

@interface UserInfoView ()

@end

@implementation UserInfoView

@synthesize faceIv;
@synthesize nicknameTf;
@synthesize phoneTf;
@synthesize addressTf;
@synthesize emailTf;
@synthesize nameTf;
@synthesize idTf;
@synthesize provinceTf;
@synthesize sexTf;
@synthesize cityTf;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 44)];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.text = @"个人信息";
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
    //适配iOS7uinavigationbar遮挡问题
    if(IS_IOS7)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.view.frame.size.height);
    
    faceEGOImageView = [[EGOImageView alloc] initWithPlaceholderImage:[UIImage imageNamed:@"loadingpic2.png"]];
    faceEGOImageView.imageURL = [NSURL URLWithString:[[UserModel Instance] getUserValueForKey:@"avatar"]];
    faceEGOImageView.frame = CGRectMake(0.0f, 0.0f, 90.0f, 90.0f);
    [self.faceIv addSubview:faceEGOImageView];
    
    UserModel *userM = [UserModel Instance];
    self.nicknameTf.text = [userM getUserValueForKey:@"nickname"];
    self.phoneTf.text = [userM getUserValueForKey:@"mobile"];
    self.addressTf.text = [userM getUserValueForKey:@"address"];
    self.emailTf.text = [userM getUserValueForKey:@"email"];
    self.nameTf.text = [userM getUserValueForKey:@"name"];
    self.idTf.text = [userM getUserValueForKey:@"id_code"];
    NSString *sexStr = [userM getUserValueForKey:@"sex"];
    NSString *provinceStr = [userM getUserValueForKey:@"province"];
    NSString *cityStr = [userM getUserValueForKey:@"city"];
    if (sexStr != nil && [sexStr length] > 0) {
        self.sexTf.text = sexStr;
    }
    if (provinceStr != nil && [provinceStr length] > 0) {
        self.provinceTf.text = provinceStr;
    }
    if (cityStr != nil && [cityStr length] > 0) {
        self.cityTf.text = cityStr;
    }
}

#pragma mark VPImageCropperDelegate
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    faceEGOImageView.image = editedImage;
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        NSString *updateUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_upload_avatar];
        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:updateUrl]];
        [request setUseCookiePersistence:[[UserModel Instance] isLogin]];
        [request setPostValue:[[UserModel Instance] getUserValueForKey:@"username"] forKey:@"username"];
        [request addData:UIImageJPEGRepresentation(editedImage, 0.75f) withFileName:@"img.jpg" andContentType:@"image/jpeg" forKey:@"portrait"];
        request.delegate = self;
        request.tag = 11;
        [request setDidFailSelector:@selector(requestFailed:)];
        [request setDidFinishSelector:@selector(requestPortrait:)];
        [request startAsynchronous];
        request.hud = [[MBProgressHUD alloc] initWithView:self.view];
        [Tool showHUD:@"头像上传" andView:self.view andHUD:request.hud];
    }];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if (request.hud) {
        [request.hud hide:NO];
    }
}

- (void)requestPortrait:(ASIHTTPRequest *)request
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
            [[UserModel Instance] saveValue:user.avatar ForKey:@"avatar"];
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

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 0) {
        if (buttonIndex == 0) {
            // 拍照
            if ([self isCameraAvailable] && [self doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                //使用前置摄像头
                if ([self isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
            
        } else if (buttonIndex == 1) {
            // 从相册中选取
            if ([self isPhotoLibraryAvailable]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = self;
                [self presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:^() {
        UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        portraitImg = [self imageByScalingToMaxSize:portraitImg];
        // 裁剪
        VPImageCropperViewController *imgEditorVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
        imgEditorVC.delegate = self;
        [self presentViewController:imgEditorVC animated:YES completion:^{
            // TO DO
        }];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
    }];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

#pragma mark camera utility
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickVideosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}
- (BOOL) canUserPickPhotosFromPhotoLibrary{
    return [self
            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

#pragma mark image scale utility
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage {
    if (sourceImage.size.width < ORIGINAL_MAX_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = ORIGINAL_MAX_WIDTH;
        btWidth = sourceImage.size.width * (ORIGINAL_MAX_WIDTH / sourceImage.size.height);
    } else {
        btWidth = ORIGINAL_MAX_WIDTH;
        btHeight = sourceImage.size.height * (ORIGINAL_MAX_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (IBAction)saveInfoAction:(id)sender {
    NSString *nicknameStr = self.nicknameTf.text;
    NSString *phoneStr = self.phoneTf.text;
    NSString *addressStr = self.addressTf.text;
    NSString *emailStr = self.emailTf.text;
    NSString *nameStr = self.nameTf.text;
    NSString *idcodeStr = self.idTf.text;
    NSString *sexStr = self.sexTf.text;
    NSString *provinceStr = self.provinceTf.text;
    NSString *cityStr = self.cityTf.text;
    if (nicknameStr == nil || [nicknameStr length] == 0) {
        [Tool showCustomHUD:@"请填写昵称" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![phoneStr isValidPhoneNum]) {
        [Tool showCustomHUD:@"手机号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (addressStr == nil || [addressStr length] == 0) {
        [Tool showCustomHUD:@"请填写住址" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (![emailStr isValidEmail]) {
        [Tool showCustomHUD:@"邮箱错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if (nameStr == nil || [nameStr length] == 0) {
        [Tool showCustomHUD:@"请填写姓名" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    if ([idcodeStr length] > 0 && ![idcodeStr isValidIdCardNum]) {
        [Tool showCustomHUD:@"身份证号错误" andView:self.view  andImage:@"37x-Failure.png" andAfterDelay:1];
        return;
    }
    
    NSString *loginUrl = [NSString stringWithFormat:@"%@%@", api_base_url, api_save_info];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:loginUrl]];
    [request setUseCookiePersistence:NO];
    [request setPostValue:[[UserModel Instance] getUserValueForKey:@"id"] forKey:@"id"];
    [request setPostValue:nicknameStr forKey:@"nickname"];
    [request setPostValue:nameStr forKey:@"name"];
    [request setPostValue:phoneStr forKey:@"mobile"];
    [request setPostValue:addressStr forKey:@"address"];
    [request setPostValue:emailStr forKey:@"email"];
    if ([idcodeStr length] > 0 && [idcodeStr isValidIdCardNum]) {
        [request setPostValue:@"IT00001" forKey:@"type"];
        [request setPostValue:idcodeStr forKey:@"idnum"];
    }
    [request setPostValue:provinceStr forKey:@"province"];
    [request setPostValue:cityStr forKey:@"city"];
    [request setPostValue:sexStr forKey:@"sex"];
    [request setDelegate:self];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidFinishSelector:@selector(requestSave:)];
    [request startAsynchronous];
    
    request.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [Tool showHUD:@"正在保存" andView:self.view andHUD:request.hud];
}

- (void)requestSave:(ASIHTTPRequest *)request
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
            [[UserModel Instance] saveValue:self.nicknameTf.text ForKey:@"nickname"];
            [[UserModel Instance] saveValue:self.nameTf.text ForKey:@"name"];
            [[UserModel Instance] saveValue:self.phoneTf.text ForKey:@"mobile"];
            [[UserModel Instance] saveValue:self.emailTf.text ForKey:@"email"];
            [[UserModel Instance] saveValue:self.addressTf.text ForKey:@"address"];
            [[UserModel Instance] saveValue:self.idTf.text ForKey:@"id_code"];
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

- (IBAction)faceAction:(id)sender {
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    choiceSheet.tag = 0;
    [choiceSheet showInView:self.view];
}

- (IBAction)selectSexAction:(id)sender {
    if (sexData == nil || [sexData count] == 0) {
        sexData = [[NSArray alloc] initWithObjects:@"男", @"女", nil];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"确  定", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
    UIPickerView *sexPicker = [[UIPickerView alloc] init];
    sexPicker.delegate = self;
    sexPicker.showsSelectionIndicator = YES;
    sexPicker.tag = 0;
    [actionSheet addSubview:sexPicker];
}

- (IBAction)selectCityAction:(id)sender {
    if (provinces == nil || [provinces count] == 0) {
        provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ProvincesAndCities.plist" ofType:nil]];
        cities = [[provinces objectAtIndex:0] objectForKey:@"Cities"];
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"\n\n\n\n\n\n\n\n\n\n"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"确  定", nil];
    actionSheet.tag = 2;
    [actionSheet showInView:self.view];
    UIPickerView *cityPicker = [[UIPickerView alloc] init];
    cityPicker.delegate = self;
    cityPicker.showsSelectionIndicator = YES;
    cityPicker.tag = 1;
    [actionSheet addSubview:cityPicker];
}

//返回显示的列数
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == 0) {
        return 1;
    }
    else if(pickerView.tag == 1)
    {
        return 2;
    }
    else
    {
        return 0;
    }
}
//返回当前列显示的行数
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 0) {
        return [sexData count];
    }
    else if(pickerView.tag == 1)
    {
        switch (component) {
            case 0:
                return [provinces count];
                break;
            case 1:
                return [cities count];
                break;
            default:
                return 0;
                break;
        }
    }
    else
    {
        return 0;
    }
}

#pragma mark Picker Delegate Methods

//返回当前行的内容,此处是将数组中数值添加到滚动的那个显示栏上
-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 0) {
        return [sexData objectAtIndex:row];
    }
    else if(pickerView.tag == 1)
    {
        switch (component) {
            case 0:
                return [[provinces objectAtIndex:row] objectForKey:@"State"];
                break;
            case 1:
                return [[cities objectAtIndex:row] objectForKey:@"city"];
                break;
            default:
                return nil;
                break;
        }
    }
    else
    {
        return nil;
    }
}

-(void) pickerView: (UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent: (NSInteger)component
{
    if (pickerView.tag == 0) {
        self.sexTf.text = [sexData objectAtIndex:row];
    }
    else if(pickerView.tag == 1)
    {
        switch (component) {
            case 0:
                cities = [[provinces objectAtIndex:row] objectForKey:@"Cities"];
                [pickerView selectRow:0 inComponent:1 animated:NO];
                [pickerView reloadComponent:1];
                self.provinceTf.text = [[provinces objectAtIndex:row] objectForKey:@"State"];;
                self.cityTf.text = [[cities objectAtIndex:0] objectForKey:@"city"];
                break;
            case 1:
                self.cityTf.text = [[cities objectAtIndex:row] objectForKey:@"city"];
                break;
            default:
                break;
        }
    }
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];//即使没有显示在window上，也不会自动的将self.view释放。
    // Add code to clean up any of your own resources that are no longer necessary.
    
    // 此处做兼容处理需要加上ios6.0的宏开关，保证是在6.0下使用的,6.0以前屏蔽以下代码，否则会在下面使用self.view时自动加载viewDidUnLoad
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        //需要注意的是self.isViewLoaded是必不可少的，其他方式访问视图会导致它加载 ，在WWDC视频也忽视这一点。
        if (self.isViewLoaded && !self.view.window)// 是否是正在使用的视图
        {
            // Add code to preserve data stored in the views that might be
            // needed later.
            
            // Add code to clean up other strong references to the view in
            // the view hierarchy.
            self.view = nil;// 目的是再次进入时能够重新加载调用viewDidLoad函数。
        }
    }
}

@end
