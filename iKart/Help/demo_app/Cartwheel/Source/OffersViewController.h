//
//  OffersTableViewController.h
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/1/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REMenu.h"
#import "Footmarks_SDK.h"
#import "ExperienceManager.h"

@interface OffersViewController : UIViewController<REMenuDelegate, UITableViewDataSource, AppsExperienceManagerDelegate>

- (void) removeExperienceViewWithExpId: (NSString*)expId;

@end
