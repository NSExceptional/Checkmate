//
//  CHTimerLabel_.m
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimerLabel.h"


@interface CHTimerLabel ()
@property (nonatomic) NSTimeInterval timeSpent;
@property (nonatomic) NSTimeInterval visibleTime;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *flashTimer;
@end

@implementation CHTimerLabel

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [[self class] desiredFontForTextStyle:CHTimerTextStyleDefault];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentLeft;
        
        self.formatter = [NSDateFormatter new];
        self.formatter.dateFormat = kFormatDefault;
        self.formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    
    return self;
}

+ (UIFont *)desiredFontForTextStyle:(CHTimerTextStyle)style {
    return [UIFont systemFontOfSize:[[self class] desiredFontSizeForTextStyle:style] weight:UIFontWeightUltraLight];
}

+ (CGFloat)desiredFontSizeForTextStyle:(CHTimerTextStyle)style {
    BOOL bigger = [UIScreen mainScreen].scale == 3;
    switch (style) {
        case CHTimerTextStyleDefault: {
            return bigger ? 122 : 110;
        }
        case CHTimerTextStyleHours: {
            return bigger ? 111 : 100;
        }
        case CHTimerTextStyleSubTen: {
            return bigger ? 111 : 100;
        }
    }
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }
    
    return _timer;
}

- (NSTimer *)flashTimer {
    if (!_flashTimer) {
        _flashTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(flash) userInfo:nil repeats:YES];
    }
    
    return _flashTimer;
}

#pragma mark - Public interface

- (BOOL)isPaused { return _timer == nil; }

- (BOOL)hasStarted { return _totalTime > self.timeLeft; }

- (NSTimeInterval)timeLeft {
    if (self.isPaused) {
        return _totalTime - _timeSpent;
    }
    
    return _totalTime - (_timeSpent + [[NSDate date] timeIntervalSinceDate:_referenceDate]);
}

- (void)displayTime:(NSTimeInterval)timeLeft {
    CHTimerTextStyle newStyle = 0;
    
    // Hours
    if (_formatter.dateFormat != kFormatHours && timeLeft >= 3600) {
        _formatter.dateFormat = kFormatHours;
        newStyle = CHTimerTextStyleHours;
    }
    // Sub ten, ie 0:05.2
    else if (timeLeft < 10) {
        if (_formatter.dateFormat != kFormatSubTen) {
            _formatter.dateFormat = kFormatSubTen;
            newStyle = CHTimerTextStyleSubTen;
        }
    }
    // Default, ie 3:26
    else if (_formatter.dateFormat != kFormatDefault && timeLeft < 3600) {
        _formatter.dateFormat = kFormatDefault;
        newStyle = CHTimerTextStyleDefault;
    }
    // Digits lost
    else if ((_visibleTime >= 600 && timeLeft < 600) || // 10:00 -> 9:59
             (_visibleTime >= 120 && timeLeft < 120) || // 2:00  -> 1:59
             (timeLeft < 60 && _visibleTime >= 60)) {   // 1:00  -> 0:59
        newStyle = CHTimerTextStyleDefault;
    }
    // Digits gained
    else if ((_visibleTime < 3600 && timeLeft >= 3600) ||
             (_visibleTime < 600 && timeLeft >= 600) ||
             (_visibleTime < 120 && timeLeft >= 120) ||
             (timeLeft >= 60 && _visibleTime < 60)) {
        if (timeLeft >= 540)
            newStyle = CHTimerTextStyleDefault;
    }
    //
    
    self.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeLeft]];
    if (newStyle) {
        if (self.textStyleChangeAction) self.textStyleChangeAction(newStyle);
    }
    
    _visibleTime = timeLeft;
}

- (void)setTotalTime:(NSTimeInterval)totalTime {
    if (!self.hasStarted) {
        _totalTime     = totalTime;
        self.textColor = [UIColor whiteColor];
        [self displayTime:totalTime];
    }
}

- (void)start {
    if (!self.isPaused) return;
    _referenceDate = [NSDate date];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)pauseUseDelay:(BOOL)useDelay {
    if (self.isPaused) return;
    [self.timer invalidate];
    self.timer = nil;
    
    NSTimeInterval timeSincePause = [[NSDate date] timeIntervalSinceDate:_referenceDate];
    _referenceDate = nil;
    
    // Timer pause delay
    NSTimeInterval delay = useDelay ? self.delayAmount : 0;
    if (self.delayType == CHTimerTypeBronstein) {
        delay = MIN(timeSincePause, delay);
    }
    self.timeSpent += timeSincePause - delay;
    [self displayTime:_visibleTime + delay];
}

- (void)reset {
    [_flashTimer invalidate];
    [_timer invalidate];
    _flashTimer    = nil;
    _timer         = nil;
    _referenceDate = nil;
    _timeSpent     = 0;
    
    [self displayTime:self.totalTime];
}

- (void)tick {
    [self updateTimer];
}

- (void)updateTimer {
    NSTimeInterval timeLeft = MAX(self.timeLeft, 0.0);
    
    // Update text only if text would change, if low power mode is on
    if (timeLeft >= 10 && [NSProcessInfo processInfo].lowPowerModeEnabled) {
        if ((NSInteger)timeLeft != (NSInteger)_visibleTime) {
            [self displayTime:timeLeft];
        }
    } else {
        [self displayTime:timeLeft];
    }
    
    if (timeLeft == 0) {
        [self timeUp];
    }
}

- (void)timeUp {
    [self.timer invalidate];
    self.timer = nil;
    _timeSpent = _totalTime;
    
    if (self.timeUpAction) self.timeUpAction();
    
    // Begin flashing
    [[NSRunLoop mainRunLoop] addTimer:self.flashTimer forMode:NSDefaultRunLoopMode];
}

- (void)flash {
    UIColor *old = self.textColor;
    self.textColor = [UIColor clearColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.textColor = old;
    });
}

@end
