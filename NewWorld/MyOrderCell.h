//
//  MyOrderCell.h
//  NewWorld
//
//  Created by Seven on 14-7-22.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyOrderCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *bgLb;
@property (strong, nonatomic) IBOutlet UIImageView *picIv;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UILabel *quantityLb;
@property (strong, nonatomic) IBOutlet UILabel *storeNameLb;
@property (strong, nonatomic) IBOutlet UILabel *storePhoneLb;
@property (strong, nonatomic) IBOutlet UILabel *addTimeLb;

@end
