//
//  FMExperience+Extension.m
//  ShoppingCart
//
//  Created by Nate R on 2/9/15.
//  Copyright (c) 2015 Footmarks. All rights reserved.
//

#import "FMExperience+Extension.h"

@implementation FMExperience (Extension)

- (BOOL)hasContent
{
    return self.type != FMExperienceTypeAlert && self.type != FMExperienceTypeUnknown;
}

@end
