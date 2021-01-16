//
//  CHTimerView.m
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimerView.h"
#import "UIColor+DarkModeShim.h"


@implementation CHTimerView

#pragma mark - Parent overrides

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[CHTimerLabel alloc] initWithFrame:CGRectMake(60, 10, 1, 1)];
        
        _activeIndicatorLine = ({
            UIView *view         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
            view.backgroundColor = CHColor.primaryBackgroundColor;
            view.center          = self.center;
            [view setFrameY:CGRectGetHeight(frame)-60];
            view;
        });
        [self addSubview:_label];
        [self addSubview:_activeIndicatorLine];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    
    [self.activeIndicatorLine setFrameY:CGRectGetHeight(self.frame)-60];
    if ((self.delegate.isPaused && self.delegate.timeLeft > 0) || !self.delegate.hasStarted) {
        [self.activeIndicatorLine setFrameX:CGRectGetWidth(self.frame)/2.f];
    } else {
        [self.activeIndicatorLine setFrameX:60];
        [self.activeIndicatorLine setFrameWidth:self.delegate.activeIndicatorLineWidth];
    }
    
    [_label centerXInView:self alignToBottomWithPadding:60];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Position active indicator line 60 pts above the bottom
    [self.activeIndicatorLine setFrameY:CGRectGetHeight(self.frame)-60];
    
    // Position label 60 pts above the bottom, center it, then
    // extend the width from it's right side to the right edge
    // of this view so the timer has room to expand without moving.
    [_label sizeToFit];
    [_label centerXInView:self alignToBottomWithPadding:60];
    CGFloat x      = CGFloatRound(CGRectGetMinX(_label.frame));
    CGFloat dw     = x;
    CGFloat width  = CGRectGetWidth(_label.frame) + dw;
    CGFloat height = CGRectGetHeight(self.frame)-70;
    CGFloat dy     = height - CGRectGetHeight(_label.frame);
    CGFloat y      = CGRectGetMinY(_label.frame) - dy;
    _label.frame   = CGRectMake(x, y, width, height);
}

#pragma mark - Public interface

@end
