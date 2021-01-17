//
//  Checkmate-Constants.m
//  Checkmate
//
//  Created by Tanner on 2/23/16.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

#import "Checkmate-Constants.h"


#pragma mark - Misc - 

extern NSString * CHFormatStringFromTextStyle(CHTimerTextStyle style) {
    switch (style) {
        case CHTimerTextStyleDefault:
            return kFormatDefault;
        case CHTimerTextStyleHours:
            return kFormatHours;
        case CHTimerTextStyleSubTen:
            return kFormatSubTen;
    }
}
#pragma mark - Strings - 

#pragma mark - Reuse

NSString * const kTimeLimitReuse = @"_CHTimeLimitReuse";
NSString * const kIncrementReuse = @"_CHIncrementReuse";
NSString * const kCheckboxReuse  = @"_CHCheckboxReuse";

#pragma mark - Preferences

NSString * const kPref_DidBounce      = @"did_show_bounce";
NSString * const kPref_TimerTime      = @"timer_time";
NSString * const kPref_TimerStyle     = @"timer_style";
NSString * const kPref_TimerIncrement = @"timer_increment";
