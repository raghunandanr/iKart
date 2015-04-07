//
//  ExperiencesViewController.m
//  ShoppingCart
//
//  Created by Nate R on 1/30/15.
//  Copyright (c) 2015 Footmarks. All rights reserved.
//

#import "ExperienceNotificationListingViewController.h"
#import <QuartzCore/CAGradientLayer.h>
#import "Footmarks_SDK.h"
#import "ExperienceCellView.h"

static NSString *cellIdentifier = @"cell";
static CGFloat const kCloseDuration = 1.0f;
static CGFloat const kDelay = 0.2f;
#define CELL_INSET_X 10.f

@interface ExperienceNotificationListingViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (nonatomic, strong) NSMutableArray *experiences;
@property (nonatomic, strong) ExperienceCellView *dummyCell;
@end

@implementation ExperienceNotificationListingViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.experiences = [NSMutableArray array];
    } return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // offset the tableview to be more in the middle
    [self.tableView setContentInset:UIEdgeInsetsMake(100, 0, 20, 0)];
    
    // setup dummy cell for later use to retrieve individual cell height
    self.dummyCell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    
}

#pragma mark - Actions

- (IBAction)selectClose:(id)sender
{
    // deque items from the array
    
    [self close];
}

#pragma mark - Internal Methods

- (void)close {
    [self.dismissButton setHidden:YES];
    
    // close view
    __weak typeof(self) weakself = self;
    [UIView animateWithDuration:kCloseDuration animations:^{
        [weakself.view setAlpha:0];
    }completion:^(BOOL finished) {
        [weakself.delegate experienceNotificationListingViewControllerClosed:weakself];
    }];
}

- (void)addExperiences:(NSArray *)experiences
{
    // add experiences to array
    [self.experiences addObjectsFromArray:experiences];
    
    // if table view exist, animate the table view to add cell to match
    // the count of experiences.
    if (self.tableView) {
        // retrieve index paths
        NSMutableArray *indexPaths = [NSMutableArray array];
        for ( int i = (int)(self.experiences.count - experiences.count);
             i < self.experiences.count;
             i++ )
        {
            [indexPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        // animate insertions.
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView endUpdates];
    }
}

- (void)activateExperience:(FMExperience *)experience atIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark - UITableView Delegate & DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.experiences.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FMExperience *experience = self.experiences[indexPath.row];
    
    // set data to dummy cell to find the intrinsic size
    [self.dummyCell setExperience:experience];
    
    CGFloat height = self.dummyCell.contentView.intrinsicContentSize.height;
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExperienceCellView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    FMExperience *experience = self.experiences[indexPath.row];
    
    // set cell view
    [cell setExperience:experience];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deque item from array
    [self.delegate experienceNotificationListingViewController:self didSelectExperience:self.experiences[indexPath.row]];
    [self.experiences removeObjectAtIndex:indexPath.row];
    
    // remove cell
    [tableView beginUpdates];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [tableView endUpdates];
    
    // disable scrolling if less than content height
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    CGFloat newContentHeight = tableView.contentSize.height - cell.contentView.frame.size.height;
    if (newContentHeight < tableView.frame.size.height) {
        [tableView setScrollEnabled:NO];
    }
    
    
    // if there is no experiences, close view controller.
    if (self.experiences.count == 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self close];
        });
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (tableView == self.tableView) {
            CGFloat cornerRadius = 5.f;
            
            // create a mask layer
            CAShapeLayer *layer = [[CAShapeLayer alloc] init];
            CGMutablePathRef pathRef = CGPathCreateMutable();
            CGRect bounds = CGRectInset(cell.bounds, CELL_INSET_X, 0);
            BOOL addLine = NO;
            if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            } else if (indexPath.row == 0) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds), CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
                addLine = YES;
            } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
                CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
                CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
                CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            } else {
                CGPathAddRect(pathRef, nil, bounds);
                addLine = YES;
            }
            layer.path = pathRef;
            CFRelease(pathRef);
            layer.fillColor = [UIColor colorWithWhite:1.f alpha:1.0f].CGColor;
            
            // set mask
            [cell.layer setMask:layer];
            
        }
    }
}


@end
