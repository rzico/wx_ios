//
//  FriendshipManager.m
//  Weex
//
//  Created by macOS on 2017/11/17.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "FriendshipManager.h"
#import "CJUserManager.h"

static NSMutableDictionary *userProfile;


@implementation FriendshipManager

+ (void)getUserProfile:(NSString *)user succ:(void(^)(TIMUserProfile *profile))success {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userProfile = [NSMutableDictionary new];
    });
    if (![[TIMManager sharedInstance] getLoginUser]){
        success([userProfile objectForKey:user]);
        return;
    }
    NSString *userId = [CJUserManager getUserId];
    if (![userProfile objectForKey:userId]){
        [[TIMFriendshipManager sharedInstance] getUsersProfile:[NSArray arrayWithObjects:userId, nil] succ:^(NSArray *friends){
            [userProfile setObject:[friends firstObject] forKey:userId];
        }fail:^(int code, NSString *msg) {
            success(nil);
        }];
    }
    if ([userProfile objectForKey:user]){
        success([userProfile objectForKey:user]);
    }else{
        [[TIMFriendshipManager sharedInstance] getUsersProfile:[NSArray arrayWithObjects:user, nil] succ:^(NSArray *friends){
            [userProfile setObject:[friends firstObject] forKey:user];
            success([friends firstObject]);
        }fail:^(int code, NSString *msg) {
            success(nil);
        }];
    }
}

@end
