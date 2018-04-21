//
//  FriendshipManager.h
//  Weex
//
//  Created by macOS on 2017/11/17.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FriendshipManager : NSObject

+ (void)getUserProfile:(NSString *)user succ:(void(^)(TIMUserProfile *profile))success;

@end
