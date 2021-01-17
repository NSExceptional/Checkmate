//
//  CHSettingsViewController.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTimeIntervalPicker.h"


@interface CHSettingsViewController : UITableViewController

@property (nonatomic          ) CHTimerType timerType;
@property (nonatomic, readonly) CHTimeIntervalPicker *timerPicker;
@property (nonatomic, readonly) CHTimeIntervalPicker *incrementPicker;

@end
