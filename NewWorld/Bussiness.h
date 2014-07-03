//
//  Bussiness.h
//  NewWorld
//
//  Created by Seven on 14-7-2.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Bussiness : NSObject

@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, retain) NSString* logo;
@property (nonatomic, retain) NSString* summary;
@property (nonatomic, retain) NSString* phone;
@property (nonatomic, retain) NSString* address;
@property (nonatomic, retain) NSString* longitude;
@property (nonatomic, retain) NSString* latitude;
@property (retain,nonatomic) UIImage *imgData;
@property int distance;

@end
