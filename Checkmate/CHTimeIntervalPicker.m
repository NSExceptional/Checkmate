//
//  CHTimeIntervalPicker.m
//  Checkmate
//
//  Created by Tanner on 2/29/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimeIntervalPicker.h"
#import "UIColor+DarkModeShim.h"


#define CHSecondsToSeconds(x) (((NSInteger)x % 3600) % 60)
#define CHSecondsToMinutes(x) (((NSInteger)x % 3600) / 60)
#define CHSecondsToHours(x) (x / 3600)

typedef NS_ENUM(NSUInteger, Component)
{
    ComponentHour,
    ComponentMinute,
    ComponentSecond
};

static NSString * const kHoursString   = @"hours";
static NSString * const kHourString    = @"hour";
static NSString * const kMinutesString = @"minutes";
static NSString * const kMinuteString  = @"minute";
static NSString * const kSecondsString = @"seconds";
static NSString * const kSecondString  = @"second";

static CGFloat const standardComponentSpacing = 5;
static CGFloat const extraComponentSpacing = 10;
static CGFloat const labelSpacing = 5;


@interface CHTimeIntervalPicker ()
@property (nonatomic) CGFloat totalPickerWidth;
@property (nonatomic) CGFloat numberWidth;
@end


@implementation CHTimeIntervalPicker

#pragma mark - Initializations

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

#pragma mark - Misc

- (NSTimeInterval)timeInterval {
    CGFloat hours = [_pickerView selectedRowInComponent:0] * 60 * 60;
    CGFloat minutes = [_pickerView selectedRowInComponent:1] * 60;
    CGFloat seconds = [_pickerView selectedRowInComponent:2];
    
    return hours + minutes + seconds;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    [self setPickerToTimeInterval:timeInterval animated:NO];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    [self updateLabels];
    [self calculateNumberWidth];
    [self calculateTotalPickerWidth];
    [self.pickerView reloadAllComponents];
}

- (void)setTimeIntervalAnimated:(NSTimeInterval)timeInterval {
    [self setPickerToTimeInterval:timeInterval animated:YES];
}

#pragma mark - Setup

- (void)setup {
    _numberWidth = 20;
    
    _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _hourLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _minuteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    _secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    
    _font = [UIFont systemFontOfSize:17];
    
    [self setupLabels];
    [self calculateNumberWidth];
    [self calculateTotalPickerWidth];
    [self setupPickerView];
}

- (void)setupLabels {
    _hourLabel.text = kHoursString;
    _minuteLabel.text = kMinutesString;
    _secondLabel.text = kSecondsString;
    
    [_hourLabel sizeToFit];
    [_minuteLabel sizeToFit];
    [_secondLabel sizeToFit];
    
    [self addSubview:_hourLabel];
    [self addSubview:_minuteLabel];
    [self addSubview:_secondLabel];
}

- (void)updateLabels {
    for (UILabel *l in @[_hourLabel, _minuteLabel, _secondLabel]) {
        l.font = self.font;
        [l sizeToFit];
    }
}

- (void)calculateNumberWidth {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    label.font = self.font;
    
    for (int i = 0; i < 60; i++) {
        label.text = @(i).stringValue;
        [label sizeToFit];
        
        if (CGRectGetWidth(label.frame) > self.numberWidth) {
            self.numberWidth = CGRectGetWidth(label.frame);
        }
    }
}

- (void)calculateTotalPickerWidth {
    _totalPickerWidth = 0;
    _totalPickerWidth += CGRectGetWidth(self.hourLabel.bounds);
    _totalPickerWidth += CGRectGetWidth(self.minuteLabel.bounds);
    _totalPickerWidth += CGRectGetWidth(self.secondLabel.bounds);
    _totalPickerWidth += standardComponentSpacing * 2;
    _totalPickerWidth += extraComponentSpacing * 3;
    _totalPickerWidth += labelSpacing * 3;
    _totalPickerWidth += self.numberWidth * 3;
}

- (void)setupPickerView {
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.pickerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.pickerView];
    
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:self.pickerView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:0];
    
    [self addConstraints:@[top, bottom, leading, trailing]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.hourLabel setCenterY:CGRectGetMidY(self.pickerView.frame)];
    [self.minuteLabel setCenterY:CGRectGetMidY(self.pickerView.frame)];
    [self.secondLabel setCenterY:CGRectGetMidY(self.pickerView.frame)];
    
    CGFloat pickerMinX = CGRectGetMidX(self.bounds) - self.totalPickerWidth / 2;
    CGFloat space = standardComponentSpacing + extraComponentSpacing + self.numberWidth + labelSpacing;
    [self.hourLabel setFrameX:pickerMinX + self.numberWidth + labelSpacing];
    [self.minuteLabel setFrameX:CGRectGetMaxX(self.hourLabel.frame) + space];
    [self.secondLabel setFrameX:CGRectGetMaxX(self.minuteLabel.frame) + space];
}

#pragma mark - UIPickerView stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    Component comp = component;
    switch (comp) {
        case ComponentHour: {
            return 24;
            break;
        }
        case ComponentMinute: {
            return 60;
            break;
        }
        case ComponentSecond: {
            return 60;
            break;
        }
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    Component comp = component;
    CGFloat labelWidth;
    switch (comp) {
        case ComponentHour: {
            labelWidth = self.hourLabel.bounds.size.width;
            break;
        }
        case ComponentMinute: {
            labelWidth = self.minuteLabel.bounds.size.width;
            break;
        }
        case ComponentSecond: {
            labelWidth = self.secondLabel.bounds.size.width;
            break;
        }
    }
    
    return self.numberWidth + labelWidth + labelSpacing + extraComponentSpacing;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *newView;
    
    if (!view) {
        CGSize size = [self.pickerView rowSizeForComponent:component];
        newView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        label.font = self.font;
        label.textColor = CHColor.primaryTextColor;
        label.textAlignment = NSTextAlignmentRight;
        label.adjustsFontSizeToFitWidth = NO;
        label.frame = CGRectMake(0, 0, self.numberWidth, size.height);
        
        [newView addSubview:label];
    } else {
        newView = view;
    }
    
    UILabel *label = newView.subviews.firstObject;
    label.text = @(row).stringValue;
    
    return newView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Component comp = component;
    
    if (row == 1) {
        switch (comp) {
            case ComponentHour: {
                self.hourLabel.text = kHourString;
                break;
            }
            case ComponentMinute: {
                self.minuteLabel.text = kMinuteString;
                break;
            }
            case ComponentSecond: {
                self.secondLabel.text = kSecondString;
                break;
            }
        }
    } else {
        switch (comp) {
            case ComponentHour: {
                self.hourLabel.text = kHoursString;
                break;
            }
            case ComponentMinute: {
                self.minuteLabel.text = kMinutesString;
                break;
            }
            case ComponentSecond: {
                self.secondLabel.text = kSecondsString;
                break;
            }
        }
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Helpers

- (void)setPickerToTimeInterval:(NSTimeInterval)interval animated:(BOOL)animated {
    NSInteger hours = CHSecondsToHours(interval);
    NSInteger minutes = CHSecondsToMinutes(interval);
    NSInteger seconds = CHSecondsToSeconds(interval);
    
    [self.pickerView selectRow:hours inComponent:0 animated:animated];
    [self.pickerView selectRow:minutes inComponent:1 animated:animated];
    [self.pickerView selectRow:seconds inComponent:2 animated:animated];
    
    [self pickerView:self.pickerView didSelectRow:hours inComponent:0];
    [self pickerView:self.pickerView didSelectRow:minutes inComponent:1];
    [self pickerView:self.pickerView didSelectRow:seconds inComponent:2];
}

@end
