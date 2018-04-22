//
//  UIScreen+Size.h
//  Application
//
//  Created by 郭书智 on 2018/3/26.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScreen (Size)

+ (CGFloat)getWidth;
+ (CGFloat)getHeight;
+ (CGFloat)getStatusBarHeight;
+ (CGRect)getSize;
+ (CGFloat)getScale;

@end
