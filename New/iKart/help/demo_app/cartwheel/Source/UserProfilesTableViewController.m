//
//  UserProfilesTableViewController.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/5/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "UserProfilesTableViewController.h"
#import "ExperienceManager.h"
#import "ProfileTableCell.h"
#import "Helpers.h"

@interface UserProfilesTableViewController ()

@property (nonatomic, strong) NSArray *profiles;

@end

@implementation UserProfilesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profiles = [NSArray array];
    [self.tableView registerClass:[ProfileTableCell class] forCellReuseIdentifier:@"ProfileTableCell"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    self.profiles = [[ExperienceManager defaultManager] profiles];
    NSLog(@"Current Number of Profiles: %lu", (unsigned long)[self.profiles count]);
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.profiles count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"ProfileTableCell";
    ProfileTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    @try {
        
        NSDictionary *profile = self.profiles[indexPath.row];
        NSString *imageURL = (NSString *)profile[UserProfileImageURLKey];
        NSString *name = (NSString *)profile[UserProfileNameKey];
        [Helpers loadImageInBGThreadWithUrl:imageURL andSetTo:cell.imgView withLoadIndColor:[UIColor grayColor]];
        cell.lblName.text = name;
        
    }
    @catch (NSException *exception) {
        NSLog(@"INFO: Exception thrown in cellForRowAtIndexPath within profileTableViewController.");
    }

    return cell;
}



@end

