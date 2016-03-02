//
//  UIPickerView+SeparatorLines.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>


/// Used to change the color of the separator lines in a UIPickerView.
@interface UIPickerView (SeparatorLines)

@property (nonatomic, readonly) UIView *bottomLineView_;
@property (nonatomic, readonly) UIView *topLineView_;

@end
