//
//  Tool.m
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Tool.h"
@implementation Tool

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message
{
    UIAlertView *progressAlert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.frame = CGRectMake(121, 80, 37, 37);
    [progressAlert addSubview:activityView];
    [activityView startAnimating];
    return progressAlert;
}

+ (NSString *)getBBSIndex:(int)index
{
    if (index < 0) {
        return @"";
    }
    return [NSString stringWithFormat:@"%d楼", index+1];
}

+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom
{
    if (isBottom) {
        NSUInteger sectionCount = [tableView numberOfSections];
        if (sectionCount) {
            NSUInteger rowCount = [tableView numberOfRowsInSection:0];
            if (rowCount) {
                NSUInteger ii[2] = {0, rowCount - 1};
                NSIndexPath * indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
                [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:isBottom ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop animated:YES];
            }
        }
    }
    else
    {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog
{
    switch (catalog) {
        case 1:
        case 3:
            return @"请先登录后发表评论";
        case 2:
            return @"请先登录后再回帖或评论";
        case 4:
            return @"请先登录后发留言";
    }
    return @"请先登录后发表评论";
}

+ (void)roundTextView:(UIView *)txtView
{
    txtView.layer.borderColor = [[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0] CGColor];
    txtView.layer.borderWidth = 1;
    txtView.layer.cornerRadius = 6.0;
    txtView.layer.masksToBounds = YES;
    txtView.clipsToBounds = YES;
}

+ (void)roundView:(UIView *)view andCornerRadius:(float)radius
{
    view.layer.cornerRadius = radius;
    view.layer.masksToBounds = YES;
    view.clipsToBounds = YES;
}

+ (void)playAudio:(BOOL)isAlert
{
    NSString * path = [NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath], isAlert ? @"/alertsound.wav" : @"/soundeffect.wav"];
    SystemSoundID soundID;
    NSURL * filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    AudioServicesPlaySystemSound(soundID);
}

+ (UIColor *)getColorForCell:(int)row
{
    return row % 2 ?
    [UIColor colorWithRed:235.0/255.0 green:242.0/255.0 blue:252.0/255.0 alpha:1.0]:
    [UIColor colorWithRed:248.0/255.0 green:249.0/255.0 blue:249.0/255.0 alpha:1.0];
}

+ (void)clearWebViewBackground:(UIWebView *)webView
{
    UIWebView *web = webView;
    for (id v in web.subviews) {
        if ([v isKindOfClass:[UIScrollView class]]) {
            [v setBounces:NO];
        }
    }
}

+ (void)doSound:(id)sender
{
    NSError *err;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"soundeffect" ofType:@"wav"]] error:&err];
    player.volume = 1;
    player.numberOfLoops = 1;
    [player prepareToPlay];
    [player play];
}

+ (NSString *)getAppClientString:(int)appClient
{
    switch (appClient) {
        case 1:
            return @"";
        case 2:
            return @"来自手机";
        case 3:
            return @"来自手机";
        case 4:
            return @"来自iPhone";
        case 5:
            return @"来自手机";
        default:
            return @"";
    }
}

+ (void)ReleaseWebView:(UIWebView *)webView
{
    [webView stopLoading];
    [webView setDelegate:nil];
    webView = nil;
}

+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请先登录或注册" delegate:delegate cancelButtonTitle:@"返回" destructiveButtonTitle:nil otherButtonTitles:@"登录", @"注册", nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}
+ (void)processLoginNotice:(UIActionSheet *)actionSheet andButtonIndex:(NSInteger)buttonIndex andNav:(UINavigationController *)nav andParent:(UIViewController *)parent
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"登录"]) {
        LoginView *loginView = [[LoginView alloc] init];
        [nav pushViewController:loginView animated:YES];
    }
    else if([buttonTitle isEqualToString:@"注册"])
    {
        RegisterView *regView = [[RegisterView alloc] init];
        [nav pushViewController:regView animated:YES];
    }
}

+ (NSString *)intervalSinceNow: (NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    NSTimeInterval cha=now-late;
    
    if (cha/3600<1) {
        if (cha/60<1) {
            timeString = @"1";
        }
        else
        {
            timeString = [NSString stringWithFormat:@"%f", cha/60];
            timeString = [timeString substringToIndex:timeString.length-7];
        }
        
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    else if (cha/3600>1&&cha/86400<1) {
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    else if (cha/86400>1&&cha/864000<1)
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    else
    {
        //        timeString = [NSString stringWithFormat:@"%d-%"]
        NSArray *array = [theDate componentsSeparatedByString:@" "];
        //        return [array objectAtIndex:0];
        timeString = [array objectAtIndex:0];
    }
    return timeString;
}

+ (BOOL)isToday:(NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    NSTimeInterval late=[d timeIntervalSince1970]*1;
    
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSTimeInterval cha=now-late;
    
    if (cha/86400<1) {
        return YES;
    }
    else
    {
        return NO;
    }
}

+(int)getTextViewHeight:(UITextView *)txtView andUIFont:(UIFont *)font andText:(NSString *)txt
{
    float fPadding = 16.0;
    CGSize constraint = CGSizeMake(txtView.contentSize.width - 10 - fPadding, CGFLOAT_MAX);
    CGSize size = [txt sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    float fHeight = size.height + 16.0;
    return fHeight;
}

+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day
{
    return year*365 + month * 31 + day;
}

+ (UIColor *)getBackgroundColor
{
//    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"fb_bg.jpg"]];
    return [UIColor colorWithRed:221.0/255 green:221.0/255 blue:221.0/255 alpha:1.0];
}
+ (UIColor *)getCellBackgroundColor
{
    return [UIColor colorWithRed:235.0/255 green:235.0/255 blue:243.0/255 alpha:1.0];
}

+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getCache:(int)type andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"detail-%d-%d",type, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}

+ (void)deleteAllCache
{
}

+ (NSString *)getHTMLString:(NSString *)html
{
    return html;
}
+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud
{
    [view addSubview:hud];
    hud.labelText = text;
    //    hud.dimBackground = YES;
    hud.square = YES;
    [hud show:YES];
}

+ (void)showCustomHUD:(NSString *)text andView:(UIView *)view andImage:(NSString *)image andAfterDelay:(int)second
{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]] ;
    HUD.mode = MBProgressHUDModeCustomView;
    HUD.labelText = text;
    [HUD show:YES];
    [HUD hide:YES afterDelay:second];
}

+ (UIImage *)scale:(UIImage *)sourceImg toSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [sourceImg drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
+ (CGSize)scaleSize:(CGSize)sourceSize
{
    float width = sourceSize.width;
    float height = sourceSize.height;
    if (width >= height) {
        return CGSizeMake(800, 800 * height / width);
    }
    else
    {
        return CGSizeMake(800 * width / height, 800);
    }
}

+ (NSString *)getOSVersion
{
    return [NSString stringWithFormat:@"GreenOrange.com/%@/%@/%@/%@",AppVersion,[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion, [UIDevice currentDevice].model];
}

//利用正则表达式验证
+ (BOOL)isValidateEmail:(NSString *)email {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom
{
    GCDiscreetNotificationView *notificationView = [[GCDiscreetNotificationView alloc] initWithText:text showActivity:isLoading inPresentationMode:isBottom?GCDiscreetNotificationViewPresentationModeBottom:GCDiscreetNotificationViewPresentationModeTop inView:view];
    [notificationView show:YES];
    [notificationView hideAnimatedAfter:2.6];
}
+ (void)CancelRequest:(ASIHTTPRequest *)request
{
    if (request != nil) {
        [request cancel];
        [request clearDelegatesAndCancel];
    }
}
+ (NSDate *)NSStringDateToNSDate:(NSString *)string
{
    NSDateFormatter *f = [NSDateFormatter new];
    [f setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [f setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * d = [f dateFromString:string];
    return d;
}

+ (NSString *)TimestampToDateStr:(NSString *)timestamp andFormatterStr:(NSString *)formatter
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]];
    return [dateFormatter stringFromDate:confromTimesp];
}

+ (NSString *)GenerateTags:(NSMutableArray *)tags
{
    if (tags == nil || tags.count == 0) {
        return @"";
    }
    else
    {
        NSString *result = @"";
        for (NSString *t in tags) {
            result = [NSString stringWithFormat:@"%@<a style='background-color: #BBD6F3;border-bottom: 1px solid #3E6D8E;border-right: 1px solid #7F9FB6;color: #284A7B;font-size: 12pt;-webkit-text-size-adjust: none;line-height: 2.4;margin: 2px 2px 2px 0;padding: 2px 4px;text-decoration: none;white-space: nowrap;' href='http://www.oschina.net/question/tag/%@' >&nbsp;%@&nbsp;</a>&nbsp;&nbsp;",result,t,t];
        }
        return result;
    }
}

+ (void)saveCache:(NSString *)catalog andType:(int)type andID:(int)_id andString:(NSString *)str
{
    NSUserDefaults * setting = [NSUserDefaults standardUserDefaults];
    NSString * key = [NSString stringWithFormat:@"%@-%d-%d",catalog,type, _id];
    [setting setObject:str forKey:key];
    [setting synchronize];
}
+ (NSString *)getCache:(NSString *)catalog andType:(int)type andID:(int)_id
{
    NSUserDefaults * settings = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"%@-%d-%d",catalog,type, _id];
    
    NSString *value = [settings objectForKey:key];
    return value;
}

+ (void)shareAction:(UIButton *)sender andShowView:(UIView *)view andContent:(NSDictionary *)shareContent {
//    Activity *activity = [[Activity alloc] init];
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:[shareContent objectForKey:@"summary"]
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:[shareContent objectForKey:@"thumb"]]
                                                title:[shareContent objectForKey:@"title"]
                                                  url:@"http://house.nwclhn.com"
                                          description:[shareContent objectForKey:@"summary"]
                                            mediaType:SSPublishContentMediaTypeNews];
    
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    //    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
    //                                                         allowCallback:YES
    //                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
    //                                                          viewDelegate:nil
    //                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    //    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
    //                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ChellonaCar"],
    //                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
    //                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ChellonaCar"],
    //                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
    //                                    nil]];
    
    //自定义新浪微博分享菜单项
    id<ISSShareActionSheetItem> sinaItem = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeSinaWeibo]
                                                                              icon:[ShareSDK getClientIconWithType:ShareTypeSinaWeibo]
                                                                      clickHandler:^{
                                                                          [ShareSDK shareContent:publishContent
                                                                                            type:ShareTypeSinaWeibo
                                                                                     authOptions:nil
                                                                                   statusBarTips:NO
                                                                                          result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                                                              
                                                                                              if (state == SSPublishContentStateSuccess)
                                                                                              {
                                                                                                  [self showCustomHUD:@"分享成功" andView:view andImage:@"37x-Checkmark.png" andAfterDelay:1];
                                                                                                  NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
                                                                                              }
                                                                                              else if (state == SSPublishContentStateFail)
                                                                                              {
                                                                                                  [self showCustomHUD:@"分享失败" andView:view andImage:@"37x-Failure.png" andAfterDelay:1];
                                                                                                  NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                                                                              }
                                                                                          }];
                                                                      }];
    
    //自定义腾讯微博分享菜单项
    id<ISSShareActionSheetItem> tencentItem = [ShareSDK shareActionSheetItemWithTitle:[ShareSDK getClientNameWithType:ShareTypeTencentWeibo]
                                                                                 icon:[ShareSDK getClientIconWithType:ShareTypeTencentWeibo]
                                                                         clickHandler:^{
                                                                             [ShareSDK shareContent:publishContent
                                                                                               type:ShareTypeTencentWeibo
                                                                                        authOptions:nil
                                                                                      statusBarTips:NO
                                                                                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                                                                                 
                                                                                                 if (state == SSPublishContentStateSuccess)
                                                                                                 {
                                                                                                     [self showCustomHUD:@"分享成功" andView:view andImage:@"37x-Checkmark.png" andAfterDelay:1];
                                                                                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"分享成功"));
                                                                                                 }
                                                                                                 else if (state == SSPublishContentStateFail)
                                                                                                 {
                                                                                                     [self showCustomHUD:@"分享失败" andView:view andImage:@"37x-Failure.png" andAfterDelay:1];
                                                                                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                                                                                 }
                                                                                             }];
                                                                         }];
    
    //创建自定义分享列表
    NSArray *shareList = [ShareSDK customShareListWithType:
                          sinaItem,
                          tencentItem,
                          SHARE_TYPE_NUMBER(ShareTypeWeixiSession),
                          SHARE_TYPE_NUMBER(ShareTypeWeixiTimeline),
                          nil];
    
    
    
    NSArray *oneKeyShareList = [ShareSDK getShareListWithType:
                                ShareTypeSinaWeibo,
                                ShareTypeTencentWeibo,
                                ShareTypeWeixiFav,
                                nil];
    
    id<ISSShareOptions> shareOptions = [ShareSDK defaultShareOptionsWithTitle:nil      //分享视图标题
                                                              oneKeyShareList:oneKeyShareList           //一键分享菜单
                                                               qqButtonHidden:NO                               //QQ分享按钮是否隐藏
                                                        wxSessionButtonHidden:NO                   //微信好友分享按钮是否隐藏
                                                       wxTimelineButtonHidden:NO                 //微信朋友圈分享按钮是否隐藏
                                                         showKeyboardOnAppear:NO                  //是否显示键盘
                                                            shareViewDelegate:nil                            //分享视图委托
                                                          friendsViewDelegate:nil                          //好友视图委托
                                                        picViewerViewDelegate:nil];                    //图片浏览视图委托
    
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:nil
                         shareList:shareList
                           content:publishContent
                     statusBarTips:NO
                       authOptions:nil
                      shareOptions:shareOptions                    //传入分享选项对象
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    [self showCustomHUD:@"分享成功" andView:view andImage:@"37x-Checkmark.png" andAfterDelay:1];
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    [self showCustomHUD:@"分享失败" andView:view andImage:@"37x-Failure.png" andAfterDelay:1];
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}

+ (NSMutableArray *)readJsonStrToHousesArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *shopArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableArray *houses = [[NSMutableArray alloc] init] ;
    if ( [shopArray count] <= 0) {
        return nil;
    }
    
    for (int i = 0; i < [shopArray count] ; i++) {
        NSDictionary *houseJSONItem = [shopArray objectAtIndex:i];
        Houses *house = [RMMapper objectWithClass:[Houses class] fromDictionary:houseJSONItem];
        if([NSNull null] != [houseJSONItem objectForKey:@"zhoubian_items"]) {
            id supportJSON = [houseJSONItem objectForKey:@"zhoubian_items"];
            NSMutableArray *supports = [RMMapper mutableArrayOfClass:[Support class]
                                               fromArrayOfDictionary:supportJSON];
            house.zhoubian_items =supports;
        }
        [houses addObject:house];
    }
    return houses;
}

+ (NSMutableArray *)readJsonStrToActivitiesArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *acticitiesJsonArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableArray *acticities = [[NSMutableArray alloc] init] ;
    if ( [acticitiesJsonArray count] <= 0) {
        return nil;
    }
    
    NSDictionary *acticitiesDict = [[NSDictionary alloc] init];
    NSString *_id = [[NSString alloc] init];
    NSString *title = [[NSString alloc] init];
    NSString *thumb = [[NSString alloc] init];
    NSString *indexImg = [[NSString alloc] init];
    NSString *summary = [[NSString alloc] init];
    NSString *validityTime = [[NSString alloc] init];
    NSString *condition = [[NSString alloc] init];
    NSString *telephone = [[NSString alloc] init];
    NSString *qq = [[NSString alloc] init];
    NSString *counts = [[NSString alloc] init];
    NSString *published = [[NSString alloc] init];
    NSString *points = [[NSString alloc] init];
    
    for (int i = 0; i < [acticitiesJsonArray count] ; i++) {
        acticitiesDict = [acticitiesJsonArray objectAtIndex:i];
        _id = [acticitiesDict objectForKey:@"id"] ;
        title = [acticitiesDict objectForKey:@"title"];
        thumb = [acticitiesDict objectForKey:@"thumb"];
        indexImg = [acticitiesDict objectForKey:@"index_img"];
        summary = [acticitiesDict objectForKey:@"summary"];
        validityTime=[acticitiesDict objectForKey:@"date"];
        condition=[acticitiesDict objectForKey:@"condition"];
        telephone=[acticitiesDict objectForKey:@"telephone"];
        qq=[acticitiesDict objectForKey:@"qq"];
        counts=[acticitiesDict objectForKey:@"counts"];
        published=[acticitiesDict objectForKey:@"published"];
        points=[acticitiesDict objectForKey:@"points"];
        Activity *activity = [[Activity alloc]initWithParameters:_id andTitle:title andThumb:thumb andIndexImg:indexImg andSummary:summary andValidityTime:validityTime andCondition:condition andTelephone:telephone andQQ:qq andCounts:counts andPublished:published andPoints:points];
        [acticities addObject:activity];
    }
    return acticities;
}

+ (NSMutableArray *)readJsonStrToStoreArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *storeArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( [storeArray count] <= 0) {
        return nil;
    }
    NSMutableArray *stores = [RMMapper mutableArrayOfClass:[Bussiness class]
                                       fromArrayOfDictionary:storeArray];
    return stores;
}

+ (NSMutableArray *)readJsonStrToProjectArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *projectArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( [projectArray count] <= 0) {
        return nil;
    }
    NSMutableArray *projects = [RMMapper mutableArrayOfClass:[HousesProject class]
                                     fromArrayOfDictionary:projectArray];
    return projects;
}

+ (Support *)readJsonStrToSupport:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *supportDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( supportDic == nil) {
        return nil;
    }
    Support *house = [RMMapper objectWithClass:[Support class] fromDictionary:supportDic];
    return house;
}

+ (NSMutableArray *)readJsonStrToSliderImageArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSMutableArray *imageArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ([imageArray count] <= 0) {
        return nil;
    }
    else
    {
        return imageArray;
    }
}

+ (BusinessGoods *)readJsonStrBusinessGoods:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *businessGoodsDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    BusinessGoods *businessGoods = [[BusinessGoods alloc] init] ;
    if ([NSNull null] == businessGoodsDic) {
        return nil;
    }
    if([NSNull null] != [businessGoodsDic objectForKey:@"coupons"]) {
        id couponsJSON = [businessGoodsDic objectForKey:@"coupons"];
        NSMutableArray *coupons = [RMMapper mutableArrayOfClass:[Coupons class]
                                           fromArrayOfDictionary:couponsJSON];
        businessGoods.coupons = coupons;
    }
    if([NSNull null] != [businessGoodsDic objectForKey:@"goodlist"]) {
        id goodsJSON = [businessGoodsDic objectForKey:@"goodlist"];
        NSMutableArray *goods = [RMMapper mutableArrayOfClass:[Goods class]
                                          fromArrayOfDictionary:goodsJSON];
        businessGoods.goodlist = goods;
    }
    return businessGoods;
}

+ (GoodsDetail *)readJsonStrToGoodsDetail:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *detailDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( detailDic == nil) {
        return nil;
    }
    GoodsDetail *detail = [RMMapper objectWithClass:[GoodsDetail class] fromDictionary:detailDic];
    return detail;
}

+ (Coupons *)readJsonStrToCouponDetail:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *detailDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( detailDic == nil) {
        return nil;
    }
    Coupons *detail = [RMMapper objectWithClass:[Coupons class] fromDictionary:detailDic];
    return detail;
}

+ (NSMutableArray *)readJsonStrToHouseTypeArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *houseTypeArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( [houseTypeArray count] <= 0) {
        return nil;
    }
    NSMutableArray *houseTypes = [RMMapper mutableArrayOfClass:[HouseType class]
                                       fromArrayOfDictionary:houseTypeArray];
    return houseTypes;
}

+ (HouseType *)readJsonStrToHouseTypeDetail:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *detailDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( detailDic == nil) {
        return nil;
    }
    HouseType *detail = [RMMapper objectWithClass:[HouseType class] fromDictionary:detailDic];
    return detail;
}

+ (NSMutableArray *)readJsonStrToRoomsArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *roomsArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( [roomsArray count] <= 0) {
        return nil;
    }
    NSMutableArray *rooms = [RMMapper mutableArrayOfClass:[Rooms class]
                                         fromArrayOfDictionary:roomsArray];
    return rooms;
}

+ (User *)readJsonStrToUser:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *detailDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( detailDic == nil) {
        return nil;
    }
    User *user = [RMMapper objectWithClass:[User class] fromDictionary:detailDic];
    return user;
}

+ (Club *)readJsonStrToClub:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *clubDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( clubDic == nil) {
        return nil;
    }
    Club *club = [[Club alloc] init];
    
    NSDictionary *club_info = [clubDic objectForKey:@"club_info"];
    ClubInfo *clubinfo = [RMMapper objectWithClass:[ClubInfo class] fromDictionary:club_info];
    club.club_info = clubinfo;
    
    NSArray *club_items = [clubDic objectForKey:@"club_items"];
    NSMutableArray *clubitems = [RMMapper mutableArrayOfClass:[ClubItem class]
                                            fromArrayOfDictionary:club_items];
    club.club_items = clubitems;
    
    return club;
}

+ (ClubItem *)readJsonStrToClubDetail:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *detailDic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( detailDic == nil) {
        return nil;
    }
    ClubItem *detail = [RMMapper objectWithClass:[ClubItem class] fromDictionary:detailDic];
    return detail;
}

+ (NSMutableArray *)readJsonStrToMyOrderArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *orderArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( [orderArray count] <= 0) {
        return nil;
    }
    NSMutableArray *myOrders = [RMMapper mutableArrayOfClass:[MyOrder class]
                                     fromArrayOfDictionary:orderArray];
    return myOrders;
}

+ (NSMutableArray *)readJsonStrToMyCouponArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *couponArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( [couponArray count] <= 0) {
        return nil;
    }
    NSMutableArray *myCoupons = [RMMapper mutableArrayOfClass:[MyCoupon class]
                                       fromArrayOfDictionary:couponArray];
    return myCoupons;
}

+ (NSMutableArray *)readJsonStrToPanoramaArray:(NSString *)str
{
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSArray *panoramaArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if ( [panoramaArray count] <= 0) {
        return nil;
    }
    NSMutableArray *panoramas = [RMMapper mutableArrayOfClass:[Panorama class]
                                        fromArrayOfDictionary:panoramaArray];
    return panoramas;
}

@end
