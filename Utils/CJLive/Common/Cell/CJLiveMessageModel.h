//
//  CJLiveMessageModel.h
//  Weex
//
//  Created by 郭书智 on 2018/4/7.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, CJLiveMessageType){
    CJLiveMessageTypeTip = 0,
    CJLiveMessageTypeText,
    CJLiveMessageTypeGift,
    CJLiveMessageTypeEnter
};

@interface CJLiveMessageModel : NSObject

@property (nonatomic, strong) NSArray<NSString *> *badgeArray;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, assign) CJLiveMessageType messageType;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) NSUInteger count;

@end
