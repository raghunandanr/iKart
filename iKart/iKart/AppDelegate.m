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


@class FMAccount;

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
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
    

    
    return YES;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end