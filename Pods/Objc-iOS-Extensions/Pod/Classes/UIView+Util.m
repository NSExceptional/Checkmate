//
//  UIView.m
//  Luna
//
//  Created by Tanner on 1/6/15.
//  Copyright (c) 2015 Tanner Bennett. All rights reserved.
//

#import "UIView+Util.h"


CGRect CGRectRound(CGRect r) {
    r.origin.x = CGFloatRound(r.origin.x);
    r.origin.y = CGFloatRound(r.origin.y);
    r.size.width = CGFloatRound(r.size.width);
    r.size.height = CGFloatRound(r.size.height);
    return r;
}

CGPoint CGPointRound(CGPoint p) {
    p.x = CGFloatRound(p.x);
    p.y = CGFloatRound(p.y);
    return p;
}

@implementation UIView (Util)

- (UIView *)subviewWithClass:(Class)classObject {
    NSParameterAssert(classObject);
    if (!self.subviews.count) return nil;
    
    for (UIView *v in self.subviews)
        if ([v isKindOfClass:classObject])
            return v;
    
    return nil;
}

- (UIView *)subviewWithClass:(Class)classObject passingTest:(BOOL (^)(UIView *))test {
    NSParameterAssert(classObject); NSParameterAssert(test);
    if (!self.subviews.count) return nil;
    
    for (UIView *v in self.subviews)
        if ([v isKindOfClass:classObject] && test(v))
            return v;
    
    return nil;
}

- (void)setFrameOrigin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame   = frame;
}

- (void)setFrameSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size   = size;
    self.frame   = frame;
}

- (void)setFrameWidth:(CGFloat)width {
    CGRect frame     = self.frame;
    frame.size.width = width;
    self.frame       = frame;
}

- (void)setFrameHeight:(CGFloat)height {
    CGRect frame      = self.frame;
    frame.size.height = height;
    self.frame        = frame;
}

- (void)setFrameX:(CGFloat)xpos {
    CGRect frame   = self.frame;
    frame.origin.x = xpos;
    self.frame     = frame;
}

- (void)setFrameY:(CGFloat)ypos {
    CGRect frame   = self.frame;
    frame.origin.y = ypos;
    self.frame     = frame;
}

- (void)setCenterX:(CGFloat)xpos{
    CGPoint p = self.center;
    p.x = xpos;
    self.center = p;
}

- (void)setCenterY:(CGFloat)ypos {
    CGPoint p = self.center;
    p.y = ypos;
    self.center = p;
}

- (void)centerWithinView:(UIView *)view {
    CGRect s  = view.frame;
    CGPoint p = self.center;
    p.x = s.size.width/2.f;
    p.y = s.size.height/2.f;
    self.center = p;
}

- (void)centerYInView:(UIView *)view alignToLeftWithPadding:(CGFloat)padding {
    self.center = CGPointRound(view.center);
    [self setFrameX:padding];
}

- (void)centerYInView:(UIView *)view alignToRightWithPadding:(CGFloat)padding {
    self.center  = CGPointRound(view.center);
    CGFloat xpos = CGRectGetWidth(view.frame) - padding;
    xpos        -= CGRectGetWidth(self.frame);
    [self setFrameX:xpos];
}

- (void)centerXInView:(UIView *)view alignToTopWithPadding:(CGFloat)padding {
    self.center = CGPointRound(view.center);
    [self setFrameY:padding];
}

- (void)centerXInView:(UIView *)view alignToBottomWithPadding:(CGFloat)padding {
    self.center  = CGPointRound(view.center);
    CGFloat ypos = CGRectGetHeight(view.frame) - padding;
    ypos        -= CGRectGetHeight(self.frame);
    [self setFrameY:ypos];
}

- (NSArray *)allConstraintsInHierarchy {
    return [self allConstraintsInHierarchyExcludingViews:nil];
}

- (NSArray *)allConstraintsInHierarchyExcludingViews:(NSArray *)views {
    NSMutableSet *constraints = self.constraints.mutableCopy;
    NSMutableArray *subviews;
    if (views.count) {
        subviews = self.subviews.mutableCopy;
        [subviews removeObjectsInArray:views];
    } else {
        subviews = (id)self.subviews;
    }
    
    for (UIView *subview in subviews)
        [constraints addObjectsFromArray:subview.constraints];
    
    // Filter dangling constraints containing excluded views
    NSMutableSet *filteredConstraints = constraints.mutableCopy;
    for (NSLayoutConstraint *constraint in constraints)
        if ([views containsObject:constraint.firstItem] || [views containsObject:constraint.secondItem])
            [filteredConstraints removeObject:constraint];
    
    return filteredConstraints.allObjects;
}

+ (CGFloat)sumOfFramePart:(CGFramePart)part ofViews:(NSArray *)views {
    CGFloat sum = 0;
    
    switch (part) {
        case CGFramePartX:
            for (UIView *view in views)
                sum += view.frame.origin.x;
            break;
            
        case CGFramePartY:
            for (UIView *view in views)
                sum += view.frame.origin.y;
            break;
            
        case CGFramePartWidth:
            for (UIView *view in views)
                sum += CGRectGetWidth(view.frame);
            break;
            
        case CGFramePartHeight:
            for (UIView *view in views)
                sum += CGRectGetHeight(view.frame);
            break;
    }
    
    return sum;
}

@end
