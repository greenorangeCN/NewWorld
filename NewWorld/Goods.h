//
//  Goods.h
//  NewWorld
//
//  Created by Seven on 14-7-7.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Goods : NSObject

@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* thumb;
@property (nonatomic, retain) NSString* summary;
@property (nonatomic, retain) NSString* price;
@property (nonatomic, retain) NSString* market_price;
@property (nonatomic, retain) NSString* buys;
@property (retain,nonatomic) UIImage *imgData;

@end