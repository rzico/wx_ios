//
//  WXURLRewriteImpl.m
//  Weex
//
//  Created by 郭书智 on 2017/10/8.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJURLRewriteImpl.h"
#import "WXSDKInstance.h"

@implementation CJURLRewriteImpl

- (NSURL *)rewriteURL:(NSString *)url
     withResourceType:(WXResourceType)resourceType
         withInstance:(WXSDKInstance *)instance
{
    url = [url rewriteURL];
    NSURL *URL;
    if ([url hasPrefix:@"/"]){
        URL = [NSURL fileURLWithPath:url];
    }else{
        URL = [NSURL URLWithString:url];
    }
    return URL;
}
@end
