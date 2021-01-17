//
//  AppDelegate.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import "CHAppDelegate.h"
#import "CHPageViewController.h"
#import "CHSettingsViewController.h"
#import "UIColor+DarkModeShim.h"


@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register default preferences
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
        @"timer_time": @420, @"timer_increment": @5
    }];
    
    [self applyTheme];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [CHPageViewController new];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applyTheme {
    [UILabel appearance].textColor                   = CHColor.primaryTextColor;
    [UITableViewCell appearance].textLabel.textColor = CHColor.primaryTextColor;
    [UITableViewCell appearance].backgroundColor     = CHColor.cellBackgroundColor;
    [UITableView appearance].backgroundColor         = CHColor.primaryBackgroundColor;
    [UITableView appearance].separatorColor          = CHColor.hairlineColor;
    // This is bad but I am lazy
    [[NSClassFromString(@"_UITableViewHeaderFooterViewLabel") appearance] setTextColor:CHColor.secondaryTextColor];
}

@end
