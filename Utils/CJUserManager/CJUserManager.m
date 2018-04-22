//
//  CJUserManager.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJUserManager.h"

static NSDictionary *localUser;

@implementation CJUserManager

+ (NSString *)getUserId{
    NSDictionary *user = [self getUser];
    if (user){
        return [user objectForKey:@"userId"];
    }else{
        return nil;
    }
}

+ (NSUInteger)getUid{
    NSDictionary *user = [self getUser];
    if (user){
        return [[user objectForKey:@"uid"] unsignedIntegerValue];
    }else{
        return 0;
    }
}

+ (void)setUser:(NSDictionary *)user{
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"CJUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    CJPostNotification(CJNOTIFICATION_TABBAR_RELOAD, nil);
}

+ (void)removeUser{
    localUser = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CJUser"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)getUser{
    if (!localUser){
        localUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"CJUser"];
    }
    return localUser;
}

@end
