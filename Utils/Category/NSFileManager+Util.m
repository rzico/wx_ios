//
//  NSFileManager+Util.m
//  Weex
//
//  Created by macOS on 2017/11/25.
//  Copyright © 2017年 rsico. All rights reserved.
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

+ (void)cleanCacheAndCookie{
    //清理cookie
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
    [cache setDiskCapacity:20*1024*1024];
    [cache setMemoryCapacity:20*1024*1024];
}
@end
