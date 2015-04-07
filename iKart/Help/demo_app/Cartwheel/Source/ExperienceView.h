//
//  OfferView.h
//  Footmarks-Demo
//
//  Created by Footmarks on 12/16/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Footmarks_SDK.h"

@protocol ExperienceViewDelegate;

@interface ExperienceView : UIView
- (id) initWithNibAndExperience: (FMExperience *)exp andParentVC: (UIViewController*)pVC;
- (void) configureWebExp;
- (void) configureNonWebExp;
- (FMExperience*) getOfferViewExperience;
- (BOOL) hasPlayedVideo;
- (void) playVideo;

@property (nonatomic, weak) id<ExperienceViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIView *viewVideo;

@property (weak, nonatomic) IBOutlet UIView *viewOuterContent;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtViewDes;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (weak, nonatomic) IBOutlet UIView *viewWebview;
@property (weak, nonatomic) IBOutlet UIButton *btnCloseWebView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIView *viewWebviewBar;
- (IBAction)clickedBtnCloseContentView:(id)sender;
- (IBAction)clickedBtnCloseWebView:(id)sender;

@end


@protocol ExperienceViewDelegate <NSObject>

- (void)experienceViewWillRemove:(ExperienceView *)view experience:(FMExperience *)experience;

@end