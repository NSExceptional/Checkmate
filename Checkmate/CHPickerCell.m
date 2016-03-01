//
//  CHPickerCell.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHPickerCell.h"


@implementation CHPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self awakeFromNib];
        
        if ([reuseIdentifier isEqualToString:kTimeLimitReuse]) {
            _picker.timeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerTime];
        } else {
            _picker.timeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerIncrement];
        }
    }
    
    return self;
}

- (void)awakeFromNib {
    _picker = [[CHTimeIntervalPicker alloc] initWithFrame:self.bounds];
    _picker.hourLabel.textColor   = [UIColor whiteColor];
    _picker.minuteLabel.textColor = [UIColor whiteColor];
    _picker.secondLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:_picker];
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    _picker.frame = self.bounds;
}

@end
