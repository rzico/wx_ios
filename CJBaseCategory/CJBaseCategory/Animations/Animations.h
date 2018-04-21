//
//  Animations.h
//  BaoUU
//
//  Created by 吴小虑 on 2017/12/26.
//  Copyright © 2017年 Mr.Dai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Animations : NSObject

#pragma mark === 永久闪烁的动画 ======
+(CABasicAnimation *)opacityForever_Animation:(float)time;

#pragma mark =====横向、纵向移动===========
+(CABasicAnimation *)moveX:(float)time X:(NSNumber *)x;

+(CABasicAnimation *)moveY:(float)time Y:(NSNumber *)y;

#pragma mark =====缩放-=============
+(CABasicAnimation *)scale:(NSNumber *)Multiple orgin:(NSNumber *)orginMultiple durTimes:(float)time Rep:(float)repertTimes;

#pragma mark =====组合动画-=============
+(CAAnimationGroup *)groupAnimation:(NSArray *)animationAry durTimes:(float)time Rep:(float)repeatTimes;

#pragma mark =====路径动画-=============
+(CAKeyframeAnimation *)keyframeAnimation:(CGMutablePathRef)path durTimes:(float)time Rep:(float)repeatTimes;

#pragma mark ====旋转动画======
+(CABasicAnimation *)rotation:(float)dur degree:(float)degree direction:(int)direction repeatCount:(int)repeatCount;

#pragma mark =====透明度===========
+(CABasicAnimation *)opacity:(NSNumber *)opacity fromValue:(NSNumber *)fromValue time:(float)time;

@end
