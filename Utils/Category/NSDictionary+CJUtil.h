//
//  DictionaryUtil.h
//  Weex
//
//  Created by 郭书智 on 2017/9/20.
//  Copyright © 2017年 rsico. All rights reserved.
//

@interface NSDictionary (CJUtil)

+ (NSDictionary *)objectToDictionary:(id)obj;
+ (NSString *)convertToJsonData:(NSDictionary *)dict;
+ (NSDictionary *)dictionaryWithJsonData:(NSData *)jsonData;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end
