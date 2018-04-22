//
//  NSString+Util.h
//  Weex
//
//  Created by 郭书智 on 2018/3/19.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

- (BOOL)isContains:(NSString *)str1 and:(NSString *)str2;
+ (NSString *)getRandomUUID;
- (NSString *)base64EncodedString;
- (NSString *)base64DecodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLDecodedString;
- (NSString *)md5;
- (NSString *)replaceUnicode;
- (NSString *)utf8ToUnicode;
@end
