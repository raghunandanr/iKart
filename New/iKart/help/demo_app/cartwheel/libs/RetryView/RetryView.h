//
//  RetryView.h
//  
//
//  Created by casey graika on 9/15/14.
//  Copyright (c) 2014 Footmarks Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol RetryViewDelegate <NSObject>

- (void)retry: (id)sender;
- (void)cancel: (id)sender;
@end

@interface RetryView : UIView

- (id) initWithParentView: (UIView*) view andTitle: (NSString*)str;
- (void) animateAlert;

@property (nonatomic, weak) id <RetryViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnRetry;

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
-(IBAction)clickCancel:(id)sender;
-(IBAction)clickRetry:(id)sender;
@end
