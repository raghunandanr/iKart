//
//  MenuView.m
//  Coffee
//
//  Created by casey graika on 5/2/14.
//  Copyright (c) 2014 casey graika. All rights reserved.
//

#import "MenuView.h"
#define WIDTH 206
#define HEIGHT 162

@implementation MenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (id)initAndAddToView: (UIView*) view
{
    if (self) {
        
        NSBundle *bundle = [NSBundle mainBundle];
        
        if(bundle)
        {
            MenuView *rootView = [[bundle loadNibNamed:@"MenuView" owner:self options:nil] objectAtIndex:0];
            self = rootView;
        }
        
    }
    [self setBackgroundColor:[UIColor colorWithRed:(171.f/255.f) green:(171.f/255.f)
                                              blue:(171.f/255.f) alpha:1.0]];
    CGRect frame = [self frame];
    frame.origin.x = 0;
    frame.origin.y = 45;
    [self setFrame:frame];
    
    
    [self setHidden:NO];
    [view addSubview:self];
    [view bringSubviewToFront:self];
    
    
    return self;
}

-(IBAction)clickedReset:(id)sender
{
    [self removeFromSuperview];
    [self.delegate resetClickedInMV];
}

-(IBAction)clickedLogout:(id)sender
{
    [self removeFromSuperview];
    [self.delegate logoutClickedInMV];
}


@end
