//
//  CHTimerViewController.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTimerView.h"


@interface CHTimerViewController : UIViewController

@property (nonatomic) CHTimerView *activeTimer;
- (void)reset;

@end
