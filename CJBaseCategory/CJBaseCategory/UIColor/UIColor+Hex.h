//
//  UIColor+Hex.h
//  Application
//
//  Created by 郭书智 on 2018/3/26.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(int)hexValue;
+ (UIColor *)colorWithHexString:(NSString *)color;

@end
