//
//  ExperienceManager.h
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/5/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString *const UserProfileImageURLKey;

NSString *const UserProfileNameKey;

NSString *const UserProfileGroupKey;

@class FMExperience;

@protocol AppsExperienceManagerDelegate <NSObject>

- (void)newPresentedExperience:(FMExperience*)exp;

@end

@interface ExperienceManager : NSObject



@property (atomic, strong, readonly) NSArray *experiences;

@property (atomic, strong, readonly) NSArray *profiles;

@property (nonatomic, weak) id <AppsExperienceManagerDelegate> delegate;

+(NSArray *)unreadExperiences;

+(void)readExperiences:(NSArray *)experiences;

+(instancetype)defaultManager;

+(void)addExperience:(FMExperience *)experience markRead:(BOOL)read;

+(void)addExperience:(FMExperience *)experience;

+(void)deleteExperienceWithId:(NSString *)expId;

+(void)removeAllExperiences;

+(void)fetchProfiles;

+(NSArray *)allExperiences;

+(NSInteger)experienceCount;

+(FMExperience *)returnPresentedExperience;

+(void)save;

+(void)load;

@end
