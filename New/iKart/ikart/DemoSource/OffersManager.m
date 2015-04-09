//
//  OffersManager.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/1/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "OffersManager.h"
#import "Offer.h"
#import "AppDelegate.h"
@import CoreData;

NSString *const OfferEntityName = @"Offer";

static NSString *const OffersPlistFileName = @"OffersList";

static NSString *const OfferNameKey = @"name";

static NSString *const OfferDiscountKey = @"discount";

static NSString *const OfferTaglineKey = @"tagline";

static NSString *const OfferImageNameKey = @"image";

@interface OffersManager ()

@property (nonatomic, strong, readonly) NSArray *offers;

@property (nonatomic, strong, readonly) NSManagedObjectContext *context;

@end

@implementation OffersManager

-(instancetype)init {
    
    self = [super init];
    if (self) {
        _offers = @[];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        _context = appDelegate.managedObjectContext;
    }
    return self;
}

+(instancetype)defaultManager {
    static OffersManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[OffersManager alloc] init];
    });
    return manager;
}

+(BOOL)loadOffers {
    BOOL loaded = NO;
    NSDictionary *offersDict = [self loadPlist];
    if (offersDict) {
        for (NSString *key in [offersDict allKeys]) {
            [[OffersManager defaultManager] refreshCacheList];
            
            NSDictionary *offer = (NSDictionary *)offersDict[key];
            if (offer) {
                if (![[OffersManager defaultManager] offerExists:offer]) {
                    [[OffersManager defaultManager] addOffer:offer];
                }
            }
        }
    }
    return loaded;
}

+(void)resetOffers {
    [[OffersManager defaultManager] refreshCacheList];
    [[OffersManager defaultManager] removeAllOffers];
}

-(void)removeAllOffers {
    for (Offer *offer in self.offers) {
        [self.context deleteObject:offer];
    }
    [self.context save:nil];
}

-(BOOL)offerExists:(NSDictionary *)offer {
    BOOL exists = NO;
    
    if (offer) {
        NSString *name = (NSString *)offer[OfferNameKey];
        for (Offer *currentOffer in self.offers) {
            
            if ([currentOffer.name isEqualToString:name]) {
                exists = YES;
                break;
            }
        }
    }
    
    return exists;
}

+(void)addOffer:(NSDictionary *)offer {
    [[OffersManager defaultManager] addOffer:offer];
}

-(void)addOffer:(NSDictionary *)offer {
    if (offer) {
        
        Offer *newOffer = [NSEntityDescription insertNewObjectForEntityForName:OfferEntityName inManagedObjectContext:self.context];
        newOffer.name = (NSString *)offer[OfferNameKey];
        newOffer.discount = (NSNumber *)offer[OfferDiscountKey];
        newOffer.tagline = (NSString *)offer[OfferTaglineKey];
        newOffer.image = (NSString *)offer[OfferImageNameKey];
        
        [self.context insertObject:newOffer];
        [self.context save:nil];
    }
}

-(void)refreshCacheList {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:OfferEntityName];
    
    _offers = [self.context executeFetchRequest:fetchRequest error:nil];
}

+(NSDictionary *)loadPlist {
    
    NSString *offersPath = [[NSBundle mainBundle] pathForResource:@"OffersList" ofType:@"plist"];
    
    NSDictionary *offersDict = [NSDictionary dictionaryWithContentsOfFile:offersPath];
    
    return offersDict;
}

@end
