//
//  ExperienceListTableViewController.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/4/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "ExperienceListTableViewController.h"
#import "ExperienceManager.h"
#import "Footmarks_SDK.h"
#import "OfferView.h"
#import "ExperienceView.h"
#import "FMExperience+Extension.h"

@interface ExperienceListTableViewController ()
@property (nonatomic, strong) NSArray *experiences;
@property (nonatomic, strong) NSMutableDictionary *dictOfferViews;
@property (nonatomic) BOOL isPresentingOfferView;
@end

@implementation ExperienceListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.experiences = [NSArray array];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    self.experiences = [ExperienceManager allExperiences];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.experiences count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExperienceCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"ExperienceCell"];
    }
    
    // Configure the cell...
    FMExperience *experience = (FMExperience *)self.experiences[indexPath.row];
    cell.textLabel.text = experience.name;
    
    switch (experience.type) {
        case FMExperienceTypeAlert:
            cell.detailTextLabel.text = @"Alert";
            break;
            
        case FMExperienceTypeHtml:
            cell.detailTextLabel.text = @"HTML";
            break;
            
        case FMExperienceTypeImage:
            cell.detailTextLabel.text = @"Image";
            break;
            
        case FMExperienceTypeVideo:
            cell.detailTextLabel.text = @"Video";
            break;
            
        case FMExperienceTypeCustom:
            cell.detailTextLabel.text = @"Custom";
            break;
            
        case FMExperienceTypeUnknown:
            cell.detailTextLabel.text = @"Unknown";
            break;
            
        default:
            break;
    }
    
    if (experience.action == FMExperienceActionPrompt && experience.type == FMExperienceTypeAlert) {
        if (experience.notificationTitle.length > 0) {
            cell.textLabel.text = experience.notificationTitle;
        }
        cell.detailTextLabel.text = experience.notificationDescription;
    }
    
    UIColor *textColor;
    if (experience.hasContent) {
        textColor = [UIColor colorWithWhite:0 alpha:1];
    } else {
        textColor = [UIColor colorWithWhite:.1f alpha:.5f];
    }
    
    cell.textLabel.textColor = textColor;
    cell.detailTextLabel.textColor = textColor;
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMExperience *experience = self.experiences[indexPath.row];
    return experience.hasContent;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMExperience *experience = self.experiences[indexPath.row];
    
    if (experience.hasContent) {
        if ([self.delegate respondsToSelector:
             @selector(experienceListTableViewControllerDidSelectExperience:)]) {
            [self.delegate experienceListTableViewControllerDidSelectExperience:experience];
        }
    }
    
}



@end
