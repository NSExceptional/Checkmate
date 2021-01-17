//
//  UIPickerView+SeparatorLines.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import "UIPickerView+SeparatorLines.h"

@implementation UIPickerView (SeparatorLines)

/// We never use the getter
- (UIColor *)ch_lineColor {
    return nil;
}

- (void)setCh_lineColor:(UIColor *)color {
//    NSString *sel = [NSString stringWithFormat:@"%@%@", @"_setMagnifier", @"LineColor:"];
//    [
    
    [self setValue:color forKey:@"magnifierLineColor"];
}

@end
