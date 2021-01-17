//
//  CHTimerLabel_.h
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CHTimerLabel : UILabel

+ (UIFont *)desiredFontForTextStyle:(CHTimerTextStyle)style;

@property (nonatomic) NSDateFormatter *formatter;

@end
