//
//  BadgeView.h
//  Redbull
//
//  Created by casey graika on 6/23/14.
//  Copyright (c) 2014 casey graika. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeView : UIView

@property (weak, nonatomic) IBOutlet UIButton *btnBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblBadgeCount;
- (id) initWithNib;

- (void) incrementBadgeCountByIncreaseCount:(NSInteger)quantity;
- (void) incrementBadgeCount;
- (void) resetBadgeCount;
- (void) decrementBadgeCount;

@end
