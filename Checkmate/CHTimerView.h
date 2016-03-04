//
//  CHTimerView.h
//  Checkmate
//
//  Created by Tanner on 2/27/16.
//  Copyright © 2016 Tanner Bennett. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTimerLabel.h"


@protocol CHTimerStateDelegate <NSObject>

@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL hasStarted;
@property (nonatomic, readonly) NSTimeInterval timeLeft;
@property (nonatomic, readonly) CGFloat activeIndicatorLineWidth;

@end


@interface CHTimerView : UIView

@property (nonatomic, readonly) CHTimerLabel *label;
@property (nonatomic, readonly) UIView *activeIndicatorLine;
@property (nonatomic) id<CHTimerStateDelegate> delegate;

@end
