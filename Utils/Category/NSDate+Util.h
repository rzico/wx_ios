//
//  NSDate+Util.h
//  Weex
//
//  Created by iMac on 2017/10/17.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Util)

+ (NSString *)DateWithFormat:(NSString *)format;
+ (NSTimeInterval)GetTimeIntervalFromUTCString:(NSString *)utc;
@end
