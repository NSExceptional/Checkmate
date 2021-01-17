//
//  Checkmate-Constants.h
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import <Foundation/Foundation.h>


#pragma mark - Misc - 

static NSTimeInterval kTimerInterval = 1.f/60.f;

typedef NS_ENUM(NSUInteger, CHTimerType)
{
    CHTimerTypeFischer,
    CHTimerTypeBronstein
};

typedef NS_ENUM(NSUInteger, CHTimerTextStyle)
{
    CHTimerTextStyleDefault = 1,
    CHTimerTextStyleHours,
    CHTimerTextStyleSubTen
};

extern NSString * CHFormatStringFromTextStyle(CHTimerTextStyle);

#pragma mark - Strings -

#pragma mark - NSDateFormatter formats
static NSString * const kFormatHours   = @"H:m:ss";
static NSString * const kFormatDefault = @"m:ss";
static NSString * const kFormatSubTen  = @"0:ss.S";

#pragma mark - Reuse

extern NSString * const kTimeLimitReuse;
extern NSString * const kIncrementReuse;
extern NSString * const kCheckboxReuse;

#pragma mark - Preferences

extern NSString * const kPref_DidBounce;
extern NSString * const kPref_TimerTime;
extern NSString * const kPref_TimerStyle;
extern NSString * const kPref_TimerIncrement;
