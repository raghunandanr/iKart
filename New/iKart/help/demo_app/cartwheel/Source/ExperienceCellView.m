//
//  ExperienceCellView.m
//  ShoppingCart
//
//  Created by Nate R on 1/30/15.
//  Copyright (c) 2015 Footmarks. All rights reserved.
//

#import "ExperienceCellView.h"

#define kSelectedColor [UIColor colorWithRed:.3 green:0 blue:0 alpha:.5]
#define kUnselectedColor [UIColor colorWithWhite:0 alpha:.5];


@implementation ExperienceCellView
{
    UIColor *_customBackgroundColor;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        self.backgroundColor = kSelectedColor;
    } else {
        if (_experience.type != FMExperienceTypeAlert) {
            self.backgroundColor = [UIColor colorWithRed:20.0f/255.0f green:20.0f/255.0f blue:20.0f/255.0f alpha:.8];
        } else {
            self.backgroundColor = [UIColor colorWithRed:56.0f/255.0f green:56.0f/255.0f blue:56.0f/255.0f alpha:.7];
        }
    }
}

- (void)setExperience:(FMExperience *)experience
{
    _experience = experience;
    
    if (!_experience) return;
    
    if (_experience.type == FMExperienceTypeAlert &&
        _experience.action == FMExperienceActionPrompt) {
        [self.titleLabel setText:_experience.notificationTitle];
        [self.descriptionLabel setText:_experience.notificationDescription];
        [self.typeImageView setImage:nil];
    } else {
        [self.titleLabel setText:_experience.name];
        [self.descriptionLabel setText:@""];
        
    }
    
    // set the type image on the left of the cell.
    if (_experience.type == FMExperienceTypeAlert) {
        [self.typeImageView setImage:[UIImage imageNamed:@"alert2"]];
    } else {
        [self.typeImageView setImage:[UIImage imageNamed:@"cartwheel_icon"]];
    }
    
}

@end
