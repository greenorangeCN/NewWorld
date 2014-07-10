//
//  Activity.h
//  NewWorld
//
//  Created by Seven on 14-6-30.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Activity : NSObject

@property (nonatomic, copy) NSString * _id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *thumb;
@property (nonatomic, copy) NSString *indexImg;
@property (nonatomic, copy) NSString *summary;
@property (nonatomic, copy) NSString *validityTime;
@property (nonatomic, copy) NSString *condition;
@property (nonatomic, copy) NSString *telephone;
@property (nonatomic, copy) NSString *qq;
@property (nonatomic, copy) NSString *counts;
@property (nonatomic, copy) NSString *published;
@property (retain,nonatomic) UIImage *imgData;
@property (nonatomic, copy) NSString *points;

- (id)initWithParameters:(NSString *)aID
                andTitle:(NSString *)aTitle
                andThumb:(NSString *)aThumb
             andIndexImg:(NSString *)aIndexImg
              andSummary:(NSString *)aSummary
         andValidityTime:(NSString *)aValidityTime
            andCondition:(NSString *)aCondition
            andTelephone:(NSString *)aTelephone
                   andQQ:(NSString *)aQQ
               andCounts:(NSString *)aCounts
            andPublished:(NSString *)aPublished
               andPoints:(NSString *)aPoints;

@end
