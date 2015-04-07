//
//  CustomButton.m
//  ShoppingCart
//
//  Created by Nate R on 1/30/15.
//  Copyright (c) 2015 Footmarks. All rights reserved.
//

#import "CustomButton.h"

@implementation CustomButton

- (CGSize)intrinsicContentSize
{
    CGSize s = [super intrinsicContentSize];
    return CGSizeMake(s.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
                      s.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom);
}

@end
