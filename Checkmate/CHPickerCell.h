//
//  CHPickerCell.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTimeIntervalPicker.h"


@interface CHPickerCell : UITableViewCell

@property (nonatomic, readonly) CHTimeIntervalPicker *picker;

@end
