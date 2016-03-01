//
//  AppDelegate.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHAppDelegate.h"
#import "CHPageViewController.h"

#import "CHTimerViewController.h"
#import "CHSettingsViewController.h"


@implementation CHAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Register default preferences
    NSString *defaults = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:defaults]];
    
    [self applyTheme];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    self.window.rootViewController = [CHPageViewController new];
    self.window.tintColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applyTheme {
    [[NSClassFromString(@"_UITableViewHeaderFooterViewLabel") appearance] setTextColor:[UIColor colorWithWhite:1.000 alpha:0.6]];
    [UILabel appearance].textColor                   = [UIColor whiteColor];
    [UITableViewCell appearance].textLabel.textColor = [UIColor whiteColor];
    [UITableViewCell appearance].backgroundColor     = [UIColor colorWithWhite:0.080 alpha:1.000];
    [UITableView appearance].backgroundColor         = [UIColor blackColor];
    [UITableView appearance].separatorColor          = [UIColor colorWithWhite:0.150 alpha:1.000];
}

@end
