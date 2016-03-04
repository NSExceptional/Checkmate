//
//  CHTimerViewController.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTimerController.h"


@interface CHCountdownViewController : UIViewController

@property (nonatomic) CHTimerController *activeTimer;
- (void)reset;

@end
