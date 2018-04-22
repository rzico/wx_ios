//
//  NSFileManager+Util.h
//  Weex
//
//  Created by 郭书智 on 2018/3/19.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (Util)

+ (unsigned long long)countFileSizeWithPath:(NSString *)path;
+ (void)cleanFileWithPath:(NSString *)path;

@end
