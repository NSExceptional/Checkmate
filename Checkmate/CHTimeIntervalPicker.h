//
//  CHTimeIntervalPicker.h
//  Checkmate
//
//  Created by Tanner on 2/29/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHTimeIntervalPicker : UIControl <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSTimeInterval timeInterval;

@property (nonatomic) UIFont *font;

@property (nonatomic, readonly) UIPickerView *pickerView;
@property (nonatomic, readonly) UILabel *hourLabel;
@property (nonatomic, readonly) UILabel *minuteLabel;
@property (nonatomic, readonly) UILabel *secondLabel;

- (void)setTimeIntervalAnimated:(NSTimeInterval)timeInterval;

@end
