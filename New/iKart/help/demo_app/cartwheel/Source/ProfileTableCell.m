//
//  ProfileTableCell.m
//  Footmarks-Demo
//
//  Created by Footmarks on 1/1/15.
//  Copyright (c) 2015 Ratio. All rights reserved.
//

#import "ProfileTableCell.h"

@implementation ProfileTableCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
        ProfileTableCell *rootView = [[[NSBundle mainBundle] loadNibNamed:@"ProfileTableCell" owner:self options:nil] objectAtIndex:0];
        
        self = rootView;
    }
    return self;
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
