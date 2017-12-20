//
//  NSString+RewriteURL.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "NSString+RewriteURL.h"

@implementation NSString (RewriteURL)

- (NSString *)rewriteURL{
    NSString *url = self;
    NSString *lowerCaseUrl = [url lowercaseString];
    if ([lowerCaseUrl hasPrefix:@"file://"]){
        if (![lowerCaseUrl isContains:@"var/mobile"]){
            url = [url stringByReplacingOccurrencesOfString:@"file://" withString:@""];
            url = [[DOCUMENT_PATH stringByAppendingPathComponent:@"resource"] stringByAppendingPathComponent:url];
        }
    }else if ([lowerCaseUrl hasPrefix:@"http://"] || [lowerCaseUrl hasPrefix:@"https://"]){
        
    }else if([lowerCaseUrl isContains:@"original"] || [lowerCaseUrl isContains:@"thumb"]){
        
    }else if ([lowerCaseUrl hasPrefix:@"localcachepath://"]){
        url = [url stringByReplacingOccurrencesOfString:@"localCachePath://" withString:CACHES_PATH];
    }else if([lowerCaseUrl hasPrefix:@"/var/mobile"]){
        
    }else if ([lowerCaseUrl hasPrefix:@"/users"]){
        
    }else{
        url = [NSString stringWithFormat:@"%@%@",WXCONFIG_INTERFACE_PATH,url];
    }
    
    
    return url;
}

@end
