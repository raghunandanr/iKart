//
//  ExperiencesView.m
//  ShoppingCart
//
//  Created by Nate R on 2/2/15.
//  Copyright (c) 2015 Footmarks. All rights reserved.
//

#import "ExperiencesOpacityView.h"
#import <QuartzCore/CAGradientLayer.h>

@interface ExperiencesOpacityView ()
@property (nonatomic, weak) CALayer *maskLayer;
@end

@implementation ExperiencesOpacityView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        // add gradient mask fade
        CGRect bounds = self.bounds;
        CAGradientLayer *maskLayer = [CAGradientLayer layer];
        [maskLayer setFrame:bounds];
        [maskLayer setOpacity:1.0f];
        [maskLayer setLocations:@[@0, @.9, @.95, @1]];
        [maskLayer setColors:@[(id)[UIColor whiteColor].CGColor,
                               (id)[UIColor whiteColor].CGColor,
                               (id)[UIColor colorWithWhite:1 alpha:.9f].CGColor,
                               (id)[UIColor colorWithWhite:1 alpha:0.0].CGColor]];
        [self.layer setMask:maskLayer];
        self.maskLayer = maskLayer;
        
    } return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // resize mask layer
    CGRect bounds = self.bounds;
    [self.maskLayer setBounds:bounds];
    [self.maskLayer setPosition:CGPointMake(bounds.size.width/2, bounds.size.height/2)];
}

@end
