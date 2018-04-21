//
//  CJCallbackMessage.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJCallbackMessage.h"

@implementation CJCallbackMessage

- (NSDictionary *)getMessage{
    NSMutableDictionary *message = [NSMutableDictionary new];
    [message setValue:self.type ? @"success" : @"error" forKey:@"type"];
    NSString *value = nil;
    if (!self.content){
        value = self.type ? @"成功" : @"失败";
    }
    [message setValue:self.content ? self.content : value forKey:@"content"];
    if ([self.data isKindOfClass:[NSArray class]]){
        NSMutableArray *dic = [NSMutableArray new];
        for (id temp in self.data){
            [dic addObject:[NSDictionary objectToDictionary:temp]];
        }
        [message setValue:dic forKey:@"data"];
    }else if ([self.data isKindOfClass:[NSString class]]){
        [message setValue:self.data forKey:@"data"];
    }else{
        [message setValue:[NSDictionary objectToDictionary:self.data] forKey:@"data"];
    }
    return [message mutableCopy];
}

@end
