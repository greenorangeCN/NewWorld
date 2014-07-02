//
//  ActivityCell.h
//  NewWorld
//
//  Created by Seven on 14-7-1.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *bg;
@property (strong, nonatomic) IBOutlet UIImageView *picIv;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UITextView *summaryTv;
@property (strong, nonatomic) IBOutlet UILabel *dateLb;

//长按删除元素用
@property (nonatomic,assign) id delegate;
- (void)initGR;

@end
