//
//  BusinessCell.h
//  NewWorld
//
//  Created by Seven on 14-7-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *bg;
@property (strong, nonatomic) IBOutlet UIImageView *picIv;
@property (strong, nonatomic) IBOutlet UILabel *nameLb;
@property (strong, nonatomic) IBOutlet UITextView *summaryTv;
@property (strong, nonatomic) IBOutlet UILabel *distanceLb;

@end
