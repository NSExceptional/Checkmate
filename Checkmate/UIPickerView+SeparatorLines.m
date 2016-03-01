//
//  UIPickerView+SeparatorLines.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "UIPickerView+SeparatorLines.h"

@implementation UIPickerView (SeparatorLines)

- (UIView *)bottomLineView_ {
    return [self valueForKey:@"_bottomLineView"];
}

- (UIView *)topLineView_ {
    return [self valueForKey:@"_topLineView"];
}

@end
