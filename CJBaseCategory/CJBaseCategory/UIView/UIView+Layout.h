//
//  UIView+Layout.h
//  Application
//
//  Created by 郭书智 on 2018/3/26.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Layout)

@property (nonatomic,assign) CGFloat x;
@property (nonatomic,assign) CGFloat y;

- (double)width;
- (void)setWidth:(double)width;

- (double)height;
- (void)setHeight:(double)height;

- (CGFloat)bottomPosition;

- (CGSize)size;
- (void)setSize:(CGSize)size;

- (CGPoint)origin;
- (void)setOrigin:(CGPoint)point;

- (double)xPosition;
- (double)yPosition;
- (double)baselinePosition;

- (void)positionAtX:(double)xValue;
- (void)positionAtY:(double)yValue;
- (void)positionAtX:(double)xValue andY:(double)yValue;

- (void)positionAtX:(double)xValue andY:(double)yValue withWidth:(double)width;
- (void)positionAtX:(double)xValue andY:(double)yValue withHeight:(double)height;

- (void)positionAtX:(double)xValue withHeight:(double)height;

- (void)removeSubviews;

- (void)centerInSuperView;
- (void)aestheticCenterInSuperView;

- (void)bringToFront;
- (void)sendToBack;

//ZF

- (void)centerAtX;

- (void)centerAtXQuarter;

- (void)centerAtX3Quarter;

@end
