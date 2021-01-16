//
//  CHTimerController.m
//  Checkmate
//
//  Created by Tanner on 3/4/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimerController.h"
#import "CHTimerView.h"
#import "UIColor+DarkModeShim.h"


@interface CHTimerController () <CHTimerStateDelegate>
@property (nonatomic, readonly) CHTimerLabel *label;
@property (nonatomic, readonly) UIView *activeIndicatorLine;

@property (nonatomic) NSDate *referenceDate;
@property (nonatomic) NSTimeInterval timeSpent;
@property (nonatomic) NSTimeInterval visibleTime;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimer *flashTimer;
@end

@implementation CHTimerController

- (void)loadView {
    CHTimerView *timer   = [[CHTimerView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    timer.delegate       = self;
    _label               = timer.label;
    _activeIndicatorLine = timer.activeIndicatorLine;
    self.view            = timer;    
    
    self.formatter = [NSDateFormatter new];
    self.formatter.dateFormat = kFormatDefault;
    self.formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.totalTime = 420;
}

#pragma mark - Properties

- (NSTimer *)timer {
    if (!_timer) {
        self.timer = [NSTimer timerWithTimeInterval:kTimerInterval target:self selector:@selector(tick) userInfo:nil repeats:YES];
    }
    
    return _timer;
}

- (NSTimer *)flashTimer {
    if (!_flashTimer) {
        self.flashTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(flash) userInfo:nil repeats:YES];
    }
    
    return _flashTimer;
}

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
    
    // These if statements help determine when we need
    // to reposition the label so that it is centered.
    // The label cannot simply be centered because the
    // font is not monospaced and the constant movement
    // of the label would otherwise be distracting.
    
    // Hours
    if (self.formatter.dateFormat != kFormatHours && timeLeft >= 3600) {
        self.formatter.dateFormat = kFormatHours;
        newStyle = CHTimerTextStyleHours;
    }
    // Sub ten, ie 0:05.2
    else if (timeLeft < 10) {
        if (self.formatter.dateFormat != kFormatSubTen) {
            self.formatter.dateFormat = kFormatSubTen;
            newStyle = CHTimerTextStyleSubTen;
        }
    }
    // Default, ie 3:26
    else if (self.formatter.dateFormat != kFormatDefault && timeLeft < 3600) {
        self.formatter.dateFormat = kFormatDefault;
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
    
    self.label.text = [self.formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:timeLeft]];
    if (newStyle) {
        [self labelTextStyleShouldUpdate:newStyle];
    }
    
    self.visibleTime = timeLeft;
}

- (void)setTotalTime:(NSTimeInterval)totalTime {
    // Only allow changing of this property if the timer has not started
    if (!self.hasStarted) {
        _totalTime = totalTime;
        self.label.textColor = CHColor.primaryTextColor;
        [self displayTime:totalTime];
    }
}

- (void)setTapGesture:(UITapGestureRecognizer *)tapGesture {
    if (_tapGesture) {
        [self.view removeGestureRecognizer:_tapGesture];
    }
    if (tapGesture) {
        [self.view addGestureRecognizer:tapGesture];
    }
    
    _tapGesture = tapGesture;
}

- (UIFont *)font { return self.label.font; }

- (void)setFont:(UIFont *)font {
    self.label.font = font;
}

- (CGFloat)activeIndicatorLineWidth {
    return CGRectGetWidth(self.view.frame) - 60;
}

- (CGFloat)activeIndicatorLineX {
    return (CGRectGetWidth(self.view.frame) - self.activeIndicatorLineWidth) / 2.f;
}

#pragma mark - Public interface

- (void)start {
    if (!self.isPaused) return;
    self.referenceDate = [NSDate date];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.activeIndicatorLine setFrameX:self.activeIndicatorLineX];
        [self.activeIndicatorLine setFrameWidth:self.activeIndicatorLineWidth];
    }];
}

- (void)pause {
    [self pauseUseDelay:YES];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.activeIndicatorLine setFrameX:CGRectGetWidth(self.view.frame)/2.f];
        [self.activeIndicatorLine setFrameWidth:0];
    }];
}

- (void)freeze {
    [self pauseUseDelay:NO];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.activeIndicatorLine setFrameX:CGRectGetWidth(self.view.frame)/2.f];
        [self.activeIndicatorLine setFrameWidth:0];
    }];
}

- (void)pauseUseDelay:(BOOL)useDelay {
    if (self.isPaused) return;
    [self.timer invalidate];
    self.timer = nil;
    
    NSTimeInterval timeSincePause = [[NSDate date] timeIntervalSinceDate:_referenceDate];
    self.referenceDate = nil;
    
    // Timer pause increment
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
    self.flashTimer    = nil;
    self.timer         = nil;
    self.referenceDate = nil;
    self.timeSpent     = 0;
    self.label.textColor = CHColor.primaryTextColor;
    
    [self displayTime:self.totalTime];
    
    self.activeIndicatorLine.backgroundColor = CHColor.primaryTextColor;
}

#pragma mark - Private interface

- (void)labelTextStyleShouldUpdate:(CHTimerTextStyle)style {
    self.label.font = [[self.label class] desiredFontForTextStyle:style];
    NSLog(@"Changed font size: %@", @(self.label.font.pointSize));
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)tick {
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
    self.timeSpent = _totalTime;
    
    self.label.textColor = [UIColor colorWithRed:0.705 green:0.209 blue:0.226 alpha:1.000];
    self.activeIndicatorLine.backgroundColor = self.label.textColor;
    [self.delegate timerEnded:self];
    
    // Begin flashing
    [[NSRunLoop mainRunLoop] addTimer:self.flashTimer forMode:NSDefaultRunLoopMode];
}

- (void)flash {
    // Flashes the label on and off
    UIColor *old = self.label.textColor;
    self.label.textColor = [UIColor clearColor];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // Don't change the color to red unless the flash timer is active
        if (_flashTimer) {
            self.label.textColor = old;
        }
    });
}

@end
