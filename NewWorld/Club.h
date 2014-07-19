//
//  Club.h
//  NewWorld
//
//  Created by Seven on 14-7-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClubInfo.h"
#import "ClubItem.h"

@interface Club : NSObject

@property (nonatomic, retain) ClubInfo *club_info;
@property (nonatomic, retain) NSMutableArray *club_items;

@end
