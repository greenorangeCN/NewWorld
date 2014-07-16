//
//  HouseType.h
//  NewWorld
//
//  Created by Seven on 14-7-8.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HouseType : NSObject

@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* thumb;
@property (nonatomic, retain) NSString* web_price;
@property (nonatomic, retain) NSString* market_price;
@property (nonatomic, retain) NSString* unit_price;
@property (nonatomic, retain) NSString* note;
@property (nonatomic, retain) NSString* discount;
@property (nonatomic, retain) NSString* area;
@property (nonatomic, retain) NSString* house_type;
@property (nonatomic, retain) NSString* floor;
@property (nonatomic, retain) NSString* floor_num;
@property (nonatomic, retain) NSString* faces;
@property (nonatomic, retain) NSString* property_type;
@property (nonatomic, retain) NSString* property_industry_fee;
@property (nonatomic, retain) NSString* points;
@property (nonatomic, retain) NSString* comm_name;
@property (nonatomic, retain) NSString* summary;
@property (nonatomic, retain) NSMutableArray *images;
@property (retain,nonatomic) UIImage *imgData;

@end
