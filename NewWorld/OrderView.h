//
//  OrderView.h
//  NewWorld
//
//  Created by Seven on 14-7-15.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "NSString+STRegex.h"

@interface OrderView : UIViewController<UIActionSheetDelegate>

@property (strong, nonatomic) GoodsDetail *goodsDetail;

@property (strong, nonatomic) IBOutlet UIImageView *picIv;
@property (strong, nonatomic) IBOutlet UILabel *goodsNameLb;
@property (strong, nonatomic) IBOutlet UITextField *nameTf;
@property (strong, nonatomic) IBOutlet UITextField *phoneTf;
@property (strong, nonatomic) IBOutlet UITextView *addressTv;
@property (strong, nonatomic) IBOutlet UITextField *numberTf;
@property (strong, nonatomic) IBOutlet UILabel *moneyLb;
@property (strong, nonatomic) IBOutlet UIButton *subBtn;
@property (strong, nonatomic) IBOutlet UIButton *orderBtn;

- (IBAction)subAction:(id)sender;
- (IBAction)addAction:(id)sender;
- (IBAction)submitOrderAction:(id)sender;

@end
