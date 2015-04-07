//
//  OfferView.m
//  Footmarks-Demo
//
//  Created by Footmarks on 12/30/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "OfferView.h"
#import "OffersViewController.h"
#import "OffersManager.h"
#import "ExperienceManager.h"

@interface OfferView ()
{
    FMExperience *experience;
    OffersViewController *parentVC;
    BOOL isValid;
}
@property (nonatomic, strong) NSDictionary *currentOffer;

@end

@implementation OfferView

- (id) initWithNibAndExperience: (FMExperience *)exp andParentVC: (UIViewController*)pVC
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    if(bundle)
    {
        OfferView *aView = [[bundle loadNibNamed:@"OfferView" owner:self options:nil] objectAtIndex:0];
        self = aView;
        experience = exp;
        parentVC = (OffersViewController*)pVC;
        [self initialize];
    }
    
    return self;
}

- (void)initialize
{
    isValid = YES;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;

    self.viewVisualEfct.layer.borderColor = [UIColor blackColor].CGColor;
    self.viewVisualEfct.layer.borderWidth = 1.0f;
    self.center = parentVC.view.center;
    
    if (experience)
    {
        @try
        {
            [self parseExperience];
        }
        @catch (NSException *exception)
        {
            isValid = NO;
            NSLog(@"ERROR: Exception while attempting to parse the experience in AddOfferViewController");
            [self.lblTitle setText:@"ERROR: Custom experience not configured properly for this app."];
        }
        @finally
        {
            [self layoutLabels];
        }
    }

}

-(void)parseExperience
{
    if (experience.content)
    {
        NSString *content = (NSString *)experience.content[@"text"];
        NSArray *split = [content componentsSeparatedByString:@"\n"];
        NSLog(@"%@", split);
        NSMutableDictionary *offerDict = [NSMutableDictionary dictionary];
        for (NSString *element in split) {
            NSArray *subSplit = [element componentsSeparatedByString:@":"];
            if ([subSplit count] == 2) {
                NSString *key = subSplit[0];
                NSString *value = subSplit[1];
                if ([key isEqualToString:@"discount"])
                {
                    NSNumber *discount = [NSNumber numberWithInteger:[value integerValue]];
                    offerDict[key] = discount;
                }
                else
                {
                    offerDict[key] = value;
                }
            }
        }
        _currentOffer = offerDict;
    }
}

-(void)layoutLabels
{
    if (self.currentOffer)
    {
        NSString *title = (NSString *)self.currentOffer[@"name"];
        NSNumber *discount = (NSNumber *)self.currentOffer[@"discount"];
        NSString *tagline = (NSString *)self.currentOffer[@"tagline"];
        NSString *imageName = (NSString *)self.currentOffer[@"image"];
        
        if (title)
        {
            self.lblTitle.text = title;
        }
        else
        {
            isValid = NO;
            [self.lblTitle setText:@"ERROR: Custom experience not configured properly for this app."];
        }
        if (tagline) {
            self.lblTagline.text = tagline;
        }
        if (discount) {
            self.lblDiscount.text = [NSString stringWithFormat:@"%@%% OFF", discount];
        }
        if (imageName) {
            self.imgView.image = [UIImage imageNamed:imageName];
        }
    }
}

- (IBAction)addButtonTapped:(id)sender
{
    if(isValid)
    {
        [OffersManager addOffer:self.currentOffer];
    }
    [self animateReturnToParent];
}

- (IBAction)cancelButtonTapped:(id)sender
{
    [self animateReturnToParent];
}

- (void) animateReturnToParent
{
    [parentVC removeExperienceViewWithExpId:experience.expId];
    [ExperienceManager deleteExperienceWithId:experience.expId];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setAlpha:0.0];
        
    } completion:^(BOOL finished)
     {
         [[NSNotificationCenter defaultCenter] postNotificationName:@"ExperienceViewDismissed" object:nil];
         [self removeFromSuperview];
     }];
    
}


@end
