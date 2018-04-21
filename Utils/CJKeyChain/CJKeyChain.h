//
//  CJKeyChain.h
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJUUID : NSObject

+ (NSString *)getUUID;

@end

@interface CJKeyChain : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;

@end
