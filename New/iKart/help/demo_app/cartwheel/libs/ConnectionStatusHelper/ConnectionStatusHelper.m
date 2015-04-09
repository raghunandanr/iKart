//
//  ConnectionStatusHelper.m
//
//
//  Created by casey graika on 5/21/14.
//  Copyright (c) 2014 Footmarks Inc. All rights reserved.
//

#import "ConnectionStatusHelper.h"

@interface ConnectionStatusHelper ()
{
    UIView *parentView;
    UILabel *alertView;
}

@end


@implementation ConnectionStatusHelper

@synthesize reachability;

-(id) initWithViewToDisplayAlertOn: (UIView*) alertParentView
{
    self = [super init];
    
    if (self)
    {
        self.reachability = [Reachability reachabilityForInternetConnection];
        parentView = alertParentView;
        [self initialize];
    }
    
    return self;
}

-(void)initialize
{
    alertView = [[UILabel alloc] initWithFrame:CGRectMake(5, 513, 310, 38)];
    UIColor *bgColor = [[UIColor alloc] initWithRed:(195.f/255.f) green:(0/255.f) blue:(18.f/255.f) alpha:1.f];
    [alertView setBackgroundColor:bgColor];
    [alertView setText:@"No Internet Connection"];
    [alertView setFont:[UIFont fontWithName:@"DINCondensed-Bold" size:22]];
    [alertView setTextColor:[UIColor whiteColor]];
    [alertView setTextAlignment:NSTextAlignmentCenter];
    [alertView setHidden:YES];
    [parentView addSubview:alertView];
    [parentView bringSubviewToFront:alertView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(presentInetProblemView:) name:kReachabilityChangedNotification object:nil];
    [reachability startNotifier];
    
    if(![self connectedToInet])
    {
        [self showInetProbView];
    }
    
}

- (BOOL)connectedToInet
{
    NetworkStatus networkStatus = [self.reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

- (void) presentInetProblemView: (NSNotification *) notification
{
    if(![self connectedToInet])
    {
        [self showInetProbView];
        
    }
}

- (void) showInetProbView
{
    
    [alertView setAlpha:0.0];
    [alertView setHidden:NO];
    [UIView animateWithDuration:1.5f
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         //Set the frame you want to the search bar
                         [alertView setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [self hideInetProbView];
                     }];
    
    
}

- (void) hideInetProbView
{
    [UIView animateWithDuration:1.5f
                          delay:3.5f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         //Set the frame you want to the search bar
                         [alertView setAlpha:0.0];
                     }
                     completion:^(BOOL finished)
     {
         [alertView setHidden:YES];
         
     }];
    
}

@end
