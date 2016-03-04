//
//  CHPageViewController.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHPageViewController.h"
#import "CHCountdownViewController.h"
#import "CHSettingsViewController.h"


@interface CHPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, readonly) CHCountdownViewController *timerViewController;
@property (nonatomic, readonly) CHSettingsViewController *settingsViewController;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehaviour;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;

@property (nonatomic, readonly) BOOL enablePaging;
@end


@implementation CHPageViewController

- (id)init {
    return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate           = self;
    self.dataSource         = self;
    _timerViewController    = [CHCountdownViewController new];
    _settingsViewController = [CHSettingsViewController new];
    
    // Disable scrolling when the timer is active
#pragma clang diagnostic ignored "-Warc-retain-cycles"
    self.timerViewController.pauseAction  = ^{ self.scrollEnabled = YES; };
    self.timerViewController.resumeAction = ^{ self.scrollEnabled = NO; };
    self.timerViewController.resetAction  = ^{ self.scrollEnabled = YES; };
    
    [self setViewControllers:@[_timerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    BOOL shouldBounce = ![[NSUserDefaults standardUserDefaults] boolForKey:kPref_DidBounce];
    
    if (shouldBounce) {
        self.view.userInteractionEnabled = NO;
        [self setupBounceAnimation];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!self.timerViewController.activeTimer) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kPref_DidBounce];
                
                // Display message
                [self presentSettingsNotification];
                // Actually bounce after 1 second
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self bounceTimerView];
                });
            }
        });
    }
}

- (void)setupBounceAnimation {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[self.timerViewController.view]];
    // Create a boundary that lies above the top edge of the screen
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(-300, 0, 0, 0)];
    [self.animator addBehavior:collisionBehaviour];
    
    self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[self.timerViewController.view]];
    self.gravityBehaviour.gravityDirection = CGVectorMake(0, 1);
    [self.animator addBehavior:self.gravityBehaviour];
    
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.timerViewController.view] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.magnitude = 0.0f;
    self.pushBehavior.angle = 0.0f;
    [self.animator addBehavior:self.pushBehavior];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[self.timerViewController.view]];
    itemBehaviour.elasticity = 0.6f;
    [self.animator addBehavior:itemBehaviour];
}

- (void)bounceTimerView {
    // active is reset to NO after force is applied
    self.pushBehavior.pushDirection = CGVectorMake(0, -75);
    self.pushBehavior.active = YES;
}

- (void)presentSettingsNotification {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    label.text = @"Swipe to reveal settings";
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:27 weight:UIFontWeightLight];
    label.alpha = 0;
    [label sizeToFit];
    label.center = self.view.center;
    
    [self.view addSubview:label];
    
    // Fade in, fade out, remove
    [UIView animateWithDuration:0.333 animations:^{
        label.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.333 animations:^{
                label.alpha = 0;
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
                self.view.userInteractionEnabled = YES;
            }];
        });
    }];
}

- (BOOL)enablePaging { return self.timerViewController.isPaused; }

- (BOOL)scrollEnabled {
    // Should be safe even if the private view layout changes
    UIScrollView *scrollView = self.view.subviews.firstObject;
    if ([scrollView isKindOfClass:[UIScrollView class]]) {
        return scrollView.isScrollEnabled;
    }
    
    return YES;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled {
    // Should be safe even if the private view layout changes
    UIScrollView *scrollView = self.view.subviews.firstObject;
    if ([scrollView isKindOfClass:[UIScrollView class]]) {
        scrollView.scrollEnabled = scrollEnabled;
    }
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController == _timerViewController) return _settingsViewController;
    return _timerViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (viewController == _timerViewController) return _settingsViewController;
    return _timerViewController;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers {
    if ([pendingViewControllers containsObject:self.timerViewController]) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        
        // Save settings
        [[NSUserDefaults standardUserDefaults] setDouble:self.settingsViewController.timerPicker.timeInterval forKey:kPref_TimerTime];
        [[NSUserDefaults standardUserDefaults] setDouble:self.settingsViewController.incrementPicker.timeInterval forKey:kPref_TimerIncrement];
        [[NSUserDefaults standardUserDefaults] setInteger:self.settingsViewController.timerType forKey:kPref_TimerStyle];
        
        // Update timer if needed
        if (self.timerViewController.activeTimer == nil) {
            [self.timerViewController reset];
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed {
    if ([previousViewControllers containsObject:self.timerViewController]) {
        [[UIApplication sharedApplication] setStatusBarHidden:!completed withAnimation:UIStatusBarAnimationFade];
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:completed withAnimation:UIStatusBarAnimationFade];
    }
}

@end
