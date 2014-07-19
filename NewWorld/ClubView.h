//
//  ClubView.h
//  NewWorld
//
//  Created by Seven on 14-7-17.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Club.h"
#import "ClubCell.h"
#import "EGOImageView.h"
#import "UITap.h"
#import "ClubDetailView.h"

@interface ClubView : UIViewController<UITableViewDelegate,UITableViewDataSource>
{
    MBProgressHUD *hud;
    Club *club;
    NSMutableArray *clubItems;
}

@property (strong, nonatomic) NSString *communityId;

@property (strong, nonatomic) IBOutlet UIImageView *clubInfoIv;
@property (strong, nonatomic) IBOutlet UITableView *clubItemTable;

@end
