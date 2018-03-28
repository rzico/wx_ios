//
//  NSURL+Util.m
//  Weex
//
//  Created by 郭书智 on 2017/10/7.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "NSURL+Util.h"

@implementation NSURL (Util)

- (BOOL)isContains:(NSString *)str{
    NSString *url = [self absoluteString];
    NSRange range = [url rangeOfString:str];
    return !(range.length == 0 && range.location > url.length);
}

- (BOOL)isContains:(NSString *)str1 and:(NSString *)str2{
    NSString *url = [self absoluteString];
    NSRange range1 = [url rangeOfString:str1];
    NSRange range2 = [url rangeOfString:str2];
    return (!(range1.length == 0 && range1.location > url.length) && !(range2.length == 0 && range2.location > url.length));
}

- (NSURL *)replaceOfString:(NSString *)target withString:(NSString *)replacement{
    NSString *source = [self absoluteString];
    source = [source stringByReplacingOccurrencesOfString:target withString:replacement];
    return [NSURL URLWithString:source];
}
@end
