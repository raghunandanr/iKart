//
//  OfferView.m
//  Footmarks-Demo
//
//  Created by Footmarks on 12/16/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import "ExperienceView.h"
#import "Helpers.h"
#import "Footmarks_SDK.h"
#import "OffersViewController.h"
#import "ExperienceManager.h"
#import "FMXCDYouTubeVideoPlayerViewController.h"

@interface ExperienceView ()
{
    FMExperience *experience;
    UIViewController *parentVC;
    BOOL hasVideoPlayed;
}
@property (nonatomic, retain) FMXCDYouTubeVideoPlayerViewController *playerController;
@end


@implementation ExperienceView

- (id) initWithNibAndExperience: (FMExperience *)exp andParentVC: (UIViewController*)pVC
{
    NSBundle *bundle = [NSBundle mainBundle];
    
    if(bundle)
    {
        ExperienceView *aView = [[bundle loadNibNamed:@"ExperienceView" owner:self options:nil] objectAtIndex:0];
        self = aView;
        experience = exp;
        hasVideoPlayed = NO;
        parentVC = (OffersViewController*)pVC;
        [self setBackgroundColor:[[UIColor clearColor] colorWithAlphaComponent:0.8]];
        [self initialize];
    }
    
    return self;
}
- (void)initialize
{
    self.viewOuterContent.layer.cornerRadius = 10;
    self.viewOuterContent.layer.masksToBounds = YES;
    
    if(![Helpers isStringNullOrEmpty:experience.name])
    {
        [self.lblTitle setText:experience.name];
    }
    if(![Helpers isStringNullOrEmpty:experience.notificationDescription])
    {
        self.txtViewDes.text = experience.notificationDescription;
    }
    // Adjust view size for diff iphones
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGRect sbounds = mainScreen.bounds;
    [self setFrame:sbounds];
    
    CGRect f = self.viewOuterContent.frame;
    f.origin.x = (mainScreen.bounds.size.width / 2) - (f.size.width/2);
    [self.viewOuterContent setFrame:f];

    CGRect fb = self.btnCloseWebView.frame;
    CGRect fw = self.viewWebviewBar.frame;
    
    fb.origin.x = fw.size.width - (fb.size.width + 3.f);
    fb.origin.y = fw.origin.y + 3.f;
    [self.btnCloseWebView setFrame:fb];
}

- (FMExperience*) getOfferViewExperience
{
    return experience;
}

- (BOOL) hasPlayedVideo
{
    return hasVideoPlayed;
}

- (void) playVideo
{
    if(self.playerController)
    {
        hasVideoPlayed = YES;
        [self.playerController.moviePlayer play];
    }
}

- (void) configureWebExp
{
    [self.viewWebview setHidden:NO];
    [self.viewOuterContent setHidden:YES];

    if(experience.type == FMExperienceTypeHtml)
    {
        [self configureHtmlExperience];
    }
    else if(experience.type == FMExperienceTypeUrl)
    {
        [self configureUrlExperience];
    }
    else{}
}
- (void) configureNonWebExp
{
    [self.viewWebview setHidden:YES];
    [self.viewOuterContent setHidden:NO];
    if(experience.type == FMExperienceTypeImage)
    {
        [self configureImageExperience];
    }
    if(experience.type == FMExperienceTypeVideo)
    {
        [self configureVideoExperience];
    }
}

-(void)configureImageExperience
{
    FMImageExp *imageExp = (FMImageExp *)experience;
    
    if(![Helpers isStringNullOrEmpty:imageExp.imgURL])
    {
        NSURL *url = [NSURL URLWithString:imageExp.imgURL];
        self.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
    }
    else
    {
        [self adjustUIForInvalidExperienceWithError:@"Error: Image experience's URL is empty."];
    }
}

-(void)configureVideoExperience
{
    FMVideoExp *videoExp = (FMVideoExp *)experience;
    if(![Helpers isStringNullOrEmpty:videoExp.vidURL])
    {
        @try {
            NSString *videoId = [videoExp getYoutubeVideoID:videoExp.vidURL];
            if([videoId isEqualToString:@""])
            {
                [self adjustUIForInvalidExperienceWithError:@"Error: Invalid Youtube URL."];
                return;
            }
            else
            {
                self.playerController = [[FMXCDYouTubeVideoPlayerViewController alloc] initWithVideoIdentifier:videoId];
                [self.playerController presentInView:self.viewVideo];
            }
        }
        @catch (NSException *exception)
        {
            [self adjustUIForInvalidExperienceWithError:@"Error: Invalid Youtube URL."];
            NSLog(@"ConfigureVideoExperience threw an exception parsing the video url.");
        }
    }
}


-(void)configureUrlExperience
{
    FMUrlExp *urlExp = (FMUrlExp *)experience;
    if(![Helpers isStringNullOrEmpty:urlExp.url])
    {
        NSURL *url = [NSURL URLWithString:urlExp.url];
        NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
        [self.webView loadRequest:request];
    }
    else
    {
        [self adjustUIForInvalidExperienceWithError:@"Error: URL experience's URL is empty."];
    }
}

-(void)configureHtmlExperience
{
    NSLog(@"Configuring HTML Experience...");
    FMHTMLExp *he = (FMHTMLExp *)experience;
    if( ![Helpers isStringNullOrEmpty:he.html] )
    {
        [self.webView loadHTMLString:he.html baseURL:nil];
    }
    else
    {
        [self adjustUIForInvalidExperienceWithError:@"Error: HTML experience's data is empty."];
    }
}

- (void) adjustUIForInvalidExperienceWithError: (NSString*)err
{
    [self.lblTitle setText:err];
    [self.txtViewDes setText:@""];
}

- (IBAction)clickedBtnCloseContentView:(id)sender
{
    [self animateReturnToParent];
}

- (IBAction)clickedBtnCloseWebView:(id)sender
{
    [self animateReturnToParent];
}

- (void) animateReturnToParent
{
    if( (experience.type == FMExperienceTypeVideo) && (self.playerController != nil))
    {
        [self.playerController.moviePlayer stop];
    }
    [self.delegate experienceViewWillRemove:self experience:experience];
    [ExperienceManager deleteExperienceWithId:experience.expId];
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [self setAlpha:0.0];
        
    } completion:^(BOOL finished)
     {
         [self removeFromSuperview];
     }];
}

@end
