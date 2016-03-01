//
//  CHTimerView.h
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTimerLabel.h"

@class CHTimerView;
@protocol CHTimerDelegate <NSObject>
- (void)timerEnded:(CHTimerView *)timer;
@end


@interface CHTimerView : UIView

- (void)start;
- (void)freeze;
- (void)pause;
- (void)reset;

@property (nonatomic) id<CHTimerDelegate> delegate;

@property (nonatomic, readonly) CHTimerLabel *label;
@property (nonatomic, readonly) UIView *activeIndicatorLine;
@property (nonatomic, readonly) CGFloat activeIndicatorLineWidth;
@property (nonatomic, readonly) CGFloat activeIndicatorLineX;

@property (nonatomic) UITapGestureRecognizer *tapGesture;

@end
