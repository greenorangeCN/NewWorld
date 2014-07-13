//
//  RegisterView.h
//  NewWorld
//
//  Created by Seven on 14-7-10.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HousesProject.h"

@interface RegisterView : UIViewController<UIActionSheetDelegate,UIPickerViewDelegate>
{
    NSMutableArray *pickerData;
    NSMutableArray *projects;
    ASIFormDataRequest *request;
    NSString *projectId;
}
@property (strong, nonatomic) IBOutlet UITextField *userNameTf;
@property (strong, nonatomic) IBOutlet UITextField *passwordTf;
@property (strong, nonatomic) IBOutlet UITextField *passwordagainTf;
@property (strong, nonatomic) IBOutlet UITextField *projectNameTf;
- (IBAction)selectAreaAction:(id)sender;
- (IBAction)registerAction:(id)sender;

@property (strong, nonatomic) UIActionSheet *actionSheet;
@property (strong, nonatomic) UIPickerView *projectPicker;
@end
