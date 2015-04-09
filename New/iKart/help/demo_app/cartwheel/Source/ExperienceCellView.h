//
//  ExperienceCellView.h
//  ShoppingCart
//
//  Created by Nate R on 1/30/15.
//  Copyright (c) 2015 Footmarks. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Footmarks_SDK.h"

@interface ExperienceCellView : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *typeImageView;
@property (nonatomic, weak) FMExperience *experience;


@end
