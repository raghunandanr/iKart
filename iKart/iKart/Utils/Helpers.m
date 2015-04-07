//
//  Helpers.m
//
//
//  Created by casey graika on 6/23/14.
//  Copyright (c) 2014 Footmarks Inc. All rights reserved.
//

#import "Helpers.h"

#define TAG_LOAD_VIEW 731
#define TAG_IND_LOAD 732

static double IPHONE_5_SIZE = 568.0;
static double IPHONE_4_SIZE = 480.0;

@implementation Helpers

+ (BOOL) isStringNullOrEmpty: (NSString*)str
{
    if( (str == nil) || ( [str isKindOfClass:[NSNull class]] )
       || [str isEqualToString:@""])
    {
        return YES;
    }
    else
        return NO;
}

+ (NSString*) capitalizeFirstLetterOnString: (NSString*) str
{
    return [str stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[str substringToIndex:1] capitalizedString]];
}

+ (BOOL) doesView: (UIView*) view containASubviewOfClass: (Class)c
{
    for(UIView *v in [view subviews])
    {
        if([v isKindOfClass:c])
        {
            return YES;
        }
    }
    return NO;
}

+ (void) addViewsToScrollViewAndPositionCorrectly: (NSArray*)arr andScrollView: (UIView*)scrollView
{
    for(UIView *view in arr)
    {
        float startLoc = 0.f;
        CGRect svF = [view frame];
        NSUInteger index = [arr indexOfObject:view];
        
        if(index == 0)
        {
            svF.origin.y = scrollView.superview.bounds.origin.y;
            startLoc = svF.origin.y - svF.size.height;
        }
        else
        {
            CGRect fL = [[arr objectAtIndex:(index -1)] frame];
            float y = fL.origin.y + fL.size.height + 10;
            svF.origin.y = y;
            startLoc = fL.origin.y;
        }
        float x = (scrollView.frame.size.width - view.frame.size.width)/2;
        svF.origin.x = x;

        [scrollView addSubview:view];
        
        [Helpers fadeAndSlideViewIn:view andNewFrame:svF andStartLoc:startLoc];
    }
}

+ (void) fadeAndSlideViewIn: (UIView *)view andNewFrame: (CGRect) newFrame andStartLoc: (float) start
{
    CGRect oldFrame = view.frame;
    oldFrame.origin.y = start;
    [view setFrame:oldFrame];
    [view setAlpha:0.0];
    [view setHidden:NO];
    [UIView animateWithDuration:1.5f
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         //Set the frame you want to the search bar
                         [view setAlpha:1.0];
                         [view setFrame:newFrame];
                     }
                     completion:^(BOOL finished)
     {
         
     }];
}

+ (void) centerViewHorizontally: (UIView*)view withinFrame: (CGRect)frame
{
    float fW = frame.size.width;
    float vW = view.frame.size.width;
    
    float x = (fW - vW)/2;
    CGRect f = view.frame;
    f.origin.x = x;
    [view setFrame:f];
}

+ (void) resizeLabel: (UILabel*) label  withFont: (UIFont*) font andText: (NSString*)text
{
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         font}];
    CGRect rect = [label frame];
    rect.size.width = size.width;
    rect.size.height = size.height;
    [label setFrame:rect];
}

+ (void) dynamicallySizeLabel: (UILabel *)label withNewText: (NSString*) text andPlaceViewOnRightSideOfIt: (UIView*)view
{
    UIFont *font = label.font;
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         font}];
    CGRect rect = [label frame];
    rect.size.width = size.width;
    [label setFrame:rect];
    
    double x = label.frame.origin.x + label.frame.size.width + 5;
    CGRect frame = [view frame];
    frame.origin.x = x;
    [view setFrame:frame];
}

+ (void) dynamicallySizeLabel: (UILabel *)label withNewText: (NSString*) text andCenterUnderView: (UIView*)view
{
    CGRect frame = [view frame];
    double y = frame.origin.y + frame.size.height + 5;
    
    UIFont *font = label.font;
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         font}];
    CGRect rect = [label frame];
    rect.size.width = size.width;
    rect.size.height = size.height;
    
    double lblX = view.center.x - (rect.size.width /2);
    rect.origin.y = y;
    rect.origin.x = lblX;
    [label setFrame:rect];
}

+ (void) dynamicallySizeLabel: (UILabel *)label withNewText: (NSString*) text andPlaceViewOnLeftSideOfIt: (UIView*)view
{
    UIFont *font = label.font;
    CGSize size = [text sizeWithAttributes:
                   @{NSFontAttributeName:
                         font}];
    CGRect rect = [label frame];
    rect.size.width = size.width;
    [label setFrame:rect];
    
    double x = label.frame.origin.x - view.frame.size.width - 5;
    CGRect frame = [view frame];
    frame.origin.x = x;
    [view setFrame:frame];
}

+ (void) fadeViewIn: (UIView *)view withDur: (float) dur
{
    [view setAlpha:0.0];
    [view setHidden:NO];
    [UIView animateWithDuration:dur
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         //Set the frame you want to the search bar
                         [view setAlpha:1.0];
                     }
                     completion:^(BOOL finished)
     {
         
     }];
}

+ (void) fadeViewOut: (UIView*)view withDur: (float) dur
{
    [UIView animateWithDuration:dur
                          delay:0.f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         //Set the frame you want to the search bar
                         [view setAlpha:0.0];
                     }
                     completion:^(BOOL finished)
     {
         [view removeFromSuperview];
         
     }];
    
}

+ (void) fadeViewOutAndThenHideAndResetAlphaToOne: (UIView*)view withDur: (float) dur
{
    [UIView animateWithDuration:dur
                          delay:0.f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [view setAlpha:0.0];
                     }
                     completion:^(BOOL finished)
     {
         [view setHidden:YES];
         [view setAlpha:1.0];
         
     }];
    
}


+ (void) fadeViewIn: (UIView *)view
{
    [view setAlpha:0.0];
    [view setHidden:NO];
    [UIView animateWithDuration:1.5f
                          delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         //Set the frame you want to the search bar
                         [view setAlpha:1.0];
                     }
                     completion:^(BOOL finished)
     {
         
     }];
    
    
}

+ (void) fadeViewOut: (UIView*)view
{
    [UIView animateWithDuration:1.5f
                          delay:3.5f
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         //Set the frame you want to the search bar
                         [view setAlpha:0.0];
                     }
                     completion:^(BOOL finished)
     {
         [view removeFromSuperview];
         
     }];
    
}



+ (NSString *)randomAlphanumericStringWithLength:(NSInteger)length
{
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i = 0; i < length; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex:arc4random() % [letters length]]];
    }
    
    return randomString;
}

+ (void) loadImageInBGThreadWithUrl: (NSString*)url andSetTo: (UIView*) view
{
    if(url)
    {
        UIActivityIndicatorView *indLoad = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indLoad startAnimating];
        CGPoint viewCenter = [view center];
        viewCenter.x -= (indLoad.frame.size.width/2);
        [indLoad setCenter:viewCenter];
        [indLoad setTag:TAG_IND_LOAD];
        [view addSubview:indLoad];
        [view bringSubviewToFront:indLoad];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
                       {
                           
                           
                           NSData *data0 = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                           UIImage *image = [UIImage imageWithData:data0];
                           
                           dispatch_sync(dispatch_get_main_queue(), ^(void)
                                         {
                                             if([view isKindOfClass:[UIButton class]])
                                             {
                                                 [(UIButton*)view setImage:image forState:UIControlStateNormal];
                                             }
                                             else if([view isKindOfClass:[UIImageView class]])
                                             {
                                                 [(UIImageView*)view setImage:image];
                                             }
                                             else
                                             {
                                                 
                                             }
                                             UIView *v = [view viewWithTag:TAG_IND_LOAD];
                                             if(v)
                                             {
                                                 [v removeFromSuperview];
                                             }
                                         });
                       });
    }
    else
        return;
    
}

+ (void) loadImageInBGThreadWithUrl: (NSString*)url andSetTo: (UIView*) view withLoadIndColor: (UIColor *)color
{
    if(url)
    {
        UIActivityIndicatorView *indLoad = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indLoad setColor:color];
        [indLoad startAnimating];
        CGPoint viewCenter = [view center];
        viewCenter.x -= (indLoad.frame.size.width/2);
        [indLoad setCenter:viewCenter];
        [indLoad setTag:TAG_IND_LOAD];
        [view addSubview:indLoad];
        [view bringSubviewToFront:indLoad];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void)
                       {
                           
                           
                           NSData *data0 = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
                           UIImage *image = [UIImage imageWithData:data0];
                           
                           dispatch_sync(dispatch_get_main_queue(), ^(void)
                                         {
                                             if([view isKindOfClass:[UIButton class]])
                                             {
                                                 [(UIButton*)view setImage:image forState:UIControlStateNormal];
                                             }
                                             else if([view isKindOfClass:[UIImageView class]])
                                             {
                                                 [(UIImageView*)view setImage:image];
                                             }
                                             else
                                             {
                                                 
                                             }
                                             UIView *v = [view viewWithTag:TAG_IND_LOAD];
                                             if(v)
                                             {
                                                 [v removeFromSuperview];
                                             }
                                         });
                       });
    }
    else
        return;
    
}


+ (void) displayLoadingViewOnView: (UIView*) parentView
{
    if(parentView)
    {
        UIView *view = [[UIView alloc] initWithFrame:parentView.frame];
        [view setTag:TAG_LOAD_VIEW];
        [view setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.85]];
        
        UIActivityIndicatorView *indLoad = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indLoad startAnimating];
        CGPoint viewCenter = [view center];
        viewCenter.y -= (viewCenter.y / 4);
        [indLoad setCenter:viewCenter];
        [view addSubview:indLoad];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Refreshing...";
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack"
                                     size:20.f];
        [label setTextColor:[UIColor whiteColor]];
        [view addSubview:label];
        
        [Helpers dynamicallySizeLabel:label withNewText:label.text andCenterUnderView:indLoad];
        
        
        [parentView addSubview:view];
        [parentView bringSubviewToFront:view];
        [parentView setUserInteractionEnabled:NO];
    }
    
}

+ (void) removeLoadingViewFromParentView: (UIView *)parentView
{
    if(parentView)
    {
        UIView *view = [parentView viewWithTag:TAG_LOAD_VIEW];
        if(view)
        {
            [view removeFromSuperview];
        }
        [parentView setUserInteractionEnabled:YES];
    }
}

+ (void) removeViewsFrom: (UIView*) view ofClassType: (Class)class
{
    NSArray *arr = [view subviews];
    for(UIView *v in arr)
    {
        if([v isKindOfClass:class])
        {
            [v removeFromSuperview];
        }
    }
}

+ (void) sendNotification: (NSString*)notif withData: (NSDictionary*) dict
{
    [[NSNotificationCenter defaultCenter] postNotificationName: notif object:nil userInfo:dict];
}

+ (NSString*) returnString: (NSString*) string trimmedByNumChars: (int) num
{
    NSInteger count = [string length];
    if(num > count)
    {
        return string;
    }
    else
    {
        return [string substringWithRange:NSMakeRange(0, (count - num))];
    }
    
}

+ (void) flipCurView: (UIView*) curView toView: (UIView*) destV basedOnTouches: (NSSet*) touches
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:curView];
    if( touchPoint.x <= curView.center.x )
    {
        [UIView transitionFromView:curView toView:destV duration:1.0 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished)
         {
         }];
    }
    else
    {
        [UIView transitionFromView:curView toView:destV duration:1.0 options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished)
         {
         }];
    }
    
}

+ (void) adjustViewsYOriginForOldIphones: (UIView*) view
{
    
    double ratio = (IPHONE_4_SIZE/IPHONE_5_SIZE);
    ratio = (ratio - 0.01);
    CGRect frame = view.frame;
    frame.origin.y = (ratio * frame.origin.y);
    [view setFrame:frame];
}

+ (void) roundViewsCorners: (UIView*)view
{
    view.layer.cornerRadius = 9.0;
    view.layer.masksToBounds = YES;
    view.layer.borderColor = [UIColor clearColor].CGColor;
    view.layer.borderWidth = 3.0;
    CGRect frame = view.frame;
    frame.size.width = 100;
    frame.size.height = 100;
    view.frame = frame;
}

+ (CGRect) getScreenRes
{
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGRect screenResolution = [[UIScreen mainScreen] bounds];
    screenResolution.size.width *= screenScale;
    screenResolution.size.height *= screenScale;
    return screenResolution;
}

+ (CGRect) getScreenDimens
{
    return [[UIScreen mainScreen] bounds];
}

@end
