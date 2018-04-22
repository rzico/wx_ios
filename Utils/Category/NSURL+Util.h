//
//  NSURL+Util.h
//  Weex
//
//  Created by 郭书智 on 2017/10/7.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Util)

- (BOOL)isContains:(NSString *)str;
- (BOOL)isContains:(NSString *)str1 and:(NSString *)str2;
- (NSURL *)replaceOfString:(NSString *)target withString:(NSString *)replacement;

@end
