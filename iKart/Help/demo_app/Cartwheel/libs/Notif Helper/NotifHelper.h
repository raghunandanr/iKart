//
//  NotifHelper.h
//  FMTestApp_v1
//
//  Created by casey graika on 1/16/14.
//  Copyright (c) 2014 casey graika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifHelper : NSObject

-(void) decrementOneBdge;

-(void) incrementOneBadge;

-(void) showNotificationWithText: (NSString*)text;

-(void)showNotificationWithText:(NSString *)text incrementBadgeNumber:(BOOL)increment;


@end
