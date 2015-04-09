//
//  OffersTableViewController.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/1/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//



#import "OffersViewController.h"
@import CoreData;

#import "AppDelegate.h"
#import "OffersManager.h"
#import "ExperienceManager.h"
#import "OfferCell.h"
#import "Helpers.h"
#import "NotifHelper.h"
#import "ExperienceView.h"
#import "OfferView.h"
#import "UIButton+Extensions.h"
#import "BadgeView.h"
#import "UIWindow+PazLabs.h"
#import "LoginViewController.h"
#import "ExperienceNotificationListingViewController.h"
#import "ExperienceListTableViewController.h"
#import "AppDelegate.h"

static NSInteger _staticToSaveIncrement = 0;

static const NSInteger kToSaveIncrementCap = 5;

static NSString *const BarcodeCellIdentifier = @"BarcodeCell";

@interface OffersViewController ()<ExperiencesViewControllerDelegate, ExperienceViewDelegate, ExperienceListTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnNavRefresh;

@property (nonatomic, strong, readonly) NSFetchRequest *fetchRequest;

@property (nonatomic, strong, readonly) NSArray *items;

@property (nonatomic, strong, readonly) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, retain) FMBeaconManager *beaconManager;

@property (nonatomic, retain) FMExperienceManager *experienceManager;

@property (nonatomic, strong) NSMutableDictionary *dictOfferViews;

@property (nonatomic, retain) REMenu *menu;

@property (nonatomic, retain) FMExperience *curNotifExp;

@property (nonatomic, weak) ExperienceNotificationListingViewController *experienceNotificationListingVC;

@property (nonatomic) BOOL presenting;

@property (nonatomic) BOOL isPresentingOfferView;

@property (nonatomic, retain) BadgeView *badgeView;

@property (weak, nonatomic) IBOutlet UIView *viewNotification;

@property (weak, nonatomic) IBOutlet UIButton *btnNotif;

@property (weak, nonatomic) IBOutlet UIImageView *imgNotifView;

@property id logoutObserver;

@property BOOL didLogout;

-(IBAction)clickedBtnNotif:(id)sender;

@end

@implementation OffersViewController

#pragma mark - View Controller Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureBadgeView];
    self.dictOfferViews = [NSMutableDictionary new];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnterForeground:)
                                                 name: @"CartwheelAppWillEnterForeground"
                                               object: nil];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Logo-bkgnd"]];
    [self.view setOpaque:NO];
    [self.view.layer setOpaque:NO];
    [self configureREMenu];
    self.isPresentingOfferView = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(viewDismissed)
                                                 name:@"ExperienceViewDismissed" object:nil];
    
    [self.viewNotification setHidden:YES];
    self.viewNotification.layer.borderColor = [UIColor yellowColor].CGColor;
    self.viewNotification.layer.borderWidth = 3.0f;
    [self.viewNotification setBackgroundColor:[UIColor colorWithWhite:0 alpha:.8]];
    
    // The app delegate will call this instance to pass the experiences it receives.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDelegateDidCompleteExperiences)
                                            name:@"CartwheelAppDelegateDidCompleteExperiences"
                                               object:nil];
    

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
    
    [self fetchData];
}

- (void)awakeFromNib
{
    self.didLogout = NO;
    __unsafe_unretained OffersViewController *this = self;
    self.logoutObserver = [[NSNotificationCenter defaultCenter] addObserverForName:kFMDemoAppLogoutNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note)
                           {
                               NSLog(@"\n\nDemo App logout notification received.\n\n");
                                [this logoutOfApp];
                           }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [self refreshTable];
    [self attemptToPlayVideoIfThereIsOne];
}

-(void)dealloc {
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self.logoutObserver];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[ExperienceListTableViewController class]]){
        ExperienceListTableViewController *vc = segue.destinationViewController;
        [vc setDelegate:self];
    }
}

- (void)experienceListTableViewControllerDidSelectExperience:(FMExperience *)experience
{
    [self presentExperience:experience];
}

#pragma mark - Internal Methods

- (void)openExperienceNotificationListingWithExperiences:(NSArray *)experiences
{
    if (!experiences || experiences.count == 0) return;
    
    // if exist, must already be presenting. so add the experiences
    if (_experienceNotificationListingVC) {
        NSLog(@"Add new experiences to already existing list");
        [_experienceNotificationListingVC addExperiences:experiences];
        return;
    }
    
    //NSLog(@"Create new experiences view controller");
    ExperienceNotificationListingViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"experiencesViewController"];
    [vc setDelegate:self];
    _experienceNotificationListingVC = vc;
    
    // set experiences
    [vc addExperiences:[ExperienceManager unreadExperiences]];
    
    // dismiss badge
    [self.badgeView setHidden:YES];
    
    // add view controller to the top of the screen
    [self.navigationController addChildViewController:vc];
    [self.navigationController.view addSubview:vc.view];
    
    
    // animate experiences view controller to be open
    [vc.view setAlpha:0];
    [UIView animateWithDuration:1.0f animations:^{
        [vc.view setAlpha:1];
    }];
}

- (void) handleEnterForeground: (NSNotification*) sender
{
    [self attemptToPlayVideoIfThereIsOne];
}

- (void) configureBadgeView
{
    self.badgeView = [[BadgeView alloc] initWithNib];
    [self.badgeView.btnBadge addTarget:self action:@selector(badgeBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [self.badgeView setHidden:YES]; // hide initially
    
    // add the button to the navigation bar
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.badgeView];
    [self.navigationItem setLeftBarButtonItems:@[self.navigationItem.leftBarButtonItem, item]];
    
    NSArray *unreadExperiences = [ExperienceManager unreadExperiences];
    if (unreadExperiences.count > 0) {
        [self showBadgeWithIncreaseBadgeCount:unreadExperiences.count];
    }
}

-(void)willOpenMenu:(REMenu *)menu
{
}
-(void)didOpenMenu:(REMenu *)menu
{

}
-(void)willCloseMenu:(REMenu *)menu
{
}
-(void)didCloseMenu:(REMenu *)menu
{
    
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

- (void)newPresentedExperience:(FMExperience*)exp
{
    
}


-(void)fetchData {
    if (!self.fetchRequest) {
        _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:OfferEntityName];
    }
    
    if (!self.appDelegate) {
        _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    }
    
    _items = nil;
    
    if (self.fetchRequest)
    {
        _items = [self.appDelegate.managedObjectContext executeFetchRequest:self.fetchRequest error:nil];
    }
    else {
        _items = @[];
    }
    
    [self.tableView reloadData];
}

- (IBAction)refresh:(id)sender
{
    [self refreshTable];
}

-(void)viewDismissed {
    self.presenting = NO;
    [self fetchData];
    [self.tableView reloadData];
}

- (void) refreshTable
{
    [OffersManager resetOffers];
    [OffersManager loadOffers];
    [self fetchData];
}

- (void) logoutOfApp
{
    self.didLogout = YES;
    LoginViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [vc clearStoredUserCreds];
    [[FMBeaconManager sharedInstance] stopScanningForFMBeacons];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) configureREMenu
{
    REMenuItem *logoutItem = [[REMenuItem alloc] initWithTitle:@"Logout"
                                                      subtitle:@"Logout of App"
                                                         image:[UIImage imageNamed:@"exitwhite"]
                                              highlightedImage:nil
                                                        action:^(REMenuItem *item)
                              {
                                  [self logoutOfApp];
                              }];
    
    REMenuItem *resetItem = [[REMenuItem alloc] initWithTitle:@"Reset"
                                                     subtitle:@"Reset offer table."
                                                        image:[UIImage imageNamed:@"spinnerwhite"]
                                             highlightedImage:nil
                                                       action:^(REMenuItem *item) {
                                                           [self refreshTable];
                                                           
                                                       }];
    
    
    self.menu = [[REMenu alloc] initWithItems:@[logoutItem, resetItem]];
    [self.menu setDelegate:self];
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
    
    if(![self doesExperienceExistAlready:experience.expId])
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
                if([self.navigationController.visibleViewController isKindOfClass:[OffersViewController class]])
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

- (void) displayViewWithExperience: (FMExperience*)exp
{
    
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
         
         [self.badgeView incrementBadgeCount];
         [self.badgeView setHidden:NO];
         [self.viewNotification setHidden:YES];
     }];
}

- (void)showBadgeWithIncreaseBadgeCount:(NSInteger)count
{
    if (count < 1) return;
    
    [self.badgeView incrementBadgeCountByIncreaseCount:count];
    [self.badgeView setHidden:NO];
    [self.viewNotification setHidden:YES];
}

- (void)autoShowExperiences:(NSArray *)experiences
{
    for (int i = (int32_t)experiences.count-1; i>=0; i--) {
        FMExperience *experience = experiences[i];
        [self presentExperience:experience];
    }
}

#pragma mark - Actions

- (void) badgeBtnSelected:(UIButton *)sender
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if( ![[window visibleViewController] isKindOfClass:[OffersViewController class]] )
    {
        // Return to OffersViewController and shows offers
        NSArray *arr = [self.navigationController viewControllers];
        if(arr && ([arr count] > 0))
        {
            [self.navigationController popToViewController:[arr firstObject] animated:YES];
        }
    }
    //    [self showAllStoredExperienceViews];
    [self.badgeView resetBadgeCount];
    [self.badgeView setHidden:YES];
    
    // determine if to present a single experience or
    //  display a listing of experiences.
    NSArray *unreadExperiences = [ExperienceManager unreadExperiences];
    if (unreadExperiences.count > 0) {
        if (unreadExperiences.count == 1) {
            FMExperience *experience = unreadExperiences.firstObject;
            if (experience.type == FMExperienceTypeAlert) {
                [self openExperienceNotificationListingWithExperiences:unreadExperiences];
            } else {
                [self presentExperience:experience];
                [ExperienceManager readExperiences:@[experience]];
            }
        } else {
            [self openExperienceNotificationListingWithExperiences:unreadExperiences];
        }
    }
}

-(IBAction)clickedBtnNotif:(id)sender
{
    if(self.curNotifExp)
    {
        ExperienceView *ov = [self.dictOfferViews objectForKey:self.curNotifExp.expId];
        [self addOfferOrExperienceViewToView:ov];
        [ExperienceManager readExperiences:@[self.curNotifExp]];
    }
    [self.viewNotification setHidden:YES];
}


- (IBAction)clickedMenu:(id)sender
{
    if([self.menu isOpen])
    {
        [self.menu close];
    }
    else
    {
        [self.menu showFromNavigationController:self.navigationController];
    }
}


#pragma mark - ExperiencesViewController Delegate

- (void)experienceNotificationListingViewControllerClosed:(ExperienceNotificationListingViewController *)viewController
{
    [ExperienceManager readExperiences:[ExperienceManager unreadExperiences]];
    [self.badgeView resetBadgeCount];
    
    //NSLog(@"Experiences View Controller Dismissed");
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)experienceNotificationListingViewController:(ExperienceNotificationListingViewController *)viewController didSelectExperience:(FMExperience *)experience
{
    [ExperienceManager readExperiences:@[experience]];
    [self.badgeView decrementBadgeCount];
    
    NSLog(@"selected experience: %@", experience.name);
    [self presentExperience:experience];
}

#pragma mark - ExperienceView Delegate

- (void)experienceViewWillRemove:(ExperienceView *)view experience:(FMExperience *)experience
{
    
    [self removeExperienceViewWithExpId:experience.expId];
}

#pragma mark - App Delegate Nofication

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
        BOOL skip = NO;
        if (_experienceNotificationListingVC) {
            if (experience.action == FMExperienceActionPrompt) {
                skip = YES;
            }
        }
        
        // If notification experience view is not shown, handle the
        //  single experience.
        if (!skip) {
            [self handleSingleExperienceInForeground:experience];
            
            // Save experiences if pass the increment cap limit.
            _staticToSaveIncrement++;
            if (_staticToSaveIncrement > kToSaveIncrementCap) {
                _staticToSaveIncrement = 0;
                [ExperienceManager save];
            }
            
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
        if(![self doesExperienceExistAlready:experience.expId])
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
    
    if ([self isApplicationInForeground]) {
        
        // For the type of display, it depends on if there are any auto-show types.
        //  If yes, display the experiences content and send the alert in queue.
        //  Otherwise, display the listing of prompts and alerts.
        if (popupExperiences.count > 0) {
            // show popups if any
            [self autoShowExperiences:popupExperiences];
            
            // show badge
            [self showBadgeWithIncreaseBadgeCount:notificationExperiences.count];
        } else if (notificationExperiences.count == 0) {
            // otherwise show unread experience
            if (!_experienceNotificationListingVC)
                [self openExperienceNotificationListingWithExperiences:[ExperienceManager unreadExperiences]];
        } else {
            [self openExperienceNotificationListingWithExperiences:notificationExperiences];
        }
    } else {
        
        // increment badge number
        [self showBadgeWithIncreaseBadgeCount:notificationExperiences.count];
        
        // even if the app is in background, once the app enters the foreground,
        //   the app will automatically display the experience content.
        [self autoShowExperiences:popupExperiences];
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

#pragma mark - UITableView DataSource & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
        case 0:
            rows = 1;
            break;
            
        case 1:
            rows = [self.items count];
            break;
            
        default:
            break;
    }
    
    return rows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    
    if (indexPath.section == 0) {

        cell = [self.tableView dequeueReusableCellWithIdentifier:BarcodeCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:BarcodeCellIdentifier];
        }
    }
    else {
        OfferCell *offerCell = [self.tableView dequeueReusableCellWithIdentifier:OfferCellIdentifier];
        if (!offerCell) {
            offerCell = (OfferCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OfferCellIdentifier];
        }
        Offer *currentOffer = (Offer *)self.items[indexPath.row];
        if (currentOffer) {
            offerCell.offer = currentOffer;
        }
        
        cell = offerCell;
    }
    return cell;
}


@end
