//
//  LoginViewController.h
//  Footmarks
//
//  Created by casey graika on 5/22/13.
//  Copyright (c) 2013 Footmarks Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Footmarks_SDK.h"
#import "UICKeyChainStore.h"
#import "RetryView.h"

typedef enum : int
{
    LoginStateBegin,
    LoginStateAuthnApp,
    LoginStateAuthnAppFailed,
    LoginStateAuthnUser,
    LoginStateAuthnUserInProgress,
    LoginStateAuthnUserFailed,
    LoginStateAuthnUserSucess
} LoginState;

@interface LoginViewController : UIViewController <FMAccountDelegate, UIAlertViewDelegate, UITextFieldDelegate, RetryViewDelegate>

- (IBAction)clearCredsSelected:(id)sender;
- (IBAction)loginBtnSelected:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *viewImgContainer;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldUsername;
@property (weak, nonatomic) IBOutlet UITextField *txtFieldPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indLogin;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnClearCreds;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *btnLogin;
@property (weak, nonatomic) IBOutlet UIView *viewLogin;
@property int loginAttempts;
@property BOOL fieldsEntered;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblMobileSavings;
@property (weak, nonatomic) IBOutlet UIView *viewSpinContainer;


- (void) clearStoredUserCreds;
- (void)login;

- (void)initialize;
@end
