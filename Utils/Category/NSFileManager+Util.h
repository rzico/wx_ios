//
//  NSFileManager+Util.h
//  Weex
//
//  Created by macOS on 2017/11/25.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Util)
+ (unsigned long long)countFileSizeWithPath:(NSString *)path;
+ (void)cleanFileWithPath:(NSString *)path;
+ (void)cleanCacheAndCookie;
@end
