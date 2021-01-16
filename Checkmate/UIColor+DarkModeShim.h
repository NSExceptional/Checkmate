//
//  UIColor+DarkModeShim.h
//  Checkmate
//
//  Created by Tanner on 1/16/21.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHColor : NSObject

@property (readonly, class) UIColor *primaryBackgroundColor;
@property (readonly, class) UIColor *cellBackgroundColor;
@property (readonly, class) UIColor *primaryTextColor;
@property (readonly, class) UIColor *secondaryTextColor;
@property (readonly, class) UIColor *hairlineColor;

@end
