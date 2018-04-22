//
//  UIScreen+Size.m
//  Application
//
//  Created by 郭书智 on 2018/3/26.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import "UIScreen+Size.h"

@implementation UIScreen (Size)

+ (CGFloat)getWidth{
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)getHeight{
    return [UIScreen mainScreen].bounds.size.height;
}

+ (CGFloat)getStatusBarHeight{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+ (CGRect)getSize{
    return [UIScreen mainScreen].bounds;
}

+ (CGFloat)getScale{
    return [[UIScreen mainScreen] scale];
}
@end
