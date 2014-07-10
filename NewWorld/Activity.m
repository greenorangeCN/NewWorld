//
//  Activity.m
//  NewWorld
//
//  Created by Seven on 14-6-30.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import "Activity.h"

@implementation Activity

@synthesize _id;
@synthesize title;
@synthesize thumb;
@synthesize indexImg;
@synthesize summary;
@synthesize validityTime;
@synthesize condition;
@synthesize telephone;
@synthesize qq;
@synthesize counts;
@synthesize published;
@synthesize imgData;
@synthesize points;

- (id)initWithParameters:(NSString *)aID andTitle:(NSString *)aTitle andThumb:(NSString *)aThumb andIndexImg:(NSString *)aIndexImg andSummary:(NSString *)aSummary andValidityTime:(NSString *)aValidityTime andCondition:(NSString *)aCondition andTelephone:(NSString *)aTelephone andQQ:(NSString *)aQQ andCounts:(NSString *)aCounts andPublished:(NSString *)aPublished andPoints:(NSString *)aPoints
{
    Activity *a = [[Activity alloc] init];
    a._id = aID;
    a.title = aTitle;
    a.thumb = aThumb;
    a.indexImg = aIndexImg;
    a.summary = aSummary;
    a.validityTime = aValidityTime;
    a.condition = aCondition;
    a.telephone = aTelephone;
    a.qq = aQQ;
    a.counts = aCounts;
    a.published = aPublished;
    a.points = aPoints;
    return a;
}

@end
