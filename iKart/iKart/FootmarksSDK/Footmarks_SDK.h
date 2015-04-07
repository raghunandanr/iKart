//
//  Footmarks_SDK.h
//  
//
//  Created by casey graika on 6/4/14.
//  Copyright (c) 2014 Footmarks Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>


/************************************************************/

/*           Enum & Completion Block Definitions            */

/************************************************************/

typedef enum : char
{
    FMBeaconPowerLevelUnknown = -100,
    FMBeaconPowerLevel1 = -30,  // Shortest broadcast range
    FMBeaconPowerLevel2 = -20,
    FMBeaconPowerLevel3 = -16,
    FMBeaconPowerLevel4 = -12,
    FMBeaconPowerLevel5 = -8,
    FMBeaconPowerLevel6 = -4,
    FMBeaconPowerLevel7 = 0,
    FMBeaconPowerLevel8 = 4     // Furthest broadcast range
} FMBeaconPower;

typedef void(^FMCompletionBlock)(NSError* error);
typedef void(^FMPowerCompletionBlock)(FMBeaconPower value, NSError* error);

// Completion blocks for the FMRestAPI class
typedef void(^FMRestCompletion)(id responseObject, NSError *error);
typedef void(^FMArrayCompletionBlock)(NSArray *arr, NSError *error);
typedef void(^FMDictionaryCompletionBlock)(NSDictionary *dict, NSError *error);
typedef void(^FMBoolCompletionBlock)(BOOL value, NSError* error);

static NSString *kFMDemoAppLogoutNotification = @"kFMDemoAppLogoutNotification";

/************************************************************/

/*                    FMAccountDelegate                     */

/************************************************************/


@protocol FMAccountDelegate <NSObject>

/**
 * @method Delegate invoked upon successful authentication
 *
 * @return void
 */
- (void) loginSuccessful;

/**
 * @method Delegate invoked upon successful authentication
 *
 * @return NSString error An error description containing
 * the reason why authentication failed.
 */
- (void) loginUnsuccessful: (NSString*)error;

@end


/************************************************************/

/*                        FMAccount                         */

/************************************************************/


@interface FMAccount : NSObject

@property (nonatomic, assign) id<FMAccountDelegate>           accountDelegate;


/**
 * @method This method returns a reference to the FootmarksAccount singleton object
 *
 * @return FootmarksAccount Reference to the FootmarksAccount singleton
 */
+ (id) sharedInstance;

/**
 * @method This method returns the App Key.
 *
 * @return NSString The Footmarks assigned App Key for the current app.
 */
-(NSString*) getAppKey;

/**
 * @method This method returns the App Secret.
 *
 * @return NSString The Footmarks assigned App Secret for the current app.
 */
-(NSString*) getAppSecret;

/**
 * @method Set the access toke to be used for API calls to the server. In
 * most cases this method will not be needed.
 *
 * @param at The access token to be used for all API requests to the server.
 * @return void
 */
- (void) setUserAccessToken: (NSString*)at;

/**
 * @method Set the access toke to be used for API calls to the server. In
 * most cases this method will not be needed.
 *
 * @return NSString The current access token
 */
- (NSString*) getAccessToken;

- (void) setIsDemoApp;

/**
 * @method This method authenticates the app to the Footmarks cloud service.
 * Pass in the App Key, App Secret and userID for the app to be authenticated.
 *
 * @param appKey The App Key for this app that is shown in the Footmarks
 *        Management Console
 * @param appSecret The App Secret for this app that is shown in the Footmarks
 *        Management Console
 * @param userID The unique user ID for the current app. This is typically the
 *        Facebook ID for apps using SSO or a user assigned ID for apps using
 *        their own authentication system.
 *
 * @return void
 */
-(void)loginToFootmarksServer: (NSString*) appKey andAppSecret: (NSString*) appSecret andUserId: (NSString*)userID;


/**
 * @method Use this method to send the user's Facebook data to the Footmarks
 * cloud service. Sending this data allows for more robust analytics
 * and personalized experiences.
 *
 * @param dict FBGraphObject (dictionary subclass) that contains
 *        the currently logged in user's data
 *
 * @return void
 */
-(void) sendFBDataToFootmarksServer: (NSMutableDictionary*)dict;


/**
 * @method Enables smart user profiles in your application. This will allow
 * your Experiences to target the appropriate audience. Also, Smart
 * Profiles will provide more powerful analytics to the Footmarks
 * Platform.
 * @param application The currently running application
 * @param launchOptions The dictionary provided in the didFinishLaunchingWithOptions
 *                      callback
 *
 * @return void
 */
- (void) useSmartProfilesInApplication: (UIApplication*)application withLaunchOptions: (NSDictionary*)launchOptions;

/**
 *  Register the application to the beacon and experience management system.
 *
 *  @param application   the pass application from AppDelegate
 *  @param launchOptions the pass launchOptions from AppDelegate
 */
- (void) application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

@end


/************************************************************/

/*                        FMBeacon                          */

/************************************************************/


@interface FMBeacon : NSObject <CBPeripheralDelegate>


/**
 *  macAddress
 *
 *  Discussion:
 *    Hardware MAC address of the beacon.
 */
@property (nonatomic, strong)   NSString*               macAddress;

/**
 *  proximityUUID
 *
 *    Proximity identifier associated with the beacon.
 *
 */
@property (nonatomic, strong)   NSUUID*                 proximityUUID;

/**
 *  txPowerMngmtConsole
 *
 *    The txPower value shown in the Footmarks management console. This is an abstract value.
 *    This value is not represented in terms of dBm.
 */
@property int                                           txPowerMngmtConsole;

/**
 *  rssi
 *
 *    Received signal strength in decibels of the specified beacon.
 *    This value is an average of the RSSI samples collected since this beacon was last reported.
 *
 */
@property (nonatomic)           NSInteger               rssi;


/*
 *  CLLocationAccuracy
 *
 *    Represents how far a user is from the beacon in meters. This value
 *    provides the best approximation of a users location with respect to
 *    the beacon. accuracy makes use of rssi and the beacon's broadcast
 *    power.
 */
@property (nonatomic) CLLocationAccuracy accuracy;

/**
 *  proximity
 *
 *    The value in this property gives a general sense of the relative distance to the beacon.
 *      Use it to quickly identify beacons that are nearer to the user rather than farther away
 */
@property (nonatomic) CLProximity          proximity;

/**
 *  proximityiOSCalculation
 *
 *    The CLProximity calculated by iOS. This calculation can be used in conjunction with
 *    or alone when determining the users distance with respect to the beacon.
 */
@property (nonatomic) CLProximity          proximityiOSCalculation;

/**
 *  fmPeripheral
 *
 *    Reference of the device peripheral object.
 */
@property (nonatomic, strong)   CBPeripheral*           fmPeripheral;

/**
 *  role
 *
 *    What role the FMBeacon has been assigned to in the Footmarks Management
 *    console. An 'enter' beacon is a beacon that lies at the entrance of
 *    venue.
 */
@property (retain, nonatomic) NSString *role;

/**
 *  name
 *
 *    The name selected for the beacon in the Footmarks Management console.
 *    Typically the name chosen describes the area the beacon is placed in.
 *    For example, 'Men's Shoe Department'
 */
@property (nonatomic, retain) NSString *name;

/**
 *  tags
 *
 *    The user defined tags associated with this beacon. These can be
 configured in the Footmarks Management console.
 */
@property (nonatomic, retain) NSArray *tags;

/**
 *  dateOfLastImpression
 *
 *    The last time the current app user has came within range of this
 *    beacon.
 */
@property NSDate *dateOfLastImpression;

/**
 * @method This helper method returns the corresponding literal
 * string for the inputted proximity (prox)
 *
 * @param prox proximity to retrieve string for
 * @return NSString literal string for CLProximity value
 */
-(NSString*) stringForProximity: (CLProximity) prox;

@end


/************************************************************/

/*                    FMBeaconRegion                        */

/************************************************************/


@interface FMBeaconRegion : CLBeaconRegion

@end


@class FMBeaconManager;
/************************************************************/

/*                  FMBeaconManagerDelegate                 */

/************************************************************/

@protocol FMBeaconManagerDelegate <NSObject>

/**
 *  This delegate is called when the bluetooth state has changed.
 *
 *  @param mangerState
 */
- (void)bluetoothDidSwitchState:(CBCentralManagerState)state;

/**
 * @method Delegate method invoked when Location services has
 * been disabled by the user. This is where you should
 * notify the user to enable Location services in their
 * settings.
 *
 * @return void
 */
- (void) locationServicesFailedWithError: (NSError *)error;

@optional

/**
 * @method Delegate method invoked when Bluetooth functiionality
 * is disabled on user's handset. Within this method
 * you should alert user to enable Bluetooth
 *
 * @return void
 */
- (void) bluetoothTurnedOff __attribute__((deprecated));

/**
 * @method Delegate method invoked during ranging.
 * Allows to retrieve NSArray of all discoverd beacons
 * represented with FMBeacon objects.
 *
 * @param manager Footmarks beacon manager
 * @param beacons all beacons as FMBeacon objects
 * @param region Footmarks beacon region
 *
 * @return void
 */
- (void)beaconManager:(FMBeaconManager *)manager
      didRangeBeacons:(NSArray *)beacons
             inRegion:(FMBeaconRegion *)region;

/**
 * @method Delegate method invoked wehen ranging fails
 * for particular region. Related NSError object passed.
 *
 * @param manager Footmarks beacon manager
 * @param region Footmarks beacon region
 * @param error object containing error info
 *
 * @return void
 */
-(void)beaconManager:(FMBeaconManager *)manager
rangingBeaconsDidFailForRegion:(FMBeaconRegion *)region
           withError:(NSError *)error;

/**
 * @method Delegate method invoked wehen monitoring fails
 * for particular region. Related NSError object passed.
 *
 * @param manager Footmarks beacon manager
 * @param region Footmarks beacon region
 * @param error object containing error info
 *
 * @return void
 */
-(void)beaconManager:(FMBeaconManager *)manager
monitoringDidFailForRegion:(FMBeaconRegion *)region
           withError:(NSError *)error;
/**
 * @method Method triggered when iOS device enters Footmarks
 * beacon region during monitoring.
 *
 * @param manager Footmarks beacon manager
 * @param region Footmarks beacon region
 *
 * @return void
 */
-(void)beaconManager:(FMBeaconManager *)manager
      didEnterRegion:(FMBeaconRegion *)region;

/**
 * @method Method triggered when iOS device leaves Footmarks
 * beacon region during monitoring.
 *
 * @param manager Footmarks beacon manager
 * @param region Footmarks beacon region
 *
 * @return void
 */
-(void)beaconManager:(FMBeaconManager *)manager
       didExitRegion:(FMBeaconRegion *)region;

/**
 * @method Method triggered when Footmarks beacon region state
 * was determined using requestStateForRegion:
 *
 * @param manager Footmarks beacon manager
 * @param state Footmarks beacon region state
 * @param region Footmarks beacon region
 *
 * @return void
 */
-(void)beaconManager:(FMBeaconManager *)manager
   didDetermineState:(CLRegionState)state
           forRegion:(FMBeaconRegion *)region;

/**
 *  Delegate method invoked when beacon manager did start scanning
 *
 *  @param beaconManager Footmarks beacon manager
 */
- (void)beaconManagerDidStartScanningForBeacons:(FMBeaconManager *)manager;

/**
 *  Delegate method invoked when beacon manager did stop scanning
 *
 *  @param beaconManager Footmarks beacon manager
 */
- (void)beaconManagerDidStopScanningForBeacons:(FMBeaconManager *)manager;

@end


/************************************************************/

/*                    FMBeaconManager                       */

/************************************************************/

@class FMExperienceManager;
@interface FMBeaconManager : NSObject <CBCentralManagerDelegate, CBPeripheralManagerDelegate, CLLocationManagerDelegate>


+ (id) sharedInstance;

/*
 *  FMBeaconManagerDelegate
 *
 *    Delegate that handles all beacon related events. Assign the class
 *    you want to be informed about beacon callback events to this
 *    delegate.
 */
@property (nonatomic, weak) id <FMBeaconManagerDelegate> delegate;


/*
 *  curBluetoothState
 *
 *    Contains the device's current bluetooth (BT) state. This can be
 *    used to determine if a user's BT is disabled. Below is an
 *    example of how to check if a user's BT is turned off:
 *    if(curBluetoothState == CBCentralManagerStatePoweredOff)
 */
@property CBCentralManagerState curBluetoothState;


/**
 * @method
 * Returns an array that contains all FMBeacons that are in range of
 * the user
 *
 * @param void
 * @return array of FMBeacons
 */
- (NSArray*) getBeaconsInRange;

/**
 * @method
 * Triggers scanning & monitoring for FMBeacons
 *
 * @param void
 * @return void
 */
- (void) startScanningForFMBeacons __attribute__((deprecated));

/**
 * @method
 * Disables scanning & monitoring for FMBeacons
 *
 * @param void
 * @return void
 */
- (void) stopScanningForFMBeacons __attribute__((deprecated));

/**
 * @method
 * Triggers scanning & monitoring for FMBeacons. When call this, the framework will remember your last state. Even when the app quits or return an error, the app will continue to scan until call 'stopScanningForFMBeaconsWithError:'. The error is to help navigate the user to perform certain tasks to enable the SDK. Please look at FMBeaconManagerDelegate bluetoothDidSwitchState: to receive callbacks when the user change the bluetooth state.
 *
 * @param error   A pointer error. Be best if pass an error to know if any errors occurs.
 * @return void
 */
- (void) startScanningForFMBeaconsWithError:(NSError **)error;

/**
 * @method
 * Disables scanning & monitoring for FMBeacons
 *
 * @param error   A pointer error. Be best if pass an error to know if any errors occurs.
 * @return void
 */
- (void) stopScanningForFMBeaconsWithError:(NSError **)error;

/**
 * @method 
 * Returns whether or not the app is currently scanning
 * for Footmarks beacons
 *
 * @param void
 * @return BOOL a boolean indicating if the app is currently scanning
 *        for Footmarks beacons
 */
- (BOOL) isScanningForBeacons;

/**
 * @method 
 * Debug method used to simulate coming within range of a beacon
 *
 * @param beacon The beacon to simulate the user came within range of
 * @return void
 */
-(void) customerCameWithinRangeOfBeacon: (FMBeacon*) beacon;

@end


/************************************************************/

/*                   FMExperience                           */

/************************************************************/
@class FMExpContent;

/*!
 *  @enum FMExperienceType
 *
 *  @discussion Represents the type of epxerience
 *
 *  @constant FMExperienceTypeCustom       Custom experience
 *  @constant FMExperienceTypeVideo        Video experience
 *  @constant FMExperienceTypeImage        Image experience
 *  @constant FMExperienceTypeAlert        Alert experience
 *  @constant FMExperienceTypeHtml         HTML experience
 *  @constant FMExperienceTypeUrl          URL experience
 *  @constant FMExperienceTypeDefault      Default experience. This type has been deprecated
 *  @constant FMExperienceTypePassive      Passive experience
 *  @constant FMExperienceTypeUnknown      Unknown experience
 */
typedef enum : int
{
    FMExperienceTypeCustom,
    FMExperienceTypeVideo,
    FMExperienceTypeImage,
    FMExperienceTypeAlert,
    FMExperienceTypeHtml,
    FMExperienceTypeUrl,
    FMExperienceTypeDefault,
    FMExperienceTypePassive,
    FMExperienceTypeUnknown
} FMExperienceType;

#define FMExperienceTypeNameString(enum) [@[@"custom",@"video", @"image", @"alert", @"html",@"url",@"default",@"passive",@"unknown", @""] objectAtIndex:enum]


/*!
 *  @enum FMExperienceAction
 *
 *  @discussion Represents how and when this experience should be presented to the user.
 *
 *  @constant FMExperienceActionPassive       This experience should be passively
 *  displayed in the application.
 *  @constant FMExperienceActionAutoShow      This experience should appear in such
 *  a way that the user does not have to perform an action in order to see it.
 *  @constant FMExperienceActionPrompt        This experience should present a prompt
 *  before it appears. That is, it is the users choice if they would like to see it or not
 *  @constant FMExperienceActionUnknown       An action has not been declared for this experience.
 */
typedef enum : int
{
    FMExperienceActionPassive = 0,
    FMExperienceActionAutoShow = 1,
    FMExperienceActionPrompt = 2,
    FMExperienceActionUnknown = 3
} FMExperienceAction;

#define FMExperienceActionNameString(enum) [@[@"passive",@"autoShow", @"prompt", @""] objectAtIndex:enum]


/*!
 *  @enum FMConvertedAction
 *
 *  @discussion Represents how the user interacted with the experience
 *
 *  @constant FMConvertedActionNone       The user did not interact with the experience
 *  @constant FMConvertedActionWatched        The user watched the video within the experience.
 *  @constant FMConvertedActionClicked        The user clicked the experience displayed.
 *  @constant FMConvertedActionSwiped        The user swiped the experience displayed.
 *  @constant FMConvertedActionListened         The user listened to the audio within the experience.
 *  @constant FMConvertedActionShared          The user shared the experience
 *  @constant FMConvertedActionOpened      The user performed some action in order to open the experience
 *  @constant FMConvertedActionAutomated      The user was presented with the experience automatically
 *  @constant FMConvertedActionRetargeted      The user was retargeted with the experience.
 *  @constant FMConvertedActionCustom      A custom converted action was performed on the experience.
 */
typedef enum : int
{
    FMConvertedActionNone,
    FMConvertedActionWatched,
    FMConvertedActionClicked,
    FMConvertedActionSwiped,
    FMConvertedActionListened,
    FMConvertedActionShared,
    FMConvertedActionOpened,
    FMConvertedActionAutomated,
    FMConvertedActionRetargeted,
    FMConvertedActionCustom
} FMConvertedAction;

#define FMConvertedActionNameString(enum) [@[@"none",@"watched", @"click", @"swipe", @"listened", @"shared", @"opened", @"automated",@"retargeted",@"custom", @""] objectAtIndex:enum]

typedef enum : int
{
    FMConvertedValueTypeSeconds = 0,
    FMConvertedValueTypeMinutes = 1,
    FMConvertedValueTypeCurrency = 2,
    FMConvertedValueTypeQuantity = 3,
    FMConvertedValueTypeCustom = 4
} FMConvertedValueType;

#define FMConvertedValueNameString(enum) [@[@"timeInSeconds",@"timeInMinutes", @"currency",@"quantity", @"custom", @""] objectAtIndex:enum]

@interface FMExperience : NSObject

/**
 * @method 
 * Method that informs the Footmarks Server that a user has
 * performed some action on this FMExperience. Sending this information
 * allows for improved analytics.
 *
 * @param action The action the user performed on this experience.
 * @param vType The value associated with the action the user performed
 * on the experience.
 * @param value A numerical indication of to what extent the user converted
 * the experience.
 *
 * @return void
 */
-(void) sendConvertedExperienceWithType: (FMConvertedAction)action valueType: (FMConvertedValueType)vType andValue: (float)value;

/**
 * @method
 * Method that informs the Footmarks Server that a user has
 * performed some action on this FMExperience. Sending this information
 * allows for improved analytics. This method also allows for custom 
 * actions and custom values to be specified, allowing for flexible
 * analytics
 *
 * @param action The action the user performed on this experience. Insert
 * FMConvertedActionCustom if you plan to use the customAction parameter
 * @param customAction A string populated with a custom action name that
 * is not contained in the FMExperienceAction enum
 * @param vType The value associated with the action the user performed
 * on the experience. Insert FMConvertedValueTypeCustom if you plan on 
 * using the customValName parameter
 * @param customValName A value name not listed in the FMConvertedValueType
 * enum.
 * @param value A numerical indication of to what extent the user converted
 * the experience.
 *
 * @return void
 */
-(void) sendCustomConvertedExperienceWithType: (FMConvertedAction)action andCustomActionName:(NSString*)customAction valueType: (FMConvertedValueType)vType andCustomValueName: (NSString*)customValName andValue: (float)value;


/**
 * @method Method used to create a custom experience. All of the
 * parameters are optional.
 *
 * @param name Name of the Experience
 * @param type The experiences type
 * @param action Determines when the Experience is shown
 * @param customDetails Any custom string input
 * @param expTitle The title of the experience
 * @param expDes The description of the experience
 * @param notifTitle The title shown for the notification displayed
 *        to the user (if any)
 * @param notifDes The description of the notification displayed to
 *        the user (if any)
 * @param show A boolean indicating if a notification will be
 *        shown to the user
 * @param customArray A array containing any arbitary custom data
 * @param content A dictionary containing any arbitary custom data
 *
 * @return id The initialized FMExperience object
 */
- (id) initExperienceWithName: (NSString*)name type:(FMExperienceType)type action:(FMExperienceAction)action customDetails:(NSString*)customDetails expTitle:(NSString*)expTitle expDescription:(NSString*)expDes notificationTitle:(NSString*)notifTitle notificationDescription:(NSString*)notifDes showNotification:(BOOL)show customActions:(NSArray*)customArray expContent:(FMExpContent*)content;

/**
 * @method Method that stores this experience for the next time
 * a user with 'username' and/or 'deviceId' is detected
 * by the Footmarks system. Once this user is detected this
 * experience will be sent back to them in the callback 
 * didCompleteExperiences()
 *
 * @param username Username of the user you would like to deliver
 *        this experience to.
 * @param deviceId DeviceId of the user you would like to deliver
 *        this experience to.
 *
 * @return void
 */
- (void) sendExperienceToUser:(NSString*)username andDevice: (NSString*)deviceId;

/**
 *  @method Method to initialize the object with a predefined dictionary. 
 *  Usually pass from a server or a save
 *
 *  @param dict Dictionary list of experience attributes
 *
 *  @return instance
 */
-(id) initWithJSONDict:(NSDictionary*)dict;

/**
 *  Return a dictionary form of the object.
 *
 *  @return mutable dictionary
 */
- (NSMutableDictionary*) returnJsonDictForAttributes;

/**
 *  alertTitle
 *
 *  @return Display both title and description for notification.
 */
- (NSString *)alertTitle;

/**
 *  expId
 *
 *    The unique identifier for the experience
 */
@property (nonatomic, retain) NSString* expId;

/**
 *  name
 *
 *    The name of the experience within the Footmarks Management
 *    Console.
 */
@property (nonatomic, retain) NSString* name;

/**
 *  type
 *
 *    The type of experience this experience object contains.
 *    The various types can be found in the ExperienceType enum
 */
@property FMExperienceType type;

/**
 *  action
 *
 *    Determines what action to take in relation to the user
 *    prior to presenting the experience.
 */
@property FMExperienceAction action;

/**
 *  customDetails
 *
 *    Contains a custom string that does fall into any of the
 *    Footmarks pre-defined attributes.
 */
@property (nonatomic, retain) NSString* customDetails;

/**
 *  expTitle
 *
 *    The title of the experience.
 */
@property (nonatomic, retain) NSString* expTitle;

/**
 *  expDescription
 *
 *    A string that describes the experience.
 */
@property (nonatomic, retain) NSString* expDescription;

/**
 *  notificationTitle
 *
 *    Discussion:
 *    The title of the notification (if any) to present
 *    to the user.
 */
@property (nonatomic, retain) NSString* notificationTitle;

/**
 *  notificationDescription
 *
 *    A string describing the notification that is presented
 *    to the user.
 */
@property (nonatomic, retain) NSString* notificationDescription;

/**
 *  customActions
 *
 *    An array of values defined in the Footmarks Management Console.
 *    This array is intended to be used for attributes that lie 
 *    outside the ones provided in the console.
 *
 */
@property (nonatomic, retain) NSArray* customActions;

/**
 *  showNotif
 *
 *    A boolean indicating whether or not to present a notification
 *    to the user. 
 *
 */
@property BOOL showNotif;

/**
 *  content
 *
 *    Contains the attributes associated with the experience. These
 *    attributes vary based on the type of experience. All attributes
 *    can be found in the Footmarks Management console
 *
 */
@property NSMutableDictionary* content;


@end

/************************************************************/

/*               FMExperienceManagerDelegate                */

/************************************************************/


@protocol FMExperienceManagerDelegate <NSObject>

/**
 * @method Delegate method invoked when any experiences associated
 * with this app is complete. The completed experiences can
 * be found in the experiences array
 *
 * @param array of Experience objects
 * @return void
 */
- (void) didCompleteExperiences: (NSArray*) experiences;

@end


/************************************************************/

/*                   FMExperienceManager                    */

/************************************************************/

@interface FMExperienceManager : NSObject

+ (id) sharedInstance;

/**
 * @method Helper method to return a given experience type from an array
 *
 * @param type experience type to search the array for
 * @param arr array of experiences
 * @return FMExperience
 */
+ (FMExperience*) returnExperienceOfType: (FMExperienceType) type fromExpArray: (NSArray *)arr;

@property (nonatomic, weak) id <FMExperienceManagerDelegate> delegate;

/**
 *  @method
 *  Return an instance of a certain class that match the dictionary.
 *
 *  @param d The dictonary that contains the attributes of an experience.
 *
 *  @return return an abtract experience instance
 */
- (FMExperience*) returnCorrectExp: (NSDictionary *)d;

@end


/************************************************************/

/*                       FMVideoExp                         */

/************************************************************/

/**
 *  FMContentProvider
 *
 *    Enum containing the supported video types.
 *
 */
typedef enum : int
{
    FMContentProviderCustom,
    FMContentProviderYoutube,
    FMContentProviderVimeo
} FMContentProvider;
#define FMContentProviderNameString(enum) [@[@"custom",@"youtube", @"vimeo", @""] objectAtIndex:enum]

/**
 *  FMDisplayType
 *
 *    Enum containing how to display the video. The display 
 *    method is configured in the Footmarks Management Console
 *
 */
typedef enum : int
{
    FMDisplayTypeFullscreen,
    FMDisplayTypeLarge,
    FMDisplayTypeSmall
} FMDisplayType;
#define FMDisplayTypeNameString(enum) [@[@"fullscreen",@"large", @"small", @""] objectAtIndex:enum]


typedef void(^FMVideoCompletionBlock)(NSError *error);

@interface FMVideoExp : FMExperience

/**
 * @method Helper method to play a youtube video.
 *
 * @param viewCon UIViewController you would like to display the video in.
 * @param selFinished Method to invoke once the video has finished
 * @return void
 */
- (void) playYoutubeVideoUsingVC: (UIViewController*)viewCon withFinishedSelector: (SEL)selFinished;

/**
 * @method Helper method that parses the unique youtube video ID from
 * a URL.
 *
 * @param url Youtube video url that the video ID will be extracted from
 * @return NSString The Youtube video ID
 */
- (NSString*)getYoutubeVideoID:(NSString*)url;

/*
 *  displayType
 *
 *  Discussion:
 *    Indicates how to display the video. The display
      method is configured in the Footmarks Management Console
 */
@property FMDisplayType displayType;

/**
 *  contentProvider
 *
 *    Contains the content provider supplying the video
 *
 */
@property FMContentProvider contentProvider;

/**
 *  vidURL
 *
 *    URL to the video associated with this experience.
 *
 */
@property (nonatomic, retain) NSString *vidURL;

@end


/************************************************************/

/*                      FMImageExp                          */

/************************************************************/

@interface FMImageExp : FMExperience

/**
 * @method Helper method to asynchronously load and display the experiences
 * image in the specified UIImageView
 *
 * @param imgView The UIImageView to display the image in.
 * @return void
 */
- (void) presentPicInUIImageView:(UIImageView *)imgView;

/**
 *  imgURL
 *
 *    The URL for the image.
 *
 */
@property (nonatomic, retain) NSString *imgURL;

@end


/************************************************************/

/*                      FMAlertExp                          */

/************************************************************/

@interface FMAlertExp : FMExperience

/**
 * @method Helper method to present a UILocalNotification 
 * The text displayed in this notification will be the 
 * notification title text defined in the Footmarks Management
 * Console
 *
 * @return void
 */
- (void) showAlert;

@end


/************************************************************/

/*                      FMHTMLExp                           */

/************************************************************/

@interface FMHTMLExp : FMExperience

/**
 *  html
 *
 *    A string containing the HTML assocaited with this experience
 *
 */
@property (nonatomic, retain) NSString *html;

@end


/************************************************************/

/*                      FMUrlExp                            */

/************************************************************/

@interface FMUrlExp : FMExperience

/**
 *  url
 *
 *    A string containing the URL assocaited with this experience
 *
 */
@property (nonatomic, retain) NSString *url;

@end


/************************************************************/

/*                      FMCustomExp                         */

/************************************************************/

@interface FMCustomExp : FMExperience

/**
 *  text
 *
 *    A string containing the custom text entered into the 
 *    Content section of the Experience within the Footmarks
 *    Management Console
 *
 */
@property (nonatomic, retain) NSString *text;

@end


/************************************************************/

/*                       FMExpContent                       */

/************************************************************/

@interface FMExpContent : NSObject

/**
 * @method Initializes a correctly formatted experience content
 * object for an Image Experience.
 *
 * @return id
 */
- (id) initImageContentWithUrl: (NSString*)url;

/**
 * @method Initializes a correctly formatted experience content
 * object for a Video Experience.
 *
 * @return id
 */
- (id) initVideoContentWithProvider:(FMContentProvider)provider displayType:(FMDisplayType)displayType videoUrl:(NSString*)url;

/**
 * @method Initializes a correctly formatted experience content
 * object for a URL Experience.
 *
 * @return id
 */
- (id) initUrlContentWithUrl: (NSString*)url;

/**
 * @method Initializes a correctly formatted experience content
 * object for a HTML Experience.
 *
 * @return id
 */
- (id) initHtmlContentWithText: (NSString*)text;

/**
 * @method Initializes a correctly formatted experience content
 * object for a Custom Experience.
 *
 * @return id
 */
- (id) initCustomContentWithText: (NSString*)text;

@end


/************************************************************/

/*                      FMRestApi                           */

/************************************************************/

@interface FMRestApi : NSObject <NSURLConnectionDelegate>

/**
 *  httpStatusCode
 *
 *    The HTTP status code returned in the response
 *
 */
@property  NSInteger httpStatusCode;

- (id) init;

/**
 * @method Helper method to create a HTTP POST request to the server.
 *
 * @param urlStr Footmarks Server endpoint
 * @param headers HTTP headers
 * @param postData Body of the POST request
 * @param timeout Number of seconds until the POST request times out
 * @param completion The data returned from the request
 */
- (void)postWithUrl: (NSString*) urlStr headers:(NSDictionary *)headers formData: (NSData*) postData timeout:(NSTimeInterval)timeout  withCompletion: (FMRestCompletion)completion;


@end

