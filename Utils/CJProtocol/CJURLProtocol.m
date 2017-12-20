//
//  CJURLProtocol.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJURLProtocol.h"

@implementation CJURLProtocol

+ (void)load{
    [NSURLProtocol registerClass:self];
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
    if ([request isKindOfClass:[NSMutableURLRequest class]]){
        NSDictionary *headDic = [HttpHead_Utils getHttpHead];
        if (headDic){
            for (NSString *key in headDic.allKeys){
                NSString *value = headDic[key];
                [(id)request setValue:value forHTTPHeaderField:key];
            }
            return NO;
        }else{
            return YES;
        }
    }
    return NO;
}

@end
