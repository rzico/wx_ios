//
//  CJLivePlayUserModel.m
//  Weex
//
//  Created by 郭书智 on 2018/4/20.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePlayUserModel.h"

@implementation CJLivePlayUserModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dic
{
    
    CJLivePlayUserModel *mo = [[CJLivePlayUserModel alloc]init];
    
    [mo setValuesForKeysWithDictionary:dic];
    
    return mo;
    
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    if ([key isEqualToString:@"id"]) {
        self.Id = value;
    }
}

@end
