//
//  AppDelegate.h
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 11/25/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "OffersViewController.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) OffersViewController *offersViewController;
@property (nonatomic) NSArray *experiences;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

