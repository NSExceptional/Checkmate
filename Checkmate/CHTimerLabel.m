//
//  CHTimerLabel_.m
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimerLabel.h"
#import "UIColor+DarkModeShim.h"


@implementation CHTimerLabel

#pragma mark - Initialization / class methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [[self class] desiredFontForTextStyle:CHTimerTextStyleDefault];
        self.textColor = CHColor.primaryTextColor;
        self.textAlignment = NSTextAlignmentLeft;
    }
    
    return self;
}

+ (UIFont *)desiredFontForTextStyle:(CHTimerTextStyle)style {
    CGFloat pointSize = [[self class] desiredFontSizeForTextStyle:style];
    return [UIFont monospacedDigitSystemFontOfSize:pointSize weight:UIFontWeightThin];
}

+ (CGFloat)desiredFontSizeForTextStyle:(CHTimerTextStyle)style {
    BOOL bigger = [UIScreen mainScreen].scale == 3;
    switch (style) {
        case CHTimerTextStyleDefault: {
            return bigger ? 122 : 110;
        }
        case CHTimerTextStyleHours: {
            return bigger ? 111 : 100;
        }
        case CHTimerTextStyleSubTen: {
            return bigger ? 111 : 100;
        }
    }
}

@end
