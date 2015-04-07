//
//  ViewController.m
//  iKart
//
//  Created by Raghunandan on 07/04/15.
//  Copyright (c) 2015 NullAndVoid. All rights reserved.
//

#import "ViewController.h"
#import "Footmarks_SDK.h"
#import "Credentials.h"

@interface ViewController () {
    
        FMAccount *fmAccount;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[FMAccount sharedInstance] setAccountDelegate:self];
    [self authenticateApp];
    
}


- (void) authenticateApp
{
    [fmAccount loginToFootmarksServer:FMAppKey andAppSecret:FMAppSecret andUserId:@""];
}

- (void) loginUnsuccessful: (NSString*)error
{
    NSLog(@"\n---LOGIN NOT SUCCESSFULL CALLBACK----\n");
}

- (void) loginSuccessful
{
    NSLog(@"\n---LOGIN SUCCESS CALLBACK----\n");
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
