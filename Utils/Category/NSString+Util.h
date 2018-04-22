//
//  NSString+Util.h
//  Weex
//
//  Created by 郭书智 on 2017/10/10.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

- (BOOL)isContains:(NSString *)str;
- (BOOL)isContains:(NSString *)str1 and:(NSString *)str2;
+ (NSString *)getUUID;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
@end
