//
//  CJLiveMessageModel.h
//  Weex
//
//  Created by 郭书智 on 2018/4/7.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CJLiveMessageGagString @"被禁言了"
#define CJLiveMessageUnGagString @"已解除禁言"
#define CJLiveMessageKickString @"被主播踢出房间"
#define CJLiveMessageUnFollowString @"取消关注主播"
#define CJLiveMessageFollowString @"关注了主播"

typedef NS_ENUM(NSUInteger, CJLiveMessageType){
    CJLiveMessageTypeTip = 0,//提示消息
    CJLiveMessageTypeText,//文本消息
    CJLiveMessageTypeGift,//礼物消息
    CJLiveMessageTypeEnter,//进入房间消息
    CJLiveMessageTypeGag,//禁言消息
    CJLiveMessageTypeKick,//踢人消息
    CJLiveMessageTypeFollow,//关注消息
    CJLiveMessageTypeUnFollow,//取消关注消息
    CJLiveMessageTypeBarrage,//弹幕消息
    CJLiveMessageTypeGame,//游戏消息
};

@interface CJLiveMessageModel : NSObject

@property (nonatomic, strong) NSArray<NSString *> *badgeArray;

@property (nonatomic, copy) NSString *Id;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, copy) NSString *VIP;

@property (nonatomic, copy) NSString *nickName;

@property (nonatomic, copy) NSString *icon;

@property (nonatomic, assign) CJLiveMessageType messageType;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, assign) NSUInteger count;

@end
