//
//  CJLivePlayUserModel.h
//  Weex
//
//  Created by 郭书智 on 2018/4/20.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "JSONModel.h"

@interface CJLivePlayUserModel : JSONModel

@property (nonatomic, copy) NSString *Id;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *logo;

@property (nonatomic, assign) int favorite;

@property (nonatomic, assign) int fans;

@property (nonatomic, copy) NSString *autograph;

@property (nonatomic, copy) NSString *VIP;

@property (nonatomic, copy) NSString *gender;

@property (nonatomic, copy) NSString *occupation;

@property (nonatomic, copy) NSDate *birth;

@property (nonatomic, assign) double balance;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;

@end
