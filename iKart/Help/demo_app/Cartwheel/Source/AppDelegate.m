//
//  AppDelegate.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 11/25/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "AppDelegate.h"
#import "Helpers.h"
#import "Footmarks_SDK.h"


#define SMARTPROFILE 0

@interface AppDelegate ()<FMBeaconManagerDelegate, FMExperienceManagerDelegate>

@end

@implementation AppDelegate


-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"\n***********************************\n        DID FINISH LAUNCHING\n***********************************");
    
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
    
    // Load experiences from storage
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
    [self saveContext];
    
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









#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ratio.Footmarks_Demo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Footmarks_Demo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Footmarks_Demo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)dealloc
{
    NSLog(@"APP DELEGATE DEALLOC");
}

@end
