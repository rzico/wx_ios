//
//  NSDate+Util.h
//  Weex
//
//  Created by 郭书智 on 2018/3/19.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Util)

+ (NSString *)DateWithFormat:(NSString *)format;
+ (NSTimeInterval)GetTimeIntervalFromUTCString:(NSString *)utc;

@end
