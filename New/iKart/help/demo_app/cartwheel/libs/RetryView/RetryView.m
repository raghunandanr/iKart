//
//  RetryView.m
//
//
//  Created by casey graika on 9/15/14.
//  Copyright (c) 2014 Footmarks Inc. All rights reserved.
//

#import "RetryView.h"

@interface RetryView ()
{
    UIView *pView;
    CGPoint alertDefaultPosition;

}

@end

@implementation RetryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id) initWithParentView: (UIView*) view andTitle: (NSString*)str
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    if(bundle)
    {
        RetryView *aView = [[bundle loadNibNamed:@"RetryView" owner:self options:nil] objectAtIndex:0];
        self = aView;
        pView = view;
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 1.0f;
        [self.lblTitle setText:str];
        [self initialize];
    }
    return self;
}

- (void) initialize
{
    float x = pView.frame.size.width/2;
    float y = (pView.frame.size.height/2);
    alertDefaultPosition = pView.center;
    alertDefaultPosition.x = x;
    alertDefaultPosition.y = y;
    [self setHidden:YES];
    [pView addSubview:self];
}

- (void) animateAlert
{
    
    dispatch_async( dispatch_get_main_queue(), ^
                   {
                       [self setHidden:NO];
                       // Get the alert just off the screen
                       [self moveAlertOffScreen];
                       
                       
                       [self animateToNewCenter:alertDefaultPosition andHide:NO];
                       
                   });
    
}

- (void) moveAlertOffScreen
{
    // Get the alert just off screen
    self.center = CGPointMake(self.center.x, self.center.y - [UIScreen mainScreen].bounds.size.height / 2);
}

- (void) animateToNewCenter: (CGPoint) newC andHide: (BOOL) hide
{
    
    dispatch_async( dispatch_get_main_queue(), ^
                   {
                       [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^
                        {
                            
                            self.center = newC;
                            
                        }completion:^(BOOL finished)
                        {
                            if(hide)
                            {
                                [self setHidden:YES];
                            }
                        }];
                   });
    
}

-(IBAction)clickCancel:(id)sender
{
    float y = (0 - self.frame.size.height);
    CGPoint center = CGPointMake(self.center.x, y);
    [self animateToNewCenter:center andHide:YES];
    [self.delegate cancel: self];
    [self removeFromSuperview];
}
-(IBAction)clickRetry:(id)sender
{
    [self.delegate retry: self];
    [self removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
