//
//  OfferTableViewCell.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/1/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "OfferCell.h"

NSString *const OfferCellIdentifier = @"OfferCell";

@interface OfferCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *taglineLabel;
@property (weak, nonatomic) IBOutlet UIImageView *offerImageView;
@property (weak, nonatomic) IBOutlet UILabel *discountLabel;

@end

@implementation OfferCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setOffer:(Offer *)offer {
    self.titleLabel.text = offer.name;
    self.taglineLabel.text = offer.tagline;
    self.discountLabel.text = [NSString stringWithFormat:@"%@%% OFF", offer.discount];
    
    self.offerImageView.image = [UIImage imageNamed:offer.image];
}

@end
