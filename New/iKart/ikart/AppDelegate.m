//
//  AppDelegate.m
//  iKart
//
//  Created by Raghunandan on 07/04/15.
//  Copyright (c) 2015 NullAndVoid. All rights reserved.
//

#import "AppDelegate.h"
#import "Helpers.h"
#import "Footmarks_SDK.h"
#import "ExperienceManager.h"
#import <GoogleMaps/GoogleMaps.h>

#define SMARTPROFILE 0

static NSString *const kAPIKey = @"AIzaSyA6p5JN50oIx5YEs6f2JIRMWfZLYbxr8BQ";

@class FMAccount;

@interface AppDelegate ()<FMBeaconManagerDelegate, FMExperienceManagerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GMSServices provideAPIKey:kAPIKey];
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)])
    {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    /************************************************************
     *                  ~~ Important ~~
     *
     *   Set the SMARTPROFILE macro to 1 if you would
     *   like to enable Smart Profiles(SP). SPs allow the Footmarks
     *   Platform to send more targeted experiences to app users.
     *   Also, more powerful analytics will be shown in the
     *   Footmarks Management console.
     *
     ************************************************************/
#if SMARTPROFILE
    [[FMAccount sharedInstance] useSmartProfilesInApplication:application withLaunchOptions:launchOptions];
#else
    [(FMAccount *)[FMAccount sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
#endif
    [[FMAccount sharedInstance] setIsDemoApp];
    

        [ExperienceManager load];
    
    return YES;

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    NSLog(@"Application Will Resign Active");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    NSLog(@"\n***********************************\n        IN BACKGROUND\n***********************************");
    
    [ExperienceManager save];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"CartwheelAppWillEnterForeground" object: nil];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
    
    NSLog(@"\n***********************************\n        WILL ENTER FOREGROUND\n***********************************");
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    NSLog(@"\n***********************************\n        DID BECOME ACTIVE\n***********************************");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    
    [ExperienceManager save];
    
    NSLog(@"\n***********************************\n        WILL TERMINATE\n***********************************");
}



#pragma mark - FMExperienceManager Delegate

/**
 *
 */
/************************************************************
 *                  ~~ Important ~~
 *
 *   This is called when retrieve experiences for the client beacons.
 *   This is also be called while in background.
 *
 *   Notify user of experience here if you plan on doing so.
 *   When the app is killed (not running), notifications will
 *   not show if you move to another view controller and attempt
 *   to present them.
 *
 ************************************************************/
- (void) didCompleteExperiences: (NSArray*) experiences
{
    NSLog(@"Experiences: %@", experiences);
    self.experiences = experiences;
    
    //NSLog(@"Post Notification for CartwheelAppDelegateDidCompleteExperiences");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"CartwheelAppDelegateDidCompleteExperiences" object:nil];
}

#pragma mark - FMBeaconManager Delegate

- (void)bluetoothDidSwitchState:(CBCentralManagerState)state
{
    NSLog(@"bluetooth state: %i", (int32_t)state);
    
    if (state == CBCentralManagerStatePoweredOn) {
        // add code when turn back on.
    } else if (state == CBCentralManagerStatePoweredOff) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *title     = @"Warning";
            NSString *message   = @"To take full advantage of this app, please enable Bluetooth in your phone's settings.";
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
        });
    } else {
        // this is for unknown state that Apple may pass.
    }
}

- (void) locationServicesFailedWithError: (NSError *)error
{
    NSLog(@"Location failed: %@", error.localizedDescription);
}

-(void)beaconManager:(FMBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(FMBeaconRegion *)region {
}


-(void)beaconManager:(FMBeaconManager *)manager didDetermineState:(CLRegionState)state forRegion:(FMBeaconRegion *)region {
}

-(void)beaconManager:(FMBeaconManager *)manager didEnterRegion:(FMBeaconRegion *)region
{
}

-(void)beaconManager:(FMBeaconManager *)manager didExitRegion:(FMBeaconRegion *)region {
    
}

-(void)beaconManager:(FMBeaconManager *)manager monitoringDidFailForRegion:(FMBeaconRegion *)region withError:(NSError *)error {
    
}

-(void)beaconManager:(FMBeaconManager *)manager rangingBeaconsDidFailForRegion:(FMBeaconRegion *)region withError:(NSError *)error {
    
}





@end
