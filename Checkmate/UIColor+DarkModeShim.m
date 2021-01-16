//
//  UIColor+DarkModeShim.m
//  Checkmate
//
//  Created by Tanner on 1/16/21.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import "UIColor+DarkModeShim.h"

#define DynamicColor(dynamic, default) ({ \
    static UIColor *c = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        if (@available(iOS 13.0, *)) { \
            c = [UIColor dynamic]; \
        } else { \
            c = default; \
        } \
    }); \
    c; \
});

@implementation CHColor
static UIColor * kTrueTableSeparatorColor = nil;

+ (void)initialize
{
    
    
    if (self == [CHColor class]) {
        kTrueTableSeparatorColor = [UITableView new].separatorColor;
    }
}

+ (UIColor *)primaryBackgroundColor {
    return DynamicColor(systemGroupedBackgroundColor, UIColor.blackColor);
}

+ (UIColor *)cellBackgroundColor {
    return DynamicColor(colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithWhite:0.080 alpha:1.000];
        }
        
        return UIColor.whiteColor;
    }, [UIColor colorWithWhite:0.080 alpha:1.000]);
}

+ (UIColor *)primaryTextColor {
    return DynamicColor(labelColor, UIColor.whiteColor);
}

+ (UIColor *)secondaryTextColor {
    return DynamicColor(secondaryLabelColor, [UIColor colorWithWhite:1.000 alpha:0.6]);
}

+ (UIColor *)hairlineColor {
    return DynamicColor(colorWithDynamicProvider:^UIColor *(UITraitCollection *traitCollection) {
        if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
            return [UIColor colorWithWhite:0.150 alpha:1.000];
        }
        
        return kTrueTableSeparatorColor;
    }, [UIColor colorWithWhite:0.150 alpha:1.000]);
}

@end
