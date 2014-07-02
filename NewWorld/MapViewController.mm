//
//  MapViewController.m
//  Sjdnbm
//
//  Created by tyh on 13-9-22.
//  Copyright (c) 2013年 tyh. All rights reserved.
//

#import "MapViewController.h"

@implementation MapViewController
@synthesize tabBar;

static CGFloat kTransitionDuration = 0.45f;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
    }
    return success;
}

- (void)addSkipBackupAttributeToPath:(NSString*)path {
    u_int8_t b = 1;
    setxattr([path fileSystemRepresentation], "com.apple.MobileBackup", &b, 1, 0, 0);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isPinSelected = NO;   //new
    mapsAll = [[NSMutableArray alloc] init];
    mapsSchool = [[NSMutableArray alloc] init];
    mapsGov = [[NSMutableArray alloc] init];
    mapsShop = [[NSMutableArray alloc] init];
    mapsService = [[NSMutableArray alloc] init];
    
//    CGRect rect = _mapView.bounds;
//    if (IS_IOS7) {
//        rect.origin.y = self.navigationController.navigationBar.frame.size.height + 15;
//        rect.size.height = rect.size.height - self.navigationController.navigationBar.frame.size.height - 15;
//    }
////    rect.size.height = rect.size.height-self.navigationController.navigationBar.frame.size.height;
//    [_mapView setFrame:rect];
    _mapView.zoomLevel = 13;
    _locService = [[BMKLocationService alloc]init];
    bubbleView = [[KYBubbleView alloc] initWithFrame:CGRectMake(0, 0, 160, 40)];
    bubbleView.hidden = NO;
    
    self.tabBar.selectedImageTintColor = [UIColor colorWithRed:197.0/255 green:36.0/255 blue:42.0/255 alpha:1.0];
    //初始化选中第一个
    self.tabBar.selectedItem = [self.tabBar.items objectAtIndex:0];
    self.tabBar.delegate = self;
    
    //设置目录不进行IOS自动同步！否则审核不能通过
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [NSString stringWithFormat:@"%@/cfg", [paths objectAtIndex:0]];
    NSURL *dbURLPath = [NSURL fileURLWithPath:directory];
    [self addSkipBackupAttributeToItemAtURL:dbURLPath];
    [self addSkipBackupAttributeToPath:directory];
    _mapView.showsUserLocation = YES;
    [self initMapsData];
}

- (void)tabBar:(UITabBar *)tabbar didSelectItem:(UITabBarItem *)item
{
    // 清除屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
    if (item.tag == 0) {
        mapsTemp = mapsAll;
        [self setMapAnnotation:mapsTemp];
    }
    else if (item.tag == 1) {
        mapsTemp = mapsSchool;
        [self setMapAnnotation:mapsTemp];
    }
    else if (item.tag == 2) {
        mapsTemp = mapsGov;
        [self setMapAnnotation:mapsTemp];
    }
    else if (item.tag == 3) {
        mapsTemp = mapsShop;
        [self setMapAnnotation:mapsTemp];
    }
    else if (item.tag == 4) {
        mapsTemp = mapsService;
        [self setMapAnnotation:mapsTemp];
    }
}

- (void)setMapAnnotation:(NSMutableArray *)mapsData
{
    for (int i = 0; i < [mapsData count]; i++) {
        Support *temp =[mapsData objectAtIndex:i];
        KYPointAnnotation* item = [[KYPointAnnotation alloc]init];
        item.tag = i;
        CLLocationCoordinate2D coor;
        coor.longitude = [temp.longitude doubleValue];
        coor.latitude = [temp.latitude doubleValue];
        item.coordinate = coor;
        item.title = temp.title;
        [_mapView addAnnotation:item];   //会触发委托方法
    }
}

-(void)initMapsData{
    NSString *url = [NSString stringWithFormat:@"%@%@", api_base_url, api_mapsNavigation];
    if ([UserModel Instance].isNetworkRunning) {
        [[AFOSCClient sharedClient]getPath:url parameters:Nil
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       @try {
                                           houses = [Tool readJsonStrToHousesArray:operation.responseString];
                                           for (Houses *house in houses) {
                                               Support *s = [[Support alloc] init];
                                               s.id = house.id;
                                               s.type = @"0";
                                               s.title = house.title;
                                               s.longitude = house.longitude;
                                               s.latitude = house.latitude;
                                               s.telephone = house.telephone;
                                               [mapsAll addObject:s];
                                               
                                               if([NSNull null] != house.zhoubian_items) {
                                                   NSMutableArray *supports = house.zhoubian_items;
                                                   if (supports != nil && [supports count] > 0) {
                                                       [mapsAll addObjectsFromArray:supports];
                                                   }
                                               }
                                           }
                                           mapsTemp = mapsAll;
                                           //添加PointAnnotation
                                           for (int i = 0; i < [mapsAll count]; i++) {
                                               Support *temp =[mapsAll objectAtIndex:i];
                                               
                                               //对地图数据进行分类，为TABBAR点击做数据准备
                                               NSString *type = temp.type;
                                               if([type isEqualToString:@"1"]){
                                                   [mapsSchool addObject:temp];
                                               }
                                               if([type isEqualToString:@"2"]){
                                                   [mapsGov addObject:temp];
                                               }
                                               if([type isEqualToString:@"3"]){
                                                   [mapsShop addObject:temp];
                                               }
                                               if([type isEqualToString:@"4"]){
                                                   [mapsService addObject:temp];
                                               }
                                               if([type isEqualToString:@"0"]){
                                                   [mapsSchool addObject:temp];
                                                   [mapsGov addObject:temp];
                                                   [mapsShop addObject:temp];
                                                   [mapsService addObject:temp];
                                               }
                                               
                                               KYPointAnnotation* item = [[KYPointAnnotation alloc]init];
                                               item.tag = i;
                                               CLLocationCoordinate2D coor;
                                               coor.longitude = [temp.longitude doubleValue];
                                               coor.latitude = [temp.latitude doubleValue];
                                               item.coordinate = coor;
                                               item.title = temp.title;
                                               [_mapView addAnnotation:item];   //会触发委托方法
                                           }
                                       }
                                       @catch (NSException *exception) {
                                           [NdUncaughtExceptionHandler TakeException:exception];
                                       }
                                       @finally {
                                           
                                       }
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       NSLog(@"地图获取出错");
                                       
                                       if ([UserModel Instance].isNetworkRunning == NO) {
                                           return;
                                       }
                                       
                                       if ([UserModel Instance].isNetworkRunning) {
                                           [Tool ToastNotification:@"错误 网络无连接" andView:self.view andLoading:NO andIsBottom:NO];
                                       }
                                   }];
        
    }
    //如果没有网络连接
    else
    {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    _mapView.delegate = nil;
}

- (void)changeBubblePosition {
    if (selectedAV) {
        CGRect rect = selectedAV.frame;
        CGPoint center;
        center.x = rect.origin.x + rect.size.width/2;
        center.y = rect.origin.y - bubbleView.frame.size.height/2 + 8;
        bubbleView.center = center;
    }
}

#ifdef Debug

#	define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else

#	define DLog(...)

#endif

#pragma mark 标注（应该就是大头针吧）
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    DLog(@"生成标注view");
    BMKPinAnnotationView *annotationView = (BMKPinAnnotationView*)[mapView viewForAnnotation:annotation];
    if (annotationView == nil)
    {
        KYPointAnnotation *ann;
        if ([annotation isKindOfClass:[KYPointAnnotation class]]) {
            ann = annotation;
        }else{
            return annotationView ;
        }
        NSUInteger tag = ann.tag;
        NSString *AnnotationViewID = [NSString stringWithFormat:@"AnnotationView-%i", tag];
        Support *support = [mapsTemp objectAtIndex:tag];
        NSString *type = support.type;
        
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:AnnotationViewID];
        ((BMKPinAnnotationView*) annotationView).pinColor = BMKPinAnnotationColorRed;
        annotationView.canShowCallout = NO;//使用自定义bubble
        
		((BMKPinAnnotationView*)annotationView).animatesDrop = YES;// 设置该标注点动画显示
//        // 设置可拖拽
//		((BMKPinAnnotationView*)annotationView).draggable = YES;
        
        
        annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
        annotationView.annotation = annotation;
        //把大头针换成别的图片
        
        if([type isEqualToString:@"1"]){
            annotationView.image = [UIImage imageNamed:@"map_school_p.png"];
        }
        if([type isEqualToString:@"2"]){
            annotationView.image = [UIImage imageNamed:@"map_gov_p.png"];
        }
        if([type isEqualToString:@"3"]){
            annotationView.image = [UIImage imageNamed:@"map_shop_p.png"];
        }
        if([type isEqualToString:@"4"]){
            annotationView.image = [UIImage imageNamed:@"map_service_p.png"];
        }
        if([type isEqualToString:@"0"]){
            annotationView.image = [UIImage imageNamed:@"map_newworld_p.png"];
        }
	}
	return annotationView ;
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    DLog(@"选中标注");
    isPinSelected = YES;
    //CGPoint point = [mapView convertCoordinate:view.annotation.coordinate toPointToView:mapView];
    if ([view isKindOfClass:[BMKPinAnnotationView class]]) {
#ifdef Debug
        CGPoint point = [mapView convertCoordinate:selectedAV.annotation.coordinate toPointToView:selectedAV.superview];
        //CGRect rect = selectedAV.frame;
        DLog(@"annotationPoint:x=%.1f, y=%.1f", point.x, point.y);
#endif
        selectedAV = view;
        if (bubbleView.superview == nil) {
			//bubbleView加在BMKAnnotationView的superview(UIScrollView)上,且令zPosition为1
            [view.superview addSubview:bubbleView];  //为大头针添加自定义对气泡view
            bubbleView.layer.zPosition = 1;
        }try {
            bubbleView.support = [mapsTemp objectAtIndex:[(KYPointAnnotation*)view.annotation tag]];  //数据全部在数据字典中
            bubbleView.navigationController = self.navigationController;
            //      [self showBubble:YES];//先移动地图，完成后再显示气泡
        } catch (NSException *exception) {
            
        }
    }
    else {
        selectedAV = nil;
    }
    [mapView setCenterCoordinate:view.annotation.coordinate animated:YES];
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view
{
    DLog(@"取消选中标注");
    isPinSelected = NO;
    if ([view isKindOfClass:[BMKPinAnnotationView class]]) {
        [self showBubble:NO];
    }
}

#pragma mark 区域改变
- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if (selectedAV) {
        bubbleView.hidden = YES;
#ifdef Debug
        CGPoint point = [mapView convertCoordinate:selectedAV.annotation.coordinate toPointToView:selectedAV.superview];
        //CGRect rect = selectedAV.frame;
        DLog(@"x=%.1f, y= %.1f", point.x, point.y);
#endif
    }
    DLog(@"地图区域即将改变");
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (selectedAV) {
        if (isPinSelected) {    //只有当大头针被选中时的区域改变才会显示气泡
            [self showBubble:YES];       //modify 地图区域改变  - 原代码是没有注释的
            [self changeBubblePosition];
        }
#ifdef Debug
        CGPoint point = [mapView convertCoordinate:selectedAV.annotation.coordinate toPointToView:selectedAV.superview];
        DLog(@"x=%.1f, y= %.1f", point.x, point.y);
#endif
    }
    DLog(@"地图区域改变完成");
}


#pragma mark show bubble animation
- (void)bounce4AnimationStopped{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
	[UIView commitAnimations];
}


- (void)bounce3AnimationStopped{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce4AnimationStopped)];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.95, 0.95);
	[UIView commitAnimations];
}

- (void)bounce2AnimationStopped{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce3AnimationStopped)];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
	[UIView commitAnimations];
}

- (void)bounce1AnimationStopped{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/6];
	[UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)showBubble:(BOOL)show {
    if (show) {
        [bubbleView showFromRect:selectedAV.frame];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/3];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
        bubbleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
        bubbleView.hidden = NO;
        [UIView commitAnimations];
    }
    else {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration/3];
        bubbleView.hidden = YES;
        [UIView commitAnimations];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locService.delegate = self;
    
//    self.navigationController.navigationBar.hidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    selectedAV = nil;
    [self startLocation];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
}

-(void)startLocation
{
    NSLog(@"进入跟随定位态");
    [_locService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeFollow;//设置定位的状态(跟随状态)
    _mapView.showsUserLocation = YES;//显示定位图层
}

/**
 *在地图View将要启动定位时，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewWillStartLocatingUser:(BMKMapView *)mapView
{
	NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
//    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    //    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [_mapView updateLocationData:userLocation];
//    userLocation.title = @"我的位置";
//    CLLocationCoordinate2D mycoord = userLocation.location.coordinate;
//    BMKMapPoint myPoint = BMKMapPointForCoordinate(mycoord);
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)mapViewDidStopLocatingUser:(BMKMapView *)mapView
{
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param mapView 地图View
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showMenuAction:(UIButton *)sender {
    NSMutableArray *menuItems = [[NSMutableArray alloc] init];
    KxMenuItem *first = [KxMenuItem menuItem:@"楼盘选择"
                                       image:nil
                                      target:nil
                                         tag:nil
                                      action:NULL];
    [menuItems addObject:first];
    for (int i = 0; i < [houses count]; i++) {
        Houses *house = [houses objectAtIndex:i];
        KxMenuItem *item = [KxMenuItem menuItem:house.title
                                          image:nil
                                         target:self
                                            tag:[NSString stringWithFormat:@"%d", i]
                                         action:@selector(pushMenuItem:)];
        [menuItems addObject:item];
    }
    KxMenuItem *first1 = menuItems[0];
    first1.foreColor = [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:1.0];
    first1.alignment = NSTextAlignmentCenter;
    [KxMenu showMenuInView:self.view
                  fromRect:sender.frame
                 menuItems:menuItems];
}

- (void) pushMenuItem:(id)sender
{
    KxMenuItem *item = sender;
    int tag = [item.tag intValue];
    Houses *house = [houses objectAtIndex:tag];
    CLLocationCoordinate2D coor;
    coor.longitude = [house.longitude doubleValue];
    coor.latitude = [house.latitude doubleValue];
    [_mapView setCenterCoordinate:coor animated:YES];
}

@end