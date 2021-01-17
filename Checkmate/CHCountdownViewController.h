//
//  CHTimerViewController.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTimerController.h"


@interface CHCountdownViewController : UIViewController

@property (nonatomic) CHTimerController *activeTimer;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL hasStarted;

@property (nonatomic, copy) void (^pauseAction)();
@property (nonatomic, copy) void (^resumeAction)();
@property (nonatomic, copy) void (^resetAction)();

- (void)reset;

@end
