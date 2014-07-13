//
//  Rooms.h
//  NewWorld
//
//  Created by Seven on 14-7-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Rooms : NSObject

@property (nonatomic, retain) NSString *id;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *thumb;
@property (nonatomic, retain) NSString *intro;
@property (nonatomic, retain) NSString *points;
@property (nonatomic, retain) NSMutableArray *images;

@end
