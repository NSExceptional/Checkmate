//
//  UIViewController.m
//  Luna
//
//  Created by Tanner on 1/5/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UIViewController+Util.h"
@import SafariServices;


@implementation UIViewController (Util)

- (UIViewController *)topmostViewController {
    if (self.presentedViewController) {
        return self.presentedViewController.topmostViewController;
    }
    
    return self;
}

- (void)dismissAnimated {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
