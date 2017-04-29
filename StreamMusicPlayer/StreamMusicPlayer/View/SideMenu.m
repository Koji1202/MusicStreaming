//
//  SideMenu.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 9/13/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "SideMenu.h"

@implementation SideMenu

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)showView:(CGFloat)width {
    self.hidden = FALSE;
    self.userInteractionEnabled = TRUE;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setFrame:CGRectMake(0, self.frame.origin.y, width, self.frame.size.height)];
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hideView {
    self.userInteractionEnabled = FALSE;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self setFrame:CGRectMake(-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
        [self updateConstraints];
        
    } completion:^(BOOL finished) {
        [self setFrame:CGRectMake(-self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height)];
    }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
            CGPoint convertedPoint = [subview convertPoint:point fromView:self];
            UIView *hitTestView = [subview hitTest:convertedPoint withEvent:event];
            if (hitTestView) {
                return hitTestView;
            }
        }
        return self;
    }
    [self hideView];
    return nil;
}

@end
