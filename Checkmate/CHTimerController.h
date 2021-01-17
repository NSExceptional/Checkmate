//
//  CHTimerController.h
//  Checkmate
//
//  Created by Tanner on 3/4/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CHTimerController;
@protocol CHTimerDelegate <NSObject>
- (void)timerEnded:(CHTimerController *)timer;
@end


@interface CHTimerController : UIViewController

- (void)start;
- (void)freeze;
- (void)pause;
- (void)reset;

@property (nonatomic) id<CHTimerDelegate> delegate;

@property (nonatomic, readonly) BOOL hasStarted;
@property (nonatomic, readonly) BOOL isPaused;

/// Cannot be changed unless the timer has not started
@property (nonatomic          ) CHTimerType delayType;
@property (nonatomic          ) NSTimeInterval delayAmount;
@property (nonatomic          ) NSTimeInterval totalTime;
@property (nonatomic, readonly) NSTimeInterval timeLeft;

@property (nonatomic) NSDateFormatter *formatter;
@property (nonatomic) UIFont *font;

@property (nonatomic) UITapGestureRecognizer *tapGesture;

@property (nonatomic, readonly) CGFloat activeIndicatorLineWidth;
@property (nonatomic, readonly) CGFloat activeIndicatorLineX;

@end
