//
//  CHTimerViewController.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHCountdownViewController.h"
#import "UIView+Util.h"


static NSInteger kButtonPadding = 60;

@interface CHCountdownViewController () <CHTimerDelegate>
/// A is the upright one
@property (nonatomic, readonly) CHTimerController *timerA;
/// A is the upright one
@property (nonatomic, readonly) CHTimerController *timerB;

@property (nonatomic, readonly) NSDateComponentsFormatter *formatter;
@property (nonatomic, readonly) NSTimeInterval timeLimit;
@property (nonatomic, readonly) NSTimeInterval delayAmount;
@property (nonatomic, readonly) CHTimerType delayType;

@property (nonatomic, readonly) UIButton *pauseButton;
@property (nonatomic, readonly) UIButton *playButton;
@property (nonatomic, readonly) UIButton *resetButton;

@property (nonatomic) BOOL gameIsOver;
@end

@implementation CHCountdownViewController

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
    
    // Timer views
    _timerA = [CHTimerController new];
    _timerB = [CHTimerController new];
    _timerA.view.frame = tapUpright;
    _timerB.view.frame = tapUpsideDown;
    _timerB.view.transform = CGAffineTransformMakeRotation(M_PI);
    _timerA.view.backgroundColor = [UIColor blackColor];
    _timerB.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:_timerA.view];
    [self.view addSubview:_timerB.view];
    
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
    [_pauseButton sizeToFit];
    [_playButton sizeToFit];
    [_resetButton sizeToFit];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Timer ended callback
    self.timerA.delegate = self;
    self.timerB.delegate = self;
    
    self.timerA.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleActiveTimer:)];
    self.timerB.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleActiveTimer:)];
    
    [self resetLabels];
}

/// Stop each timer and update their total time, delay amount, and delay type
- (void)resetLabels {
    [self.timerA reset];
    [self.timerB reset];
    self.timerA.totalTime = self.timeLimit;
    self.timerB.totalTime = self.timeLimit;
    
    self.timerA.delayAmount = self.delayAmount;
    self.timerB.delayAmount = self.delayAmount;
    self.timerA.delayType = self.delayType;
    self.timerB.delayType = self.delayType;
}

- (BOOL)isPaused {
    return self.timerA.isPaused && self.timerB.isPaused;
}

- (BOOL)hasStarted { return _activeTimer != nil; }

#pragma mark - Preference accessors

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
    if (!self.hasStarted) {
        [self revealGameControls];
    }
    
    [self.activeTimer pause];
    
    // Swap active timer and toggle enabled gestures
    if (sender == self.timerA.tapGesture) {
        self.activeTimer = self.timerB;
        self.timerA.tapGesture.enabled = NO;
        self.timerB.tapGesture.enabled = YES;
    }
    else if (sender == self.timerB.tapGesture) {
        self.activeTimer = self.timerA;
        self.timerA.tapGesture.enabled = YES;
        self.timerB.tapGesture.enabled = NO;
    }
    
    [self.activeTimer start];
    if (self.resumeAction) self.resumeAction();
}

- (void)pause {
    [self.activeTimer freeze];
    
    // These are separate from the label's pause
    // method because this is a different kind of
    // "pause" than the usual pause of each label.
    [UIView animateWithDuration:0.2 animations:^{
        self.timerA.view.alpha = 0.5;
        self.timerB.view.alpha = 0.5;
    }];
    
    if (self.pauseAction) self.pauseAction();
}

- (void)resume {
    [self.activeTimer start];
    
    // These are separate from the label's start
    // method because this is a different kind of
    // "resume" than the usual start of each label.
    [UIView animateWithDuration:0.2 animations:^{
        self.timerA.view.alpha = 1;
        self.timerB.view.alpha = 1;
    }];
    
    if (self.resumeAction) self.resumeAction();
}

- (void)reset {
    [self.activeTimer pause];
    self.activeTimer = nil;
    
    [self resetLabels];
    self.timerA.tapGesture.enabled = YES;
    self.timerB.tapGesture.enabled = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.timerA.view.alpha = 1;
        self.timerB.view.alpha = 1;
    }];
    
    if (self.resetAction) self.resetAction();
}

#pragma mark - Button actions

- (void)resetButtonPressed {
    [self reset];
    
    // Reposition both buttons and hide them
    if (self.gameIsOver) {
        // Add and fade in pause button
        self.pauseButton.alpha = 0;
        [self.view addSubview:self.pauseButton];
        [self.pauseButton centerYInView:self.view alignToLeftWithPadding:kButtonPadding];
        
        // Fade out reset button, adjust frame
        [UIView animateWithDuration:0.2 animations:^{
            self.resetButton.alpha = 0;
        }];
    }
    // Simply hide both buttons
    else {
        [self hideGameControls];
    }
}

- (void)pauseButtonPressed {
    [self togglePlayPauseButton];
    [self pause];
}

- (void)playButtonPressed {
    [self togglePlayPauseButton];
    [self resume];
}

#pragma mark - Helper methods

/// Called once to add and position the buttons in the view
- (void)revealGameControls {
    self.pauseButton.alpha = 0;
    self.resetButton.alpha = 0;
    self.playButton.alpha  = 0;
    
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

/// Called when the reset button is pressed during a paused game
- (void)hideGameControls {
    // Just in case
    [self.pauseButton removeFromSuperview];
    
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
    self.pauseButton.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.5 animations:^{
        self.pauseButton.alpha = 0;
    } completion:^(BOOL finished) {
        self.pauseButton.userInteractionEnabled = YES;
        [self.pauseButton removeFromSuperview];
    }];
    
    // Sweep in reset button
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.resetButton.center = self.view.center;
    } completion:nil];
}

/// Swap the play and pause buttons based on wither the pause button is visible
- (void)togglePlayPauseButton {
    UIButton *reveal, *remove;
    if (self.pauseButton.alpha == 1) {
        reveal = self.playButton;
        remove = self.pauseButton;
    } else {
        reveal = self.pauseButton;
        remove = self.playButton;
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

#pragma mark - CHTimerDelegate

- (void)timerEnded:(CHTimerController *)timer {
    self.timerA.tapGesture.enabled = NO;
    self.timerB.tapGesture.enabled = NO;
    [self showGameOverControls];
}

@end
