//
//  HttpHead+Utils.m
//  Weex
//
//  Created by 郭书智 on 2017/9/26.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "HttpHead+Utils.h"
#import "CJKeyChain.h"
#import "MD5+Util.h"
#import "CJUpdateManager.h"
//#import "DictionaryUtil.h"

@implementation HttpHead_Utils

+ (NSDictionary*) getHttpHead
{
    static NSString *uid;
    NSString *Md5key;
    static NSString *appKey = nil;
    
    static NSString *userAgent = nil;
    
    if (!userAgent){
        userAgent = [SharedAppDelegate.userAgent stringByAppendingString:@"weex"];
    }
    
    if (!uid){
        uid = [CJUUID getUUID];
    }
    if (!appKey){
        NSDictionary *resourceInfo = [[CJUpdateManager sharedInstance] resourceInfo];
        if (resourceInfo){
            appKey = [resourceInfo objectForKey:@"key"];
        }
        if (!appKey){
            [[CJUpdateManager sharedInstance] checkUpdate];
        }
    }
    unsigned long timeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
    Md5key = [MD5_Util md5:[NSString stringWithFormat:@"%@%@%lu%@",uid,ApplicationID,timeInterval,appKey]];
    
    return   @{@"x-uid":uid,@"x-app":ApplicationID,@"x-tsp":[NSString stringWithFormat:@"%lu",timeInterval],@"x-tkn":Md5key,@"User-Agent":userAgent};
}

@end
