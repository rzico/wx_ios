//
//  IWXToastManager.m
//  Weex
//
//  Created by 郭书智 on 2017/9/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "IWXToastManager.h"

@implementation IWXToastManager

+ (IWXToastManager *)sharedManager{
    static IWXToastManager * shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[IWXToastManager alloc] init];
        shareInstance.toastQueue = [NSMutableArray new];
    });
    return shareInstance;
}

@end
