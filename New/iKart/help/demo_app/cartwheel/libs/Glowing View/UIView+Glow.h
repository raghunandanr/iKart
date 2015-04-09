//
//  UIView+Glow.m
//
//  Created by Jon Manning on 29/05/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <Foundation/NSObject.h>

@interface UIView (Glow) 

@property (nonatomic, readonly) UIView* glowView;
// set duration
- (void)setDurationBtw:(NSNumber*)durationBtw;
- (NSNumber *)durationBtw;

// Fade up, then down.
- (void) glowOnce;

// Useful for indicating "this object should be over there"
- (void) glowOnceAtLocation:(CGPoint)point inView:(UIView*)view;

- (void) startGlowing;
- (void) startGlowingWithColor:(UIColor*)color intensity:(CGFloat)intensity;
- (void) glowOnceWithColor:(UIColor *)color intensity:(CGFloat)intensity;
- (void) glowOnceAndKillAfterSecs: (int64_t)dur;
- (void) glowOnceAndRemoveAnimOnceCompleted;

- (void)startGlowingWithColor:(UIColor *)color intensity:(CGFloat)intensity withDuration: (NSNumber*) duration;
- (void) stopGlowing;

-(BOOL) isGlowing;

@end
