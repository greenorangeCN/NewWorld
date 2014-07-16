//
//  UserInfoView.h
//  NewWorld
//
//  Created by Seven on 14-7-13.
//  Copyright (c) 2014年 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VPImageCropperViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "EGOImageView.h"
#import "NSString+STRegex.h"

@interface UserInfoView : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, VPImageCropperDelegate>
{
    EGOImageView *faceEGOImageView;
}

@property (strong, nonatomic) IBOutlet UITextField *nicknameTf;
@property (strong, nonatomic) IBOutlet UITextField *phoneTf;
@property (strong, nonatomic) IBOutlet UITextField *addressTf;
@property (strong, nonatomic) IBOutlet UITextField *emailTf;
@property (strong, nonatomic) IBOutlet UITextField *nameTf;
@property (strong, nonatomic) IBOutlet UITextField *idTf;
@property (strong, nonatomic) IBOutlet UIImageView *faceIv;
- (IBAction)saveInfoAction:(id)sender;

@end
