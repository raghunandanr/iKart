//
//  ConnectionStatusHelper.h
//  
//
//  Created by casey graika on 5/21/14.
//  Copyright (c) 2014 Footmarks Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"

@interface ConnectionStatusHelper : NSObject

-(id) initWithViewToDisplayAlertOn: (UIView*) alertParentView;

@property (nonatomic, retain)  Reachability *reachability;

@end
