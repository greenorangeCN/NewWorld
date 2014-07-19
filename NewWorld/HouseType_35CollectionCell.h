//
//  HouseType_35CollectionCell.h
//  NewWorld
//
//  Created by Seven on 14-7-19.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HouseType_35CollectionCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageIv;
@property (strong, nonatomic) IBOutlet UIView *bg;
@property (strong, nonatomic) IBOutlet UILabel *titleLb;
@property (strong, nonatomic) IBOutlet UILabel *webPriceLb;
@property (strong, nonatomic) IBOutlet UILabel *marketPriceLb;
@property (strong, nonatomic) IBOutlet UITextView *noteTv;
@property (strong, nonatomic) IBOutlet UILabel *discountLb;
@property (strong, nonatomic) IBOutlet UILabel *unitPriceLb;
@property (strong, nonatomic) IBOutlet UILabel *areaLb;
@property (strong, nonatomic) IBOutlet UILabel *houseTypeLb;

@property (strong, nonatomic) IBOutlet UIButton *orderBtn;
@property (strong, nonatomic) IBOutlet UIButton *praiseBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;


@end
