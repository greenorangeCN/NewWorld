//
//  LoginView.h
//  NewWorld
//
//  Created by Seven on 14-7-11.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJSwitch.h"

@interface LoginView : UIViewController
{
    ASIFormDataRequest *request;
}

@property (strong, nonatomic) IBOutlet UITextField *userNameTf;
@property (strong, nonatomic) IBOutlet UITextField *passwordTf;
@property (strong, nonatomic) IBOutlet UILabel *switchLb;
- (IBAction)loginAction:(id)sender;

@end
