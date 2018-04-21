//
//  UIScreen+CJUtil.m
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "UIScreen+CJUtil.h"

@implementation UIScreen (CJUtil)

+ (CGFloat)getWidth{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)getHeight{
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)getStatusBarHeight{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}
@end
