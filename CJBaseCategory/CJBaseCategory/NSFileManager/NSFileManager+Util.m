//
//  NSFileManager+Util.m
//  Weex
//
//  Created by 郭书智 on 2018/3/19.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import "NSFileManager+Util.h"

@implementation NSFileManager (Util)

+ (unsigned long long)countFileSizeWithPath:(NSString *)path{
    unsigned long long size = 0;
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [mgr fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists){
        return size;
    }
    if (isDirectory){
        NSDirectoryEnumerator *enumerator = [mgr enumeratorAtPath:path];
        for (NSString *subPath in enumerator){
            size += [NSFileManager countFileSizeWithPath:[path stringByAppendingPathComponent:subPath]];
        }
    }else{
        size += [mgr attributesOfItemAtPath:path error:nil].fileSize;
    }
    return size;
}

+ (void)cleanFileWithPath:(NSString *)path{
    NSFileManager *mgr = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL exists = [mgr fileExistsAtPath:path isDirectory:&isDirectory];
    if (!exists){
        return;
    }
    if (isDirectory){
        NSDirectoryEnumerator *enumerator = [mgr enumeratorAtPath:path];
        for (NSString *subPath in enumerator){
            [NSFileManager cleanFileWithPath:[path stringByAppendingPathComponent:subPath]];
        }
    }else{
        [mgr removeItemAtPath:path error:nil];
    }
}

@end
