//
//  NSDictionary+Json.h
//  Weex
//
//  Created by 郭书智 on 2018/3/16.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Json)

+ (NSDictionary *)objectToDictionary:(id)obj;
+ (NSString *)convertToJsonData:(NSDictionary *)dict;
+ (NSDictionary *)dictionaryWithJsonData:(NSData *)jsonData;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
