//
//  MusicPlaySlider.m
//  StreamMusicPlayer
//
//  Created by Mac Developer001 on 8/8/16.
//  Copyright © 2016 SCN. All rights reserved.
//

#import "MusicPlaySlider.h"

@implementation MusicPlaySlider

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    UIImage *sliderThumb = [UIImage imageNamed:@"Slider_Thumb.png"];
    [self setTintColor:[UIColor colorWithRed:139.0f/255.0f green:49.0f/255.0f blue:158.0f/255.0f alpha:1.0f]];
    [self setThumbImage:sliderThumb forState:UIControlStateNormal];
    [self setThumbImage:sliderThumb forState:UIControlStateHighlighted];
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect customBounds = [super trackRectForBounds:bounds];
    customBounds.size.height = 1;
    return customBounds;
}

@end
