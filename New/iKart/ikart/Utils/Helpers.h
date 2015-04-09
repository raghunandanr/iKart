//
//  Helpers.h
//  
//
//  Created by casey graika on 6/23/14.
//  Copyright (c) 2014 Footmarks Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

//#define NSLog(FORMAT, ...) printf("%s\n", [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

@interface Helpers : NSObject

+ (BOOL) isStringNullOrEmpty: (NSString*)str;

+ (NSString*) capitalizeFirstLetterOnString: (NSString*) str;

+ (BOOL) doesView: (UIView*) view containASubviewOfClass: (Class)c;

+ (void) addViewsToScrollViewAndPositionCorrectly: (NSArray*)arr andScrollView: (UIView*)view;

+ (void) resizeLabel: (UILabel*) label  withFont: (UIFont*) font andText: (NSString*)text;

+ (void) adjustViewsYOriginForOldIphones: (UIView*) view;

+ (void) dynamicallySizeLabel: (UILabel *)label withNewText: (NSString*) text andCenterUnderView: (UIView*)view;

+ (void) dynamicallySizeLabel: (UILabel *)label withNewText: (NSString*) text andPlaceViewOnRightSideOfIt: (UIView*)view;

+ (void) dynamicallySizeLabel: (UILabel *)label withNewText: (NSString*) text andPlaceViewOnLeftSideOfIt: (UIView*)view;

+ (void) centerViewHorizontally: (UIView*)view withinFrame: (CGRect)frame;

+ (void) fadeViewOut: (UIView*)view withDur: (float) dur;

+ (void) fadeViewIn: (UIView *)view;

+ (void) fadeViewOutAndThenHideAndResetAlphaToOne: (UIView*)view withDur: (float) dur;

+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length;

+ (void) loadImageInBGThreadWithUrl: (NSString*)url andSetTo: (UIView*) view;

+ (void) loadImageInBGThreadWithUrl: (NSString*)url andSetTo: (UIView*) view withLoadIndColor: (UIColor *)color;

+ (void) displayLoadingViewOnView: (UIView*) parentView;

+ (void) removeLoadingViewFromParentView: (UIView *)parentView;

+ (void) removeViewsFrom: (UIView*) view ofClassType: (Class)class;

+ (void) sendNotification: (NSString*)notif withData: (NSDictionary*) dict;

+ (void) flipCurView: (UIView*) curView toView: (UIView*) destV basedOnTouches: (NSSet*) touches;

+ (NSString*) returnString: (NSString*) string trimmedByNumChars: (int) num;

+ (void) roundViewsCorners: (UIView*)view;

+ (CGRect) getScreenRes;

+ (CGRect) getScreenDimens;
@end
