//
//  ExperienceListTableViewController.h
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/4/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FMExperience;

@protocol ExperienceListTableViewControllerDelegate;

@interface ExperienceListTableViewController : UITableViewController
@property (nonatomic, weak) id<ExperienceListTableViewControllerDelegate> delegate;
@end

@protocol ExperienceListTableViewControllerDelegate <NSObject>

- (void)experienceListTableViewControllerDidSelectExperience:(FMExperience *)experience;

@end