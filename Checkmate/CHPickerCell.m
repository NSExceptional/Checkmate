//
//  CHPickerCell.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHPickerCell.h"
#import "UIColor+DarkModeShim.h"
#import "UIPickerView+SeparatorLines.h"

@implementation CHPickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self awakeFromNib];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialize picker and set label colors
    _picker = [[CHTimeIntervalPicker alloc] initWithFrame:self.bounds];
    _picker.hourLabel.textColor   = CHColor.primaryTextColor;
    _picker.minuteLabel.textColor = CHColor.primaryTextColor;
    _picker.secondLabel.textColor = CHColor.primaryTextColor;
    [self.contentView addSubview:_picker];
    
    // Set picker values
    if ([self.reuseIdentifier isEqualToString:kTimeLimitReuse]) {
        _picker.timeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerTime];
    } else {
        _picker.timeInterval = [[NSUserDefaults standardUserDefaults] doubleForKey:kPref_TimerIncrement];
    }
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    if (!@available(iOS 13.0, *)) {
        _picker.pickerView.magnifierLineColor = CHColor.hairlineColor;
    }
}

- (void)setFrame:(CGRect)frame {
    super.frame = frame;
    [_picker setFrameSize:frame.size];
}

@end
