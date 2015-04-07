//
//  BadgeView.m
//  Redbull
//
//  Created by casey graika on 6/23/14.
//  Copyright (c) 2014 casey graika. All rights reserved.
//

#import "BadgeView.h"

@implementation BadgeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithNib
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    if(bundle)
    {
        BadgeView *aView = [[bundle loadNibNamed:@"BadgeView" owner:self options:nil] objectAtIndex:0];
        self = aView;
        [self initialize];
    }
    
    return self;
}
- (void)initialize
{
    
}

- (void) incrementBadgeCountByIncreaseCount:(NSInteger)count
{
    int badgecount = [self.lblBadgeCount.text intValue];
    badgecount = badgecount + (int32_t)count;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lblBadgeCount setText:[NSString stringWithFormat:@"%d", badgecount]];
    });
}

- (void) incrementBadgeCount
{
    int count = [self.lblBadgeCount.text intValue];
    count = count + 1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.lblBadgeCount setText:[NSString stringWithFormat:@"%d", count]];

    });
}


- (void) resetBadgeCount;
{
    [self.lblBadgeCount setText:[NSString stringWithFormat:@"%d", 0]];
}

- (void)decrementBadgeCount
{
    int count = [self.lblBadgeCount.text intValue];
    count = count - 1;
    if (count < 0) count = 0;
    [self.lblBadgeCount setText:[NSString stringWithFormat:@"%d", count]];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
