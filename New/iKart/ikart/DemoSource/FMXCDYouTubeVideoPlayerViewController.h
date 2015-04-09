//
//  FMXCDYouTubeVideoPlayerViewController.h
//  FMXCDYouTubeVideoPlayerViewController
//
//  Created by Cédric Luthi on 02.05.13.
//  Copyright (c) 2013 Cédric Luthi. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, FMXCDYouTubeVideoQuality) {
	FMXCDYouTubeVideoQualitySmall240  = 36,
	FMXCDYouTubeVideoQualityMedium360 = 18,
	FMXCDYouTubeVideoQualityHD720     = 22,
	FMXCDYouTubeVideoQualityHD1080    = 37,
};

MP_EXTERN NSString *const FMXCDYouTubeVideoErrorDomain;
MP_EXTERN NSString *const FMXCDMoviePlayerPlaybackDidFinishErrorUserInfoKey; // NSError key for the `MPMoviePlayerPlaybackDidFinishNotification` userInfo dictionary

enum {
	FMXCDYouTubeErrorInvalidVideoIdentifier = 2,   // The given `videoIdentifier` string is invalid (including `nil`)
	FMXCDYouTubeErrorRemovedVideo           = 100, // The video has been removed as a violation of YouTube's policy
	FMXCDYouTubeErrorRestrictedPlayback     = 150  // The video is not playable because of legal reasons or the this is a private video
};

MP_EXTERN NSString *const FMXCDYouTubeVideoPlayerViewControllerDidReceiveMetadataNotification;
// Metadata notification userInfo keys, they are all optional
MP_EXTERN NSString *const FMXCDMetadataKeyTitle;
MP_EXTERN NSString *const FMXCDMetadataKeySmallThumbnailURL;
MP_EXTERN NSString *const FMXCDMetadataKeyMediumThumbnailURL;
MP_EXTERN NSString *const FMXCDMetadataKeyLargeThumbnailURL;

@interface FMXCDYouTubeVideoPlayerViewController : MPMoviePlayerViewController

- (id) initWithVideoIdentifier:(NSString *)videoIdentifier;

@property (nonatomic, copy) NSString *videoIdentifier;

// On iPhone, defaults to @[ @(FMXCDYouTubeVideoQualityHD720), @(FMXCDYouTubeVideoQualityMedium360), @(FMXCDYouTubeVideoQualitySmall240) ]
// On iPad, defaults to @[ @(FMXCDYouTubeVideoQualityHD1080), @(FMXCDYouTubeVideoQualityHD720), @(FMXCDYouTubeVideoQualityMedium360), @(FMXCDYouTubeVideoQualitySmall240) ]
// If you really know what you are doing, you can use the `itag` values as described on http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
// Setting this property to nil restores its default values
@property (nonatomic, copy) NSArray *preferredVideoQualities;

// Ownership of the FMXCDYouTubeVideoPlayerViewController instance is transferred to the view.
- (void) presentInView:(UIView *)view;

@end
