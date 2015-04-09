//
//  OfferView.h
//  Footmarks-Demo
//
//  Created by Footmarks on 12/30/14.
//  Copyright (c) 2014 Ratio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Footmarks_SDK.h"



@interface OfferView : UIView
- (id) initWithNibAndExperience: (FMExperience *)exp andParentVC: (UIViewController*)pVC;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UILabel *lblTagline;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDiscount;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *viewVisualEfct;

@end
