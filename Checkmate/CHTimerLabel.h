//
//  CHTimerLabel_.h
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CHTimerLabel : UILabel

- (void)start;
- (void)pauseUseDelay:(BOOL)useDelay;
- (void)reset;

+ (UIFont *)desiredFontForTextStyle:(CHTimerTextStyle)style;

@property (nonatomic, copy) void (^timeUpAction)();
@property (nonatomic, copy) void (^textStyleChangeAction)(CHTimerTextStyle);

@property (nonatomic, readonly) BOOL hasStarted;
@property (nonatomic, readonly) BOOL isPaused;

/// Cannot be changed unless the timer has not started
@property (nonatomic          ) CHTimerType delayType;
@property (nonatomic          ) NSTimeInterval delayAmount;
@property (nonatomic          ) NSTimeInterval totalTime;
@property (nonatomic, readonly) NSTimeInterval timeLeft;
@property (nonatomic, readonly) NSDate *referenceDate;

@property (nonatomic) NSDateFormatter *formatter;

@end
