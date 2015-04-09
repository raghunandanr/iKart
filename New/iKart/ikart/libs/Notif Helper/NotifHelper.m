//
//  NotifHelper.m
//  FMTestApp_v1
//
//  Created by casey graika on 1/16/14.
//  Copyright (c) 2014 casey graika. All rights reserved.
//

#import "NotifHelper.h"


@implementation NotifHelper

#pragma mark Alert Badge Helper Methods

/****************************************************************************/

/*                 Alert Badge and Notification Helper Methods              */

/****************************************************************************/
-(void) showNotificationWithText: (NSString*)text
{
    [self showNotificationWithText:text incrementBadgeNumber:YES];
    
}

- (void)showNotificationWithText:(NSString *)text incrementBadgeNumber:(BOOL)increment
{
    if((![text isEqualToString:@""]) && (text != nil) )
    {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        
        NSDictionary *infoDict = [NSDictionary dictionaryWithObject:text forKey:@"KEY"];
        localNotification.userInfo = infoDict;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
        {
            // Reset badge count if user forgot to add this logic in their app delegate
            NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
            if(numberOfBadges > 0)
            {
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:-1];
            }
        }
        else
        {
            if (increment) [self incrementOneBadge];
            
        }
        localNotification.alertBody = text;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
}

-(void) incrementOneBadge
{
    NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
    if(numberOfBadges < 0) // < 0 means no badges are currently being displayed
        numberOfBadges = 0;
    numberOfBadges +=1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
}

-(void) decrementOneBdge
{
    NSInteger numberOfBadges = [UIApplication sharedApplication].applicationIconBadgeNumber;
    numberOfBadges -=1;
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:numberOfBadges];
}
#pragma end

@end
