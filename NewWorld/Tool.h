//
//  Tool.h
//  oschina
//
//  Created by wangjun on 12-3-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "MBProgressHUD.h"
#import <CommonCrypto/CommonCryptor.h>
#import "RMMapper.h"
#import "Activity.h"
#import "Houses.h"
#import "Support.h"
#import "Bussiness.h"
#import "HousesProject.h"
#import "BusinessGoods.h"
#import "Coupons.h"
#import "Goods.h"
#import "GoodsDetail.h"
#import "HouseType.h"
#import "Rooms.h"
#import "User.h"
#import "LoginView.h"
#import "RegisterView.h"
#import "Club.h"
#import <ShareSDK/ShareSDK.h>

@interface Tool : NSObject

+ (UIAlertView *)getLoadingView:(NSString *)title andMessage:(NSString *)message;

+ (NSMutableArray *)getRelativeNews:(NSString *)request;
+ (NSString *)generateRelativeNewsString:(NSArray *)array;

+ (UIColor *)getColorForCell:(int)row;

+ (void)clearWebViewBackground:(UIWebView *)webView;

+ (void)doSound:(id)sender;

+ (NSString *)getBBSIndex:(int)index;

+ (void)toTableViewBottom:(UITableView *)tableView isBottom:(BOOL)isBottom;

+ (void)roundTextView:(UIView *)txtView;
+ (void)roundView:(UIView *)view andCornerRadius:(float)radius;

+ (void)noticeLogin:(UIView *)view andDelegate:(id)delegate andTitle:(NSString *)title;

+ (void)processLoginNotice:(UIActionSheet *)actionSheet andButtonIndex:(NSInteger)buttonIndex andNav:(UINavigationController *)nav andParent:(UIViewController *)parent;

+ (NSString *)getCommentLoginNoticeByCatalog:(int)catalog;

+ (void)playAudio:(BOOL)isAlert;

+ (NSString *)intervalSinceNow: (NSString *) theDate;

+ (BOOL)isToday:(NSString *) theDate;

+ (int)getDaysCount:(int)year andMonth:(int)month andDay:(int)day;

+ (NSString *)getAppClientString:(int)appClient;

+ (void)ReleaseWebView:(UIWebView *)webView;

+ (int)getTextViewHeight:(UITextView *)txtView andUIFont:(UIFont *)font andText:(NSString *)txt;

+ (UIColor *)getBackgroundColor;
+ (UIColor *)getCellBackgroundColor;

+ (BOOL)isValidateEmail:(NSString *)email;

+ (void)saveCache:(int)type andID:(int)_id andString:(NSString *)str;
+ (NSString *)getCache:(int)type andID:(int)_id;

+ (void)deleteAllCache;

+ (NSString *)getHTMLString:(NSString *)html;

+ (void)showHUD:(NSString *)text andView:(UIView *)view andHUD:(MBProgressHUD *)hud;
+ (void)showCustomHUD:(NSString *)text andView:(UIView *)view andImage:(NSString *)image andAfterDelay:(int)second;

+ (UIImage *) scale:(UIImage *)sourceImg toSize:(CGSize)size;

+ (CGSize)scaleSize:(CGSize)sourceSize;

+ (NSString *)getOSVersion;

+ (void)ToastNotification:(NSString *)text andView:(UIView *)view andLoading:(BOOL)isLoading andIsBottom:(BOOL)isBottom;

+ (void)CancelRequest:(ASIFormDataRequest *)request;

+ (NSDate *)NSStringDateToNSDate:(NSString *)string;
//时间戳转指定格式时间字符串
+ (NSString *)TimestampToDateStr:(NSString *)timestamp andFormatterStr:(NSString *)formatter;

+ (NSString *)GenerateTags:(NSMutableArray *)tags;

+ (void)saveCache:(NSString *)catalog andType:(int)type andID:(int)_id andString:(NSString *)str;
+ (NSString *)getCache:(NSString *)catalog andType:(int)type andID:(int)_id;
+ (void)shareAction:(UIButton *)sender andShowView:(UIView *)view andContent:(NSDictionary *)shareContent;

+ (NSMutableArray *)readJsonStrToHousesArray:(NSString *)str;
+ (NSMutableArray *)readJsonStrToActivitiesArray:(NSString *)str;
+ (NSMutableArray *)readJsonStrToStoreArray:(NSString *)str;
+ (NSMutableArray *)readJsonStrToProjectArray:(NSString *)str;
+ (Support *)readJsonStrToSupport:(NSString *)str;
+ (NSMutableArray *)readJsonStrToSliderImageArray:(NSString *)str;
+ (BusinessGoods *)readJsonStrBusinessGoods:(NSString *)str;
+ (GoodsDetail *)readJsonStrToGoodsDetail:(NSString *)str;
+ (Coupons *)readJsonStrToCouponDetail:(NSString *)str;
+ (NSMutableArray *)readJsonStrToHouseTypeArray:(NSString *)str;
+ (HouseType *)readJsonStrToHouseTypeDetail:(NSString *)str;
+ (NSMutableArray *)readJsonStrToRoomsArray:(NSString *)str;
+ (User *)readJsonStrToUser:(NSString *)str;
+ (Club *)readJsonStrToClub:(NSString *)str;
+ (ClubItem *)readJsonStrToClubDetail:(NSString *)str;

@end
