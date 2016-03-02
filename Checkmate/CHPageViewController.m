//
//  CHPageViewController.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHPageViewController.h"
#import "CHTimerViewController.h"
#import "CHSettingsViewController.h"


@interface CHPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>
@property (nonatomic, readonly) CHTimerViewController *timerViewController;
@property (nonatomic, readonly) CHSettingsViewController *settingsViewController;
@end


@implementation CHPageViewController

- (id)init {
    return [self initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationVertical options:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate           = self;
    self.dataSource         = self;
    _timerViewController    = [CHTimerViewController new];
    _settingsViewController = [CHSettingsViewController new];
    
    [self setViewControllers:@[_timerViewController] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
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
