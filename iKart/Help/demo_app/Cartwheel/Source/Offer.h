//
//  Offer.h
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/1/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Offer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tagline;
@property (nonatomic, retain) NSNumber * discount;
@property (nonatomic, retain) NSString * image;

@end
