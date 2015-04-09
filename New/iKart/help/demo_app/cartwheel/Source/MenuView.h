//
//  MenuView.h
//  Coffee
//
//  Created by casey graika on 5/2/14.
//  Copyright (c) 2014 casey graika. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MenuViewDelegate <NSObject>

- (void)resetClickedInMV;
- (void)logoutClickedInMV;

@end

@interface MenuView : UIView

@property (nonatomic, weak) id <MenuViewDelegate> delegate;


- (id)initAndAddToView: (UIView*) view;
@property (weak, nonatomic) IBOutlet UIView *viewReset;
@property (weak, nonatomic) IBOutlet UIButton *btnReset;
@property (weak, nonatomic) IBOutlet UIButton *btnLogout;

-(IBAction)clickedReset:(id)sender;
-(IBAction)clickedLogout:(id)sender;
@end
