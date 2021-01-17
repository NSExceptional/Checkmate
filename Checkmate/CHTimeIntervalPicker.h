//
//  CHTimeIntervalPicker.h
//  Checkmate
//
//  Created by Tanner on 2/29/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

// Copyright (c) 2015 Ludvig Eriksson <ludvigeriksson@icloud.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

#import <UIKit/UIKit.h>


/// Translated to Objective-C from https://github.com/ludvigeriksson/LETimeIntervalPicker  License above.
@interface CHTimeIntervalPicker : UIControl <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSTimeInterval timeInterval;

@property (nonatomic) UIFont *font;

@property (nonatomic, readonly) UIPickerView *pickerView;
@property (nonatomic, readonly) UILabel *hourLabel;
@property (nonatomic, readonly) UILabel *minuteLabel;
@property (nonatomic, readonly) UILabel *secondLabel;

- (void)setTimeIntervalAnimated:(NSTimeInterval)timeInterval;

@end
