//
//  CHTimerViewController.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimerViewController.h"
#import "CHTimerView.h"
#import "UIView+Util.h"


static NSInteger kButtonPadding = 60;

@interface CHTimerViewController () <CHTimerDelegate>

/// A is the upright one
@property (nonatomic, readonly) CHTimerView *timerViewA;
/// A is the upright one
@property (nonatomic, readonly) CHTimerView *timerViewB;

@property (nonatomic, readonly) NSDateComponentsFormatter *formatter;
@property (nonatomic, readonly) NSTimeInterval timeLimit;
@property (nonatomic, readonly) NSTimeInterval delayAmount;
@property (nonatomic, readonly) CHTimerType delayType;

@property (nonatomic, readonly) UIButton *pauseButton;
@property (nonatomic, readonly) UIButton *playButton;
@property (nonatomic, readonly) UIButton *resetButton;

@property (nonatomic) BOOL gameIsOver;

@end


@implementation CHTimerViewController

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    CGFloat width  = CGRectGetWidth(self.view.frame);
    CGFloat height = CGRectGetHeight(self.view.frame);
    
    // Frames of labels and tap areas
    CGFloat tapHeight      = height/2.f - 50;
    CGFloat tapUprightY    = height - tapHeight;
    CGRect tapUpright      = CGRectMake(0, tapUprightY, width, tapHeight);
    CGRect tapUpsideDown   = CGRectMake(0, 0, width, tapHeight);
    
    
    _timerViewA = [[CHTimerView alloc] initWithFrame:tapUpright];
    _timerViewB = [[CHTimerView alloc] initWithFrame:tapUpsideDown];
    _timerViewB.transform = CGAffineTransformMakeRotation(M_PI);
    _timerViewA.backgroundColor = [UIColor blackColor];
    _timerViewB.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:_timerViewA];
    [self.view addSubview:_timerViewB];
    
    // Buttons
    _pauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton  = [UIButton buttonWithType:UIButtonTypeCustom];
    _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_pauseButton addTarget:self action:@selector(pauseButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_playButton  addTarget:self action:@selector(playButtonPressed)  forControlEvents:UIControlEventTouchUpInside];
    [_resetButton addTarget:self action:@selector(resetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // Button icons
    [_pauseButton setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [_playButton  setBackgroundImage:[UIImage imageNamed:@"play"]  forState:UIControlStateNormal];
    [_resetButton setBackgroundImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
    [_pauseButton sizeToFit]; [_playButton sizeToFit]; [_resetButton sizeToFit];
    
#if DEBUG_VIEW
    self.timerViewA.backgroundColor = [UIColor darkGrayColor];
    self.timerViewB.backgroundColor = [UIColor darkGrayColor];
    self.timerViewA.label.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    self.timerViewB.label.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.500];
    UIView *tmp =  ({
        CGFloat h = tapUpright.origin.y - CGRectGetHeight(tapUpsideDown);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(tapUpsideDown), width, h)];
        view.backgroundColor = [UIColor grayColor];
        view;
    });
    [self.view addSubview:tmp];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Timer ended callback
    self.timerViewA.delegate = self;
    self.timerViewB.delegate = self;
    
    self.timerViewA.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleActiveTimer:)];
    self.timerViewB.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleActiveTimer:)];
    
    [self resetLabels];
}

- (void)resetLabels {
    [self.timerViewA reset];
    [self.timerViewB reset];
    self.timerViewA.label.totalTime = self.timeLimit;
    self.timerViewB.label.totalTime = self.timeLimit;
    
    self.timerViewA.label.delayAmount = self.delayAmount;
    self.timerViewB.label.delayAmount = self.delayAmount;
    self.timerViewA.label.delayType = self.delayType;
    self.timerViewB.label.delayType = self.delayType;
}

- (NSTimeInterval)timeLimit {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerTime];
}

- (NSTimeInterval)delayAmount {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerIncrement];
}

- (CHTimerType)delayType {
    return [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerStyle];
}

#pragma mark - Primary methods

- (void)toggleActiveTimer:(UITapGestureRecognizer *)sender {
    if (self.activeTimer == nil) {
        [self revealGameControls];
    }
    
    [self.activeTimer pause];
    
    // Swap active timer and toggle enabled gestures
    if (sender == self.timerViewA.tapGesture) {
        self.activeTimer = self.timerViewB;
        self.timerViewA.tapGesture.enabled = NO;
        self.timerViewB.tapGesture.enabled = YES;
    }
    else if (sender == self.timerViewB.tapGesture) {
        self.activeTimer = self.timerViewA;
        self.timerViewA.tapGesture.enabled = YES;
        self.timerViewB.tapGesture.enabled = NO;
    }
    
    [self.activeTimer start];
}

- (void)pause {
    [self.activeTimer freeze];
    
    // These are separate from the label's pause
    // method because this is a different kind of
    // "pause" than the usual pause of each label.
    [UIView animateWithDuration:0.2 animations:^{
        self.timerViewA.label.alpha = 0.5;
        self.timerViewB.label.alpha = 0.5;
    }];
}

- (void)resume {
    [self.activeTimer start];
    
    // These are separate from the label's start
    // method because this is a different kind of
    // "resume" than the usual start of each label.
    [UIView animateWithDuration:0.2 animations:^{
        self.timerViewA.label.alpha = 1;
        self.timerViewB.label.alpha = 1;
    }];
}

- (void)reset {
    [self resume];
    [self.activeTimer pause];
    self.activeTimer = nil;
    
    [self resetLabels];
    self.timerViewA.tapGesture.enabled = YES;
    self.timerViewB.tapGesture.enabled = YES;
}

#pragma mark - Helper methods

- (void)revealGameControls {
    self.pauseButton.alpha = 0;
    self.resetButton.alpha = 0;
    
    [self.resetButton centerYInView:self.view alignToRightWithPadding:kButtonPadding];
    [self.pauseButton centerYInView:self.view alignToLeftWithPadding:kButtonPadding];
    self.playButton.frame = self.pauseButton.frame;
    
    [self.view addSubview:self.pauseButton];
    [self.view addSubview:self.resetButton];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.pauseButton.alpha = 1;
        self.resetButton.alpha = 1;
    }];
}

- (void)hideGameControls {
    [UIView animateWithDuration:0.2 animations:^{
        self.playButton.alpha  = 0;
        self.pauseButton.alpha = 0;
        self.resetButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.playButton removeFromSuperview];
    }];
}

- (void)showGameOverControls {
    self.gameIsOver = YES;
    
    // Fade out and remove pause button
    [UIView animateWithDuration:0.2 animations:^{
        self.pauseButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.pauseButton removeFromSuperview];
    }];
    
    // Sweep in reset button
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.resetButton.center = self.view.center;
    } completion:nil];
}

- (void)resetButtonPressed {
    [self reset];
    
    if (self.gameIsOver) {
        // Add and fade in pause button
        [self.view addSubview:self.pauseButton];
        [self.pauseButton centerYInView:self.view alignToLeftWithPadding:kButtonPadding];
        
        // Fade out reset button, adjust frame;
        [UIView animateWithDuration:0.2 animations:^{
            self.resetButton.alpha = 0;
        }];
    } else {
        [self hideGameControls];
    }
}

- (void)togglePlayPauseButton {
    UIButton *reveal, *remove;
    if (self.pauseButton.alpha == 1) {
        reveal = self.playButton, remove = self.pauseButton;
    } else {
        reveal = self.pauseButton, remove = self.playButton;
    }
    
    reveal.alpha = 0;
    [self.view addSubview:reveal];
    
    [UIView animateWithDuration:0.2 animations:^{
        reveal.alpha = 1;
        remove.alpha = 0;
    } completion:^(BOOL finished) {
        [remove removeFromSuperview];
    }];
}

- (void)pauseButtonPressed {
    [self togglePlayPauseButton];
    [self pause];
}

- (void)playButtonPressed {
    [self togglePlayPauseButton];
    [self resume];
}

#pragma mark - CHTimerDelegate

- (void)timerEnded:(CHTimerLabel *)timer {
    self.timerViewA.tapGesture.enabled = NO;
    self.timerViewB.tapGesture.enabled = NO;
    [self showGameOverControls];
}

@end
