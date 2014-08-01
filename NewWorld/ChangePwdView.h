//
//  ChangePwdView.h
//  NewWorld
//
//  Created by Seven on 14-7-28.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangePwdView : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *oldPwdTf;
@property (strong, nonatomic) IBOutlet UITextField *newsPwdTf;
@property (strong, nonatomic) IBOutlet UITextField *newsPwdAgainTf;

- (IBAction)changeAction:(id)sender;

@end
