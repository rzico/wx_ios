//
//  CJLivePlayModel.m
//  Weex
//
//  Created by 郭书智 on 2018/4/13.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePlayModel.h"

@implementation CJLivePlayModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dic
{
    
    CJLivePlayModel *mo = [[CJLivePlayModel alloc]init];
    
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
