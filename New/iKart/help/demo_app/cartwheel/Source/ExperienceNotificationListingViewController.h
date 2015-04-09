//
//  ExperiencesViewController.h
//  ShoppingCart
//
//  Created by Nate R on 1/30/15.
//  Copyright (c) 2015 Footmarks. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FMExperience;
@protocol ExperiencesViewControllerDelegate;

@interface ExperienceNotificationListingViewController : UIViewController
@property (nonatomic, weak) id<ExperiencesViewControllerDelegate> delegate;
- (void)addExperiences:(NSArray *)experiences;
@end

@protocol ExperiencesViewControllerDelegate <NSObject>
- (void)experienceNotificationListingViewControllerClosed:(ExperienceNotificationListingViewController *)viewController;
- (void)experienceNotificationListingViewController:(ExperienceNotificationListingViewController *)viewController didSelectExperience:(FMExperience *)experience;
@end
