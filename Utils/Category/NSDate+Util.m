//
//  NSDate+Util.m
//  Weex
//
//  Created by iMac on 2017/10/17.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

+ (NSString *)DateWithFormat:(NSString *)format{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSString *DateTime = [formatter stringFromDate:date];
    return DateTime;
}

+ (NSTimeInterval)GetTimeIntervalFromUTCString:(NSString *)utc{
    NSDateFormatter *formater = [NSDateFormatter new];
    [formater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    [formater setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [formater dateFromString:utc];
    NSTimeInterval interval = [date timeIntervalSinceNow];
    return interval;
}
@end
