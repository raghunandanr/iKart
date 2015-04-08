//
//  ViewController.m
//  iKart
//
//  Created by Raghunandan on 07/04/15.
//  Copyright (c) 2015 NullAndVoid. All rights reserved.
//

#import "ViewController.h"
#import "Footmarks_SDK.h"
#import "Credentials.h"
#import "ExperienceManager.h"
#import "Helpers.h"
#import "ExperienceView.h"
#import "NotifHelper.h"
#import "OfferView.h"
#import "AppDelegate.h"


static NSInteger _staticToSaveIncrement = 0;

static const NSInteger kToSaveIncrementCap = 5;

@interface ViewController () {
    
        FMAccount *fmAccount;
}

@property (nonatomic, strong, readonly) AppDelegate *appDelegate;
@property (nonatomic, retain) FMBeaconManager *beaconManager;

@property (nonatomic, retain) FMExperienceManager *experienceManager;

@property (nonatomic, strong) NSMutableDictionary *dictOfferViews;

@property (nonatomic) BOOL isPresentingOfferView;

@property (nonatomic, retain) FMExperience *curNotifExp;

@property (retain, nonatomic)  UIView *viewNotification;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    fmAccount = [FMAccount sharedInstance];
    
    [[FMAccount sharedInstance] setAccountDelegate:self];
    [self authenticateApp];
    
    // The app delegate will call this instance to pass the experiences it receives.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDelegateDidCompleteExperiences)
                                                 name:@"CartwheelAppDelegateDidCompleteExperiences"
                                               object:nil];
    
    self.viewNotification = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 51)];
    [self.viewNotification setHidden:YES];
    self.viewNotification.layer.borderColor = [UIColor yellowColor].CGColor;
    self.viewNotification.layer.borderWidth = 3.0f;
    [self.viewNotification setBackgroundColor:[UIColor colorWithWhite:0 alpha:.8]];
    [self.view addSubview:self.viewNotification];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 217, 41)];
    [titleLabel setTag:1];
    [self.viewNotification addSubview:titleLabel];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    
    /************************************************************
     *                  ~~ Important ~~
     *
     *   Beacon scanning for Footmarks beacons in the class you
     *   would like to handle beacon events.
     *
     ************************************************************/
    if(![self.beaconManager isScanningForBeacons])
    {
        NSError *error = nil;
        [[FMBeaconManager sharedInstance] startScanningForFMBeaconsWithError:&error];
        if (error) {
            // Process the error according to the localize description. You don't have
            // recall the start scanning as the sdk will remember once comply to the errors.
        } else {
            // Look for experiences come in from the AppDelegate
        }
    }
    
    BOOL inForeground = [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
    if (inForeground) {
        [ExperienceManager fetchProfiles];
    }
    
}

- (void) viewWillAppear:(BOOL)animated
{

    [self attemptToPlayVideoIfThereIsOne];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) handleEnterForeground: (NSNotification*) sender
{
    [self attemptToPlayVideoIfThereIsOne];
}

- (void) attemptToPlayVideoIfThereIsOne
{
    ExperienceView *presentingOV = [self getTopExperienceView];
    if(presentingOV)
    {
        if([presentingOV getOfferViewExperience].type == FMExperienceTypeVideo)
        {
            if([presentingOV hasPlayedVideo] == NO)
            {
                [presentingOV setHidden:NO];
                [presentingOV playVideo];
            }
        }
    }
}


- (ExperienceView*) getTopExperienceView
{
    @try {
        NSInteger i = -1;
        NSArray *arr = [self.view subviews];
        
        if(arr)
        {
            // Find index of top-most OfferView (presenting view)
            for(UIView *v in arr)
            {
                if([v isKindOfClass:[ExperienceView class]])
                {
                    i = [arr indexOfObject:v];
                }
            }
            
            if(i != -1)
            {
                ExperienceView *ov = [arr objectAtIndex:i];
                return ov;
            }
            else
            {
                return nil;
            }
        }
        else{
            return nil;
        }
    }
    @catch (NSException *exception) {
        return nil;
    }
}


- (BOOL)isApplicationInForeground {
    return [UIApplication sharedApplication].applicationState == UIApplicationStateActive;
}

- (void)presentExperience:(FMExperience *)experience
{
    if (!experience) {
        NSLog(@"Experience is NIL");
    }
    
    switch (experience.type)
    {
        case FMExperienceTypeCustom:
        {
            self.isPresentingOfferView = YES;
            OfferView *oView = [[OfferView alloc] initWithNibAndExperience:experience andParentVC:self];
            [self.dictOfferViews setObject:oView forKey:experience.expId];
            break;
        }
            
        case FMExperienceTypeUrl:
        {
            ExperienceView *uView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
            [uView configureWebExp];
            [self.dictOfferViews setObject:uView forKey:experience.expId];
            break;
        }
            
        case FMExperienceTypeHtml:
        {
            ExperienceView *hView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
            self.isPresentingOfferView = YES;
            [hView configureWebExp];
            [self.dictOfferViews setObject:hView forKey:experience.expId];
            break;
        }
            
        case FMExperienceTypeImage:
        {
            ExperienceView *iView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
            self.isPresentingOfferView = YES;
            [iView configureNonWebExp];
            [self.dictOfferViews setObject:iView forKey:experience.expId];
            break;
        }
            
        case FMExperienceTypeVideo:
        {
            ExperienceView *vView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
            self.isPresentingOfferView = YES;
            [vView configureNonWebExp];
            [self.dictOfferViews setObject:vView forKey:experience.expId];
            break;
        }
            
        case FMExperienceTypeAlert:
        {
            // Handle Alert experience however you would like
            break;
        }
            
        default:
        {
            break;
        }
    } // end switch(experience type)
    
    ExperienceView *ov = [self.dictOfferViews objectForKey:experience.expId];
    if (ov) {
        [self addOfferOrExperienceViewToView:ov];
    }
    
}

-(void)handleSingleExperienceInForeground:(FMExperience *)experience
{
    
  //  if(![self doesExperienceExistAlready:experience.expId])
    {
        if( ![Helpers isStringNullOrEmpty:experience.name] )
        {
            NotifHelper *nh = [[NotifHelper alloc] init];
            NSString *title = experience.alertTitle;
            NSLog(@"!!!! handleSingleExperienceInForeground(): Showing notification with title %@ !!!!!", title);
            
            [nh showNotificationWithText:title];
        }
        switch (experience.type)
        {
            case FMExperienceTypeCustom:
            {
                self.isPresentingOfferView = YES;
                OfferView *oView = [[OfferView alloc] initWithNibAndExperience:experience andParentVC:self];
                [self.dictOfferViews setObject:oView forKey:experience.expId];
                [ExperienceManager addExperience:experience];
                
                [self determineHowToPresentExperience:experience withView:oView];
                break;
            }
                
            case FMExperienceTypeUrl:
            {
                ExperienceView *uView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
                [uView configureWebExp];
                [self.dictOfferViews setObject:uView forKey:experience.expId];
                [ExperienceManager addExperience:experience];
                
                [self determineHowToPresentExperience:experience withView:uView];
                break;
            }
                
            case FMExperienceTypeHtml:
            {
                ExperienceView *hView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
                self.isPresentingOfferView = YES;
                [hView configureWebExp];
                [self.dictOfferViews setObject:hView forKey:experience.expId];
                [ExperienceManager addExperience:experience];
                [self determineHowToPresentExperience:experience withView:hView];
                break;
            }
                
            case FMExperienceTypeImage:
            {
                ExperienceView *iView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
                self.isPresentingOfferView = YES;
                [iView configureNonWebExp];
                [self.dictOfferViews setObject:iView forKey:experience.expId];
                [ExperienceManager addExperience:experience];
                [self determineHowToPresentExperience:experience withView:iView];
                break;
            }
                
            case FMExperienceTypeVideo:
            {
                ExperienceView *vView = [[ExperienceView alloc] initWithNibAndExperience:experience andParentVC:self];
                self.isPresentingOfferView = YES;
                [vView configureNonWebExp];
                [self.dictOfferViews setObject:vView forKey:experience.expId];
                [ExperienceManager addExperience:experience];
                [self determineHowToPresentExperience:experience withView:vView];
                break;
            }
                
            case FMExperienceTypeAlert:
            {
                // Handle Alert experience however you would like
                self.curNotifExp = nil; // this is to prevent a previous experience to be activated.
                [ExperienceManager addExperience:experience];
                [self showNotifForExperience:experience];
                break;
            }
            default:
            {
                break;
            }
        } // end switch(experience type)
    } // end if the experience did not already exist
}

- (void) determineHowToPresentExperience: (FMExperience*)exp withView:(UIView*)v
{
    self.curNotifExp = exp;
    
    /************************************************************
     *                  ~~ Important ~~
     *
     * The below method informServerOfConvertedExperience(),
     * shows an example of how to let the Footmarks server know
     * that the user took some action on a given Experience.
     * Using this functionality will provide for much more robust
     * analytics.
     *
     ************************************************************/
    [self informServerOfConvertedExperience:exp];
    if(exp.action == FMExperienceActionPrompt || exp.type == FMExperienceTypeAlert)
    {
        [self showNotifForExperience:exp];
    }
    else
    {
        [self addOfferOrExperienceViewToView:v];
    }
}

- (void) showAllStoredExperienceViews
{
    NSArray *arr = [[ExperienceManager defaultManager ] experiences];
    for(FMExperience *exp in arr)
    {
        UIView *v = [self.dictOfferViews objectForKey:exp.expId];
        if(v)
        {
            [self addOfferOrExperienceViewToView:v];
        }
    }
    [ExperienceManager removeAllExperiences];
}

- (void) addOfferOrExperienceViewToView: (UIView*)v
{
    if([v isKindOfClass:[ExperienceView class]])
    {
        FMExperience *exp = [(ExperienceView*)v getOfferViewExperience];
        if(exp.type == FMExperienceTypeVideo)
        {
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
            {
                if([self.navigationController.visibleViewController isKindOfClass:[ViewController class]])
                {
                    [self.view addSubview:v];
                    [(ExperienceView*)v playVideo];
                    return;
                }
            }
        }
    }
    [self.navigationController.view addSubview:v];
}


- (void) showNotifForExperience: (FMExperience*)exp
{
    [self.viewNotification setAlpha:0.0];
    [self.viewNotification setHidden:NO];
    UILabel *notifLabel = (id)[self.viewNotification viewWithTag:1];
    
    NSString *title = exp.alertTitle;
    
    // set a cap limit of length of the title
    if (title.length > 200)
        title = [title substringToIndex:200];
    
    // set label
    [notifLabel setText:title];
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.viewNotification setAlpha:1.0];
        
    } completion:^(BOOL finished)
     {
         [self.viewNotification setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.8]];
         int64_t delayInSeconds = 4.0;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             if(self.viewNotification.hidden == NO)
             {
                 [self hideNotifViewOfExperience:exp];
             }
         });
     }];
}


- (void) hideNotifViewOfExperience: (FMExperience*)exp
{
    [self.viewNotification setAlpha:1.0];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self.viewNotification setAlpha:0.0];
        
    } completion:^(BOOL finished)
     {
         // don't show badge if alert
         if(exp.type == FMExperienceTypeAlert) return;
         
         [self.viewNotification setHidden:YES];
     }];
}

// NOTE: This method provides an example of how to inform the Footmarks
// server that the user took some action on a given experience. The data
// used in the fields below is fake for this example. If you use this method
// make sure to adjust the data to make it dynamic. For instance, place the
// real number of seconds the user watched a video for, etc.
- (void) informServerOfConvertedExperience: (FMExperience*)exp
{
    float testWatchTime = 30.f;
    switch(exp.type)
    {
        case FMExperienceTypeVideo:
            [exp sendConvertedExperienceWithType:FMConvertedActionWatched valueType:FMConvertedValueTypeSeconds andValue:testWatchTime];
            break;
            
        case FMExperienceTypeUrl:
            [exp sendConvertedExperienceWithType:FMConvertedActionOpened valueType:FMConvertedValueTypeQuantity andValue:1.f];
            break;
            
        case FMExperienceTypeHtml:
            [exp sendConvertedExperienceWithType:FMConvertedActionOpened valueType:FMConvertedValueTypeQuantity andValue:1.f];
            break;
            
        case FMExperienceTypeAlert:
            [exp sendConvertedExperienceWithType:FMConvertedActionSwiped valueType:FMConvertedValueTypeQuantity andValue:1.f];
            break;
            
        case FMExperienceTypeImage:
            [exp sendConvertedExperienceWithType:FMConvertedActionShared valueType:FMConvertedValueTypeQuantity andValue:10.f];
            break;
            
        case FMExperienceTypePassive:
            [exp sendConvertedExperienceWithType:FMConvertedActionOpened valueType:FMConvertedValueTypeQuantity andValue:1.f];
            break;
            
        case FMExperienceTypeCustom:
            [exp sendCustomConvertedExperienceWithType:FMConvertedActionCustom andCustomActionName:@"In Zone 1" valueType:FMConvertedValueTypeMinutes andCustomValueName:@"" andValue:20.f];
            break;
            
        default:
            break;
    }
}



- (void)newPresentedExperience:(FMExperience*)exp
{
    
}

- (void) removeExperienceViewWithExpId: (NSString*)expId
{
    [self.dictOfferViews removeObjectForKey:expId];
}

- (BOOL) doesExperienceExistAlready: (NSString*)eid
{
    if([Helpers isStringNullOrEmpty:eid])
    {
        return NO;
    }
    NSArray *experiences = [ExperienceManager unreadExperiences];
    for(FMExperience *e in experiences)
    {
        if(![Helpers isStringNullOrEmpty:e.expId])
        {
            if([e.expId isEqualToString:eid])
            {
                NSLog(@"Experience %@ already exists", eid);
                return YES;
            }
        }
    }
    return NO;
}


- (void)appDelegateDidCompleteExperiences
{
    //NSLog(@"Notification Callback for CartwheelAppDelegateDidCompleteExperiences");
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [self didCompleteExperiences:appDelegate.experiences];
}

-(void)didCompleteExperiences:(NSArray *)experiences
{
    //    NSLog(@"Did Complete Exeriences: %@", experiences);
    // For certain type of experience, it can either alert the user of
    //  the notifiction or automaticall display the user of the experience
    //  content.
    if (experiences.count == 1 && [self isApplicationInForeground]) {
        
        FMExperience *experience = experiences.firstObject;

        
        // If notification experience view is not shown, handle the
        //  single experience.

            [self handleSingleExperienceInForeground:experience];
            
            // Save experiences if pass the increment cap limit.
            _staticToSaveIncrement++;
            if (_staticToSaveIncrement > kToSaveIncrementCap) {
                _staticToSaveIncrement = 0;
                [ExperienceManager save];
            
            return;
        }
    }
    
    NSMutableArray *notificationExperiences = [NSMutableArray array];
    NSMutableArray *popupExperiences = [NSMutableArray array];
    for(FMExperience *experience in experiences)
    {
        /*
         NOTE: For demo purposes, I added logic to prevent
         the app from displaying multiple copies of the same
         experience. This can and should be controlled server-side,
         but I added logic here as well just in case someone
         configures their experience to deliver multiple copies of
         the same experience to the same user.
         */
      //  if(![self doesExperienceExistAlready:experience.expId])
        {
            BOOL markRead = !(experience.action == FMExperienceActionPrompt ||
                              experience.type == FMExperienceTypeAlert);
            
            [ExperienceManager addExperience:experience markRead:markRead];
            
            // popups will be automatically be display to the user.
            //   no need to mark as unread.
            if (markRead) {
                [popupExperiences addObject:experience];
            } else {
                [notificationExperiences addObject:experience];
            }
        } // end if the experience did not already exist
        
        // Display notification if in background
        NotifHelper *nh = [[NotifHelper alloc] init];
        NSString *title = experience.alertTitle;
        NSLog(@"!!!! didCompleteExperiences: Showing notification with title %@ !!!!!", title);
        [nh showNotificationWithText:title];
    } // end for loop of experiences
    
    
    if (notificationExperiences.count > 0 ||
        popupExperiences.count > 0) {
        // Save experiences if pass the increment cap limit.
        [self saveExperiences];
    }

}

- (void)saveExperiences
{
    _staticToSaveIncrement++;
    if (_staticToSaveIncrement > kToSaveIncrementCap) {
        _staticToSaveIncrement = 0;
        [ExperienceManager save];
    }
}


- (void) authenticateApp
{
    [fmAccount loginToFootmarksServer:FMAppKey andAppSecret:FMAppSecret andUserId:@""];
}

- (void) loginUnsuccessful: (NSString*)error
{
    NSLog(@"\n---LOGIN NOT SUCCESSFULL CALLBACK----\n");
}

- (void) loginSuccessful
{
    NSLog(@"\n---LOGIN SUCCESS CALLBACK----\n");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
