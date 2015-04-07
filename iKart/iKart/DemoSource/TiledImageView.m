//
//  TiledImageView.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 11/26/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "TiledImageView.h"

@implementation TiledImageView

-(void)awakeFromNib {
    [super awakeFromNib];

    UIColor *tiledColor = [UIColor colorWithPatternImage:self.tiledImage];
    self.backgroundColor = tiledColor;
}

@end
