//
//  CJUserManager.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

@interface CJUserManager : NSObject

+ (NSString *)getUserId;
+ (NSUInteger)getUid;
+ (void)setUser:(NSDictionary *)user;
+ (void)removeUser;
+ (NSDictionary *)getUser;

@end
