//
//  ExperienceManager.m
//  Footmarks-Demo
//
//  Created by Thomas De Leon on 12/5/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "ExperienceManager.h"
#import "Footmarks_SDK.h"
#import "Helpers.h"
@import AdSupport;

// Used for user defaults retrieve and save data.
NSString *const kUserDefaultsExperiencesKey = @"experiences";

NSString *const kUserDefaultsExperiencesCountKey = @"experiences_count";

NSString *const kUserDefaultsUnreadExperienceIdsKey = @"unread_experiences_ids";

NSString *const kExperienceIdKey = @"experience_id";

NSString *const UserProfileImageURLKey = @"imgurl";

NSString *const UserProfileNameKey = @"name";

NSString *const UserProfileGroupKey = @"group";

static NSString *const FMRestAPIURL = @"http://api.footmarks.com/user/profiles";

static const NSTimeInterval FMRestAPITimeout = 30;

@interface ExperienceManager ()

@property (nonatomic) NSInteger readIndex;

@property (nonatomic, strong) NSMutableArray *internalExperiences;

@property (nonatomic, strong) NSMutableArray *unreadExperiences;

@property (nonatomic, strong) NSMutableArray *savedExperiences;

@property (nonatomic, strong) NSMutableArray *savedExperiencesIds;

@end

@implementation ExperienceManager

-(instancetype)init {
    
    self = [super init];
    if (self) {
        _internalExperiences = [NSMutableArray array];
        _unreadExperiences = [NSMutableArray array];
        _savedExperiences = [NSMutableArray array];
        _savedExperiencesIds = [NSMutableArray array];
        _readIndex = 0;
    }
    return self;
}

+(instancetype)defaultManager {
    static ExperienceManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ExperienceManager alloc] init];
    });
    return manager;
}

+(void)addExperience:(FMExperience *)experience markRead:(BOOL)read
{
    if (experience) {
        ExperienceManager *sharedInstance = [ExperienceManager defaultManager];
        
        
        [sharedInstance.savedExperiences insertObject:experience atIndex:0];
        [sharedInstance.internalExperiences addObject:experience];
        [sharedInstance alertAppOfNewlyPresentedExperience];
        
        NSNumber *experienceId = @(sharedInstance.savedExperiencesIds.count+1);
        [sharedInstance.savedExperiencesIds insertObject:experienceId atIndex:0];
        
        
        if (!read) {
            [sharedInstance.unreadExperiences addObject:experience];
        }
    }
}

+ (void)addExperience:(FMExperience *)experience {
    [self addExperience:experience markRead:NO];
}

+ (FMExperience *)returnPresentedExperience
{
    return [[ExperienceManager defaultManager].internalExperiences lastObject];
}

+(NSInteger)experienceCount
{
    return [[ExperienceManager defaultManager].internalExperiences count];
}

+(void)deleteExperienceWithId:(NSString *)expId {
    if ([[ExperienceManager defaultManager].internalExperiences count] > 0)
    {
        NSInteger index = -1;
        for(FMExperience *e in [ExperienceManager defaultManager].internalExperiences)
        {
            if([e.expId isEqualToString:expId])
            {
                index = [[ExperienceManager defaultManager].internalExperiences indexOfObject:e];
            }
        }
        if(index >= 0)
        {
            [[ExperienceManager defaultManager].internalExperiences removeObjectAtIndex:index];
            [[ExperienceManager defaultManager] alertAppOfNewlyPresentedExperience];
        }
    }
}

- (void) alertAppOfNewlyPresentedExperience
{
    FMExperience *topExp = [[ExperienceManager defaultManager].internalExperiences lastObject];
    if(topExp)
    {
        [[ExperienceManager defaultManager].delegate newPresentedExperience:topExp];
    }
}

+ (void)readExperiences:(NSArray *)experiences
{
    for (int i = (int32_t)experiences.count-1; i >= 0; i--) {
        FMExperience *experience = experiences[i];
        [[ExperienceManager defaultManager].unreadExperiences removeObject:experience];
    }
}

+ (NSArray *)unreadExperiences
{
    return [ExperienceManager defaultManager].unreadExperiences;
}

-(NSArray *)experiences {
    return [NSArray arrayWithArray:self.internalExperiences];
}

+(void)removeAllExperiences {
    [[[ExperienceManager defaultManager] internalExperiences] removeAllObjects];
}

+ (NSArray*) getProfiles
{
    return [ExperienceManager defaultManager].profiles;
}

+(void)fetchProfiles {
    FMRestApi *rest = [[FMRestApi alloc] init];
    NSString *at = [[FMAccount sharedInstance] getAccessToken];

    NSString *authStr = [NSString stringWithFormat:@"Bearer %@", at];
    NSDictionary *headers = @{@"Authorization":authStr,
                              @"Content-Type":@"application/json"};
    

    
    
    /*****************************************************************
     *                  ~~ Important ~~
     *
     *   Bug: NSJSONSerialization dataWithJSONObject throws an
     *        exception when an NSUUID object is set as the value
     *        for the dictionary that is passed to dataWithJSONObject.
     *        This method is tricky and only accepts a defined set of
     *        object types or it will throw an exception. I have never
     *        had any problems with NSStrings, so I switched it to that
     *
     *   Bug: switched device_id to an underscore as opposed to a hyphen
     *
     ******************************************************************/
    NSString *deviceId = [[ExperienceManager defaultManager] getAdvId];
    if([Helpers isStringNullOrEmpty:deviceId])
    {
        deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    NSDictionary *dict = [NSDictionary dictionaryWithObject:deviceId forKey:@"device_id"];
    
    @try {

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:(NSJSONWritingPrettyPrinted)
                                                             error:nil];
        NSString *jsonRequest = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        
        
        NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
        
        [rest postWithUrl:FMRestAPIURL headers:headers formData:requestData timeout:FMRestAPITimeout withCompletion:^(id responseObject, NSError *error)
         {
             if (!error)
             {
                 if([responseObject isKindOfClass:[NSData class]])
                 {
                     NSData *response = (NSData *)responseObject;
                     if (response)
                     {
                         NSArray *array = [NSJSONSerialization JSONObjectWithData:response options:0 error:nil];
                         if (array)
                         {
                             [[ExperienceManager defaultManager] addProfiles:array];
                         }
                     }
                 }
             }
         }];
        
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in fetchProfiles(): %@", exception);
    }
    
}

-(void)addProfiles:(NSArray *)profiles {
    _profiles = profiles;
}

- (NSString *) getAdvId
{
    static dispatch_once_t pred;
    static NSString *ret = nil;
    dispatch_once(&pred, ^{
        if (NSClassFromString(@"ASIdentifierManager"))
        {
            if (! [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled])
            {
                ret = @"";
            }
            else
            {
#ifdef PS_NO_IDFA_USAGE
                ret = @"";
#else
                ret = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
                if (ret == nil)
                {
                    ret = @"";
                }
#endif
            }
        } else {
            // we're on iOS5, and Apple disallows calls for UDID, so generate a
            // CFUUID as needed
            // ios5 is less than 8% of the market in use as of Sept 2013
            ret = @"";
        }
    });
    return ret;
}

// this is only used on iOS5
- (NSString *)getUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

+ (void)load
{
    // has it already loaded?
    if ([ExperienceManager defaultManager].savedExperiences
        && [ExperienceManager defaultManager].savedExperiences.count > 0) return;
    
    // setup
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    NSArray *savedExperiences = [ud objectForKey:kUserDefaultsExperiencesKey];
    if (!savedExperiences) savedExperiences = @[];
    
    NSArray *unreadExperiencesIDs = [ud objectForKey:kUserDefaultsUnreadExperienceIdsKey];
    if (!unreadExperiencesIDs) unreadExperiencesIDs = @[];
    
    NSMutableArray *loadExperienceIds = [NSMutableArray array];
    
    // decode save experiences from dictionary to native objects
    NSMutableArray *loadedExperiences = [NSMutableArray array];
    for (NSDictionary *dExperience in savedExperiences) {
        FMExperience *experience = [[FMExperienceManager sharedInstance] returnCorrectExp:dExperience];
        [loadedExperiences addObject:experience];
        NSNumber *identity = dExperience[kExperienceIdKey];
        if (!identity){
            [loadExperienceIds addObject:@(savedExperiences.count)];
        } else {
            [loadExperienceIds addObject:identity];
        }
        
    }
    
    // retrieve unread experiences from the decode list
    NSMutableArray *unreadExperiences = [NSMutableArray array];
    for (NSNumber *experienceId in unreadExperiencesIDs) {
        NSInteger index = [loadExperienceIds indexOfObject:experienceId];
        // if not found don't try to find the unread experience.
        //  Move on to the next one.
        if (index != NSNotFound) {
            FMExperience *foundexperience = loadedExperiences[index];
            if (foundexperience) {
                [unreadExperiences addObject:foundexperience];
            }
        }
    }
    
    // load
    [ExperienceManager defaultManager].savedExperiencesIds = loadExperienceIds;
    [ExperienceManager defaultManager].savedExperiences = loadedExperiences;
    [ExperienceManager defaultManager].unreadExperiences = unreadExperiences;
}

+ (void)save
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSArray *experiences = [ExperienceManager defaultManager].savedExperiences;
    NSArray *experiencesIds = [ExperienceManager defaultManager].savedExperiencesIds;
    NSMutableArray *unreadExperiencesIDs = [NSMutableArray array];
    NSMutableArray *newExperiences = [NSMutableArray array];
    NSNumber *countNumber = [ud objectForKey:kUserDefaultsExperiencesCountKey];
    if (!countNumber) countNumber = @0;
    
    // retrieve unread experience ids
    for (FMExperience *experience in [ExperienceManager defaultManager].unreadExperiences) {
        NSUInteger index = [experiences indexOfObject:experience];
        if (index != NSNotFound)
            [unreadExperiencesIDs addObject:experiencesIds[index]];
    }
    
    // key unread keys
    [ud setObject:unreadExperiencesIDs forKey:kUserDefaultsUnreadExperienceIdsKey];
    
    // read experiences - convert from navtive objects to dictionary objects.
    int newCount = (int32_t)(experiences.count - countNumber.intValue);
    for ( int i = 0; i < newCount; i++){
        FMExperience *experience = experiences[i];
        NSMutableDictionary *dExperience = [NSMutableDictionary dictionaryWithDictionary:
                                            [experience returnJsonDictForAttributes]];
        dExperience[kExperienceIdKey] = experiencesIds[i];
        [newExperiences addObject:dExperience];
    }
    
    // combine all experiences - old and new
    NSArray *savedExperiences = [ud objectForKey:kUserDefaultsExperiencesKey];
    if (!savedExperiences) savedExperiences = @[];
    NSArray *allExperiences = [newExperiences arrayByAddingObjectsFromArray:savedExperiences];
    
    // save
    [ud setObject:allExperiences forKey:kUserDefaultsExperiencesKey];
    [ud setObject:@(allExperiences.count) forKey:kUserDefaultsExperiencesCountKey];
    [ud synchronize];
}

+ (NSArray *)allExperiences
{
    return [ExperienceManager defaultManager].savedExperiences;
}

@end
