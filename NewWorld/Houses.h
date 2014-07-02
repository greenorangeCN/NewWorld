//
//  Houses.h
//  NewWorld
//
//  Created by Seven on 14-6-30.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+RMArchivable.h"

@interface Houses : NSObject

@property (nonatomic, retain) NSString* id;
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* longitude;
@property (nonatomic, retain) NSString* latitude;
@property (nonatomic, retain) NSString* telephone;
@property (nonatomic, retain) NSMutableArray* zhoubian_items;

@end
