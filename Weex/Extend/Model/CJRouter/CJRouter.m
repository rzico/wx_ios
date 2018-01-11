//
//  CJRouter.m
//  Weex
//
//  Created by macOS on 2018/1/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJRouter.h"

@implementation CJRouter

+ (instancetype)shareInstance{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [self alloc];
    });
    return instance;
}

@end
