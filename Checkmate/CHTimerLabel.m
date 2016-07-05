//
//  CHTimerLabel_.m
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import "CHTimerLabel.h"


@implementation CHTimerLabel

#pragma mark - Initialization / class methods

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [[self class] desiredFontForTextStyle:CHTimerTextStyleDefault];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentLeft;
    }
    
    return self;
}

+ (UIFont *)desiredFontForTextStyle:(CHTimerTextStyle)style {
    return [UIFont monospacedDigitSystemFontOfSize:[[self class] desiredFontSizeForTextStyle:style] weight:UIFontWeightUltraLight];
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
