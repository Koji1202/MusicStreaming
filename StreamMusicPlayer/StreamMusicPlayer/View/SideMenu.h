//
//  SideMenu.h
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 9/13/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenu : UIView

- (void)showView:(CGFloat)width;
- (void) hideView;

@property (weak, nonatomic) IBOutlet UIView *homeView;
@property (weak, nonatomic) IBOutlet UIView *likeView;
@property (weak, nonatomic) IBOutlet UIView *settingView;
@property (weak, nonatomic) IBOutlet UIView *helpView;

@end
