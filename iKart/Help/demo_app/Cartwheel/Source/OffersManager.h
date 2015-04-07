//
//  OffersManager.h
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/1/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FMExperience;

NSString *const OfferEntityName;

@interface OffersManager : NSObject

+(instancetype)defaultManager;

/** Load from PList file */
+(BOOL)loadOffers;

+(void)resetOffers;

+(void)addOffer:(NSDictionary *)offer;

@end
