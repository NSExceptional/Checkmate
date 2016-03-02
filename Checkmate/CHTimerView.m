//
//  CHTimerView.m
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimerView.h"


@implementation CHTimerView

#pragma mark - Parent overrides

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _label = [[CHTimerLabel alloc] initWithFrame:CGRectMake(60, 10, 1, 1)];
        _label.totalTime = 420;
        _label.delegate  = self;
        
        _activeIndicatorLine = ({
            UIView *view         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 3)];
            view.backgroundColor = [UIColor whiteColor];
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
    if ((self.label.isPaused && self.label.timeLeft > 0) || !self.label.hasStarted) {
        [self.activeIndicatorLine setFrameX:CGRectGetWidth(self.frame)/2.f];
    } else {
        [self.activeIndicatorLine setFrameX:60];
        [self.activeIndicatorLine setFrameWidth:self.activeIndicatorLineWidth];
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

- (CGFloat)activeIndicatorLineWidth {
    return CGRectGetWidth(self.frame) - 60;
}

- (CGFloat)activeIndicatorLineX {
    return (CGRectGetWidth(self.frame) - self.activeIndicatorLineWidth) / 2.f;
}

- (void)setTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (_tapGesture) {
        [self removeGestureRecognizer:_tapGesture];
    }
    if (tapGesture) {
        [self addGestureRecognizer:tapGesture];
    }
    
    _tapGesture = tapGesture;
}

- (void)start {
    [self.label start];
    [UIView animateWithDuration:0.2 animations:^{
        [self.activeIndicatorLine setFrameX:self.activeIndicatorLineX];
        [self.activeIndicatorLine setFrameWidth:self.activeIndicatorLineWidth];
    }];
}

- (void)freeze {
    [self.label pauseUseDelay:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.activeIndicatorLine setFrameX:CGRectGetWidth(self.frame)/2.f];
        [self.activeIndicatorLine setFrameWidth:0];
    }];
}

- (void)pause {
    [self.label pauseUseDelay:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.activeIndicatorLine setFrameX:CGRectGetWidth(self.frame)/2.f];
        [self.activeIndicatorLine setFrameWidth:0];
    }];
}

- (void)reset {
    [self.label reset];
    self.label.textColor = [UIColor whiteColor];
    self.activeIndicatorLine.backgroundColor = [UIColor whiteColor];
}

#pragma mark - CHTimerLabelDelegate

- (void)timeUp:(CHTimerLabel *)label {
    label.textColor = [UIColor colorWithRed:0.705 green:0.209 blue:0.226 alpha:1.000];
    self.activeIndicatorLine.backgroundColor = self.label.textColor;
    [self.delegate timerEnded:self];
}

- (void)label:(CHTimerLabel *)label textStyleShouldChange:(CHTimerTextStyle)newStyle {
    label.font = [[label class] desiredFontForTextStyle:newStyle];
    NSLog(@"Changed font size: %@", @(label.font.pointSize));
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

@end
