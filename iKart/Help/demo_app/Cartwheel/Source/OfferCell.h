//
//  OfferTableViewCell.h
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/1/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offer.h"

NSString *const OfferCellIdentifier;

@interface OfferCell : UITableViewCell

@property (nonatomic, strong) Offer *offer;

@end
