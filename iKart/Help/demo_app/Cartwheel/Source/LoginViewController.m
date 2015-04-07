//
//  LoginViewController.m
//  Footmarks
//
//  Created by casey graika on 5/22/13.
//  Copyright (c) 2013 Footmarks Inc. All rights reserved.
//

#import "LoginViewController.h"
#import "ConnectionStatusHelper.h"
#import "AppDelegate.h"
#import "RTSpinKitView.h"
#import "Helpers.h"
#import "OffersViewController.h"
#import "ExperienceNotificationListingViewController.h"
#import "Credentials.h"

#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)

#define RETRY_TAG_APP_AUTHN 2
#define RETRY_TAG_USER_AUTHN 3
#define LOGIN_BTN_SPACING 20.0
#define KEYCHAIN_USERNAME @"username"
#define KEYCHAIN_PASSWORD @"password"


@interface LoginViewController ()
{
    BOOL hasCreds;
    NSString *username;
    NSString *userPassword;
    NSString *bunId;
    ConnectionStatusHelper *conStatus;
    LoginState loginState;
    RTSpinKitView *spinner;
    FMAccount *fmAccount;
}

@property (retain, nonatomic) IBOutlet RTSpinKitView *spin2;


@end

@implementation LoginViewController


const int btnLoginWidth = 200;
const int btnLoginHeight = 40;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    fmAccount = [FMAccount sharedInstance];
    bunId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
    /************************************************************
     *                  ~~ Important ~~
     *
     *  Its your responsibility to intialize the view 
     *  controllers to handle any display and storage for 
     *  the experiences. Once you receive the experiences, 
     *  you may do as you like. But understand, when the 
     *  app quits, the app will reintialize from an
     *  enter region event. So you must reintialize your
     *  view controllers.
     *
     *
     ************************************************************/
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    appDelegate.offersViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OffersViewController"];
    self.fieldsEntered = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
}

- (void) awakeFromNib
{
    bunId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];

}

- (void)viewDidUnload
{
    [self setBtnLogin:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self initialize];
}
- (void)initialize
{
    [self insertSpinnerOfStyle: RTSpinKitViewStyle9CubeGrid];
    loginState = LoginStateAuthnApp;
    [self updateUIForLoginState];
    conStatus = [[ConnectionStatusHelper alloc] initWithViewToDisplayAlertOn:self.view];
    [self.txtFieldUsername setDelegate:self];
    [self.txtFieldPassword setDelegate:self];
    [[FMAccount sharedInstance] setAccountDelegate:self];
    self.loginAttempts = 0;
    [self authenticateApp];

}

- (IBAction)loginBtnSelected:(id)sender
{
    [self.btnLogin setHidden:YES];
    [self login];
}

- (void) moveTxtFieldsToCenter
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.viewImgContainer setHidden:YES];
    CGRect f1 = self.viewLogin.frame;
        f1.origin.y = f1.origin.y - 200.f;
        [self.viewLogin setFrame:f1];
        
    });
}

- (void) updateUIForLoginState
{
       dispatch_async(dispatch_get_main_queue(), ^{
    if(loginState == LoginStateBegin)
    {
        [self.txtFieldPassword setHidden:YES];
        [self.txtFieldUsername setHidden:YES];
        [spinner startAnimating];
        
        [self.btnLogin setHidden:YES];
        [self.btnClearCreds setHidden:YES];
        [self.lblStatus setText:@""];
        [self.lblStatus setHidden:YES];
    }
    else if(loginState == LoginStateAuthnApp)
    {
        [self.txtFieldPassword setHidden:YES];
        [self.txtFieldUsername setHidden:YES];
        [spinner startAnimating];
        [self.btnLogin setHidden:YES];
        [self.btnClearCreds setHidden:YES];
        [self.lblStatus setText:@"Authenticating app. Please wait..."];
        [self.lblStatus setHidden:NO];
    }
    else if(loginState == LoginStateAuthnAppFailed)
    {
        [self.txtFieldPassword setHidden:YES];
        [self.txtFieldUsername setHidden:YES];
        [spinner stopAnimating];
        [self.btnLogin setHidden:YES];
        [self.btnClearCreds setHidden:YES];
        [self.lblStatus setText:@""];
        [self.lblStatus setHidden:YES];
        [self showRetryViewWithText:@"App Authentication failed." andTag:RETRY_TAG_APP_AUTHN];
    }
    else if(loginState == LoginStateAuthnUser)
    {
        [self.txtFieldPassword setHidden:NO];
        [self.txtFieldUsername setHidden:NO];
        [spinner stopAnimating];
        [self.btnLogin setHidden:NO];
        [self.btnClearCreds setHidden:NO];
        [self.lblStatus setText:@""];
        [self.lblStatus setHidden:YES];
    }
    else if(loginState == LoginStateAuthnUserInProgress)
    {
        [self.txtFieldPassword setHidden:YES];
        [self.txtFieldUsername setHidden:YES];
        [spinner startAnimating];
        [self.btnLogin setHidden:YES];
        [self.btnClearCreds setHidden:YES];
        [self.lblStatus setText:@"Authenticating user. Please wait..."];
        [self.lblStatus setHidden:NO];
    }
    else if(loginState == LoginStateAuthnUserFailed)
    {
        [self.txtFieldPassword setHidden:NO];
        [self.txtFieldUsername setHidden:NO];
        [spinner stopAnimating];
        [self.btnLogin setHidden:NO];
        [self.btnClearCreds setHidden:NO];
        [self.lblStatus setText:@""];
        [self.lblStatus setHidden:YES];
        [self showRetryViewWithText:@"User Authentication failed. Please retry." andTag:RETRY_TAG_USER_AUTHN];
    }
    else if(loginState == LoginStateAuthnUserSucess)
    {
        [self.txtFieldPassword setHidden:YES];
        [self.txtFieldUsername setHidden:YES];
        [spinner stopAnimating];
        [self.btnLogin setHidden:NO];
        [self.btnClearCreds setHidden:NO];
        [self.lblStatus setText:@""];
        [self.lblStatus setHidden:YES];
    }
    else
    {
        [self.txtFieldPassword setHidden:NO];
        [self.txtFieldUsername setHidden:NO];
        [spinner stopAnimating];
        [self.btnLogin setHidden:NO];
        [self.btnClearCreds setHidden:NO];
        [self.lblStatus setText:@""];
        [self.lblStatus setHidden:YES];
    }
      });
}

- (void)login
{
    if(loginState == LoginStateAuthnUserSucess)
    {
        UINavigationController* nc = [self.storyboard instantiateViewControllerWithIdentifier:@"OfferNav"];
        [self presentViewController:nc animated:YES completion:nil];
    }
    else
    {
        [self.txtFieldPassword resignFirstResponder];
        [self.txtFieldUsername resignFirstResponder];
        
        // Check if user credentials exist in the keychain
        BOOL credsExist = [self doCredsExist];
        if(credsExist == NO) // Retrieve creds from user input
        {
            username = self.txtFieldUsername.text;
            userPassword = self.txtFieldPassword.text;
            if([Helpers isStringNullOrEmpty:username] || [Helpers isStringNullOrEmpty:userPassword])
            {
                // TODO: Switch to Retry View
                NSString *title     = @"Login Problem";
                NSString *message   = @"Please enter your username & password into the text boxes.";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertView show];
                [self.btnLogin setHidden:NO];
                return;
            }
        }
        else // Retrieve creds from keychain
        {
            username = [[UICKeyChainStore keyChainStoreWithService:bunId] stringForKey:KEYCHAIN_USERNAME];
            userPassword = [[UICKeyChainStore keyChainStoreWithService:bunId] stringForKey:KEYCHAIN_PASSWORD];
        }
        
        [self performUserAuthentication];
    }
}

- (void) authenticateApp
{
    [fmAccount loginToFootmarksServer:FMAppKey andAppSecret:FMAppSecret andUserId:@""];
}

/***********************************************************
 *
 *   FootmarksAccount Delegate Methods
 *
 *   Note: These are the callbacks for the app's authn,
 *         not the user
 ***********************************************************/
- (void) loginSuccessful
{
    NSLog(@"\n---LOGIN SUCCESS CALLBACK----\n");
    hasCreds = [self doCredsExist];
    if(hasCreds)
    {
        loginState = LoginStateAuthnUserInProgress;
        [self updateUIForLoginState];
        [self login];
    }
    else
    {
        loginState = LoginStateAuthnUser;
       // [self moveLoginButtonBelowTxtField];
        [self updateUIForLoginState];
    }
}

- (void) loginUnsuccessful: (NSString*)error
{
    NSLog(@"\n---LOGIN NOT SUCCESSFULL CALLBACK----\n");
    loginState = LoginStateAuthnAppFailed;
    [self updateUIForLoginState];
}
// *** END FootmarksAccount Delegate Methods ****

- (void) performUserAuthentication
{
    if([Helpers isStringNullOrEmpty:username] || [Helpers isStringNullOrEmpty:userPassword])
    {
        loginState = LoginStateAuthnUserFailed;
        [self updateUIForLoginState];
        return;
    }
    else
    {
        loginState = LoginStateAuthnUserInProgress;
        [self updateUIForLoginState];
        
        NSString *urlString = AUTH_DOMAIN_NAME;
        NSDictionary *dictHeaders = [[NSDictionary alloc] initWithObjectsAndKeys:@"application/x-www-form-urlencoded",@"Content-Type", nil];
        NSString *post = [NSString stringWithFormat:@"grant_type=password&username=%@&password=%@", username, userPassword];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
        
        FMRestApi *rest = [FMRestApi new];
        [rest postWithUrl:urlString headers:dictHeaders formData:postData timeout:10.0 withCompletion:^(id responseObject, NSError *error)
         {
             if(error)
             {
                 [self clearStoredUserCreds];
                 loginState = LoginStateAuthnUserFailed;
                 [self updateUIForLoginState];
             }
             else if([responseObject isKindOfClass:[NSData class]])
             {
                 id data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
                 if([data isKindOfClass:[NSDictionary class]])
                 {
                     NSString *at = [data objectForKey:@"accessToken"];
                     if(![Helpers isStringNullOrEmpty:at])
                     {
                         NSLog(@"!! Access Token = %@ !!\n", at);
                         [[FMAccount sharedInstance] setUserAccessToken:at];
                         loginState = LoginStateAuthnUserSucess;
                         [self updateUIForLoginState];
                         [self performUserAuthnSuccess];
                     }
                     else // User authn failed
                     {
                         [self clearStoredUserCreds];
                         loginState = LoginStateAuthnUserFailed;
                         [self updateUIForLoginState];
                     }
                 }
                 else
                 {
                     [self clearStoredUserCreds];
                     loginState = LoginStateAuthnUserFailed;
                     [self updateUIForLoginState];
                 }
             }
             else
             {
                 [self clearStoredUserCreds];
                 loginState = LoginStateAuthnUserFailed;
                 [self updateUIForLoginState];
             }
         }];
    }
}

- (void) performUserAuthnSuccess
{
    self.loginAttempts = 0;
    [UICKeyChainStore setString:username forKey:KEYCHAIN_USERNAME service:bunId];
    [UICKeyChainStore setString:userPassword forKey:KEYCHAIN_PASSWORD service:bunId];
    NSLog(@"Sample App Login successful!");
    [spinner stopAnimating];
    
    if(![self.navigationController.topViewController isKindOfClass:[LoginViewController class]]){
        return;
    }
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    [self.navigationController pushViewController:appDelegate.offersViewController animated:YES];
}

// This method checks if an existing app key & secret pair lie in the keychain.
- (BOOL)doCredsExist
{
    NSString *user = [[UICKeyChainStore keyChainStoreWithService:bunId] stringForKey:KEYCHAIN_USERNAME];
    NSString *password = [[UICKeyChainStore keyChainStoreWithService:bunId] stringForKey:KEYCHAIN_PASSWORD];
    
    if( (![Helpers isStringNullOrEmpty:user]) && (![Helpers isStringNullOrEmpty:password]) )
    {
        hasCreds = YES;
        return YES;
    }
    else
    {
        hasCreds = NO;
        return NO;
    }
}

// Delete the app key and app secret pair from the iOS Keychain
-(IBAction)clearCredsSelected:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Credentials" message:@"Do you really want to clear your stored Username and Password? If you select \"YES\", you will have to re-enter your credentials" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil];
    [alert addButtonWithTitle:@"NO"];
    [alert setTag:12];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 12)
    {
        if (buttonIndex == 0) // Clicked YES.
        {
            [self clearStoredUserCreds];
            loginState = LoginStateAuthnUser;
            [self updateUIForLoginState];
        }
    }
}

- (void) clearStoredUserCreds
{
    // Delete app key & app secret pair from the key chain
    [self.txtFieldPassword setText:@""];
    [self.txtFieldUsername setText:@""];
    [UICKeyChainStore removeAllItemsForService:bunId];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void) showRetryViewWithText: (NSString*)text andTag:(int)tag
{
    BOOL doesContain = [Helpers doesView:self.view containASubviewOfClass:[RetryView class]];
    if(!doesContain)
    {
        RetryView *rv = [[RetryView alloc] initWithParentView:self.view andTitle:text];
        [rv setTag:tag];
        [rv setDelegate:self];
        [rv animateAlert];
    }
}

/***********************************************************
 *
 *   RetryView Delegate Methods
 *
 ***********************************************************/

- (void)retry: (id)sender
{
    [sender removeFromSuperview];
    if( [sender tag] == RETRY_TAG_APP_AUTHN )
    {
        loginState = LoginStateAuthnApp;
        [self updateUIForLoginState];
        [self authenticateApp];
    }
    else if([sender tag] == RETRY_TAG_USER_AUTHN)
    {
        loginState = LoginStateAuthnUserInProgress;
        [self updateUIForLoginState];
        [self performUserAuthentication];
    }
}
- (void)cancel: (id)sender
{
    [sender removeFromSuperview];
    
    if( [sender tag] == RETRY_TAG_USER_AUTHN )
    {
        loginState = LoginStateAuthnUser;
        [self updateUIForLoginState];
    }
    else if( [sender tag] == RETRY_TAG_APP_AUTHN )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Authentication failed. Please contact footmarks@support.com for help." delegate:nil cancelButtonTitle:@"YES" otherButtonTitles:nil];
        [alert show];
    }
}

// End RetryView Delegate Methods

- (void) moveLoginButtonToCenter
{
    float y = self.view.center.y;
    CGRect frame = self.btnLogin.frame;
    frame.origin.y = y;
    [self.btnLogin setFrame:frame];
}

- (void) moveLoginButtonBelowTxtField
{
    float y = self.txtFieldPassword.frame.origin.y + self.txtFieldPassword.frame.size.height + LOGIN_BTN_SPACING;
    CGRect frame = self.btnLogin.frame;
    frame.origin.y = y;
    [self.btnLogin setFrame:frame];
}
 

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissKeyboard
{
    if(self.txtFieldPassword)
    {
        if([self.txtFieldPassword isFirstResponder])
        {
            [self.txtFieldPassword resignFirstResponder];
        }
    }
    if(self.txtFieldUsername)
    {
        if([self.txtFieldUsername isFirstResponder])
        {
            [self.txtFieldUsername resignFirstResponder];
        }
    }
}

/***********************************************************
 *
 *   UITextField Delegate Methods
 *
 ***********************************************************/

#pragma mark TextField Delegate Methods

- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{

}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.txtFieldPassword resignFirstResponder];
    [self.txtFieldUsername resignFirstResponder];
    // Perform login if user filled out both the username
    // and password fields
    if([self isCredInput])
    {
        [self login];
    }
    return YES;
}

// Check user credential input
- (BOOL) isCredInput
{
    NSString *user = self.txtFieldUsername.text;
    NSString *pass = self.txtFieldPassword.text;
    if([Helpers isStringNullOrEmpty:user] || [Helpers isStringNullOrEmpty:pass])
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

// Configure Loading View
-(void)insertSpinnerOfStyle:(RTSpinKitViewStyle)style
{
    spinner = [[RTSpinKitView alloc] initWithStyle:style color:[UIColor whiteColor]];

    CGRect f = self.viewSpinContainer.frame;
    f.origin.x = self.view.center.x - (f.size.width/2);
    //self.viewSpinContainer.center = self.view.center;
    [self.viewSpinContainer setFrame:f];

    CGRect frame = self.viewSpinContainer.bounds;
    
    /*frame.origin.y = self.lblMobileSavings.frame.origin.y + self.lblMobileSavings.frame.size.height + 20.f;
    frame.origin.x = self.view.center.x - (frame.size.width/2);
     */
    [spinner setFrame:frame];
    [self.viewSpinContainer addSubview:spinner];
}


@end
