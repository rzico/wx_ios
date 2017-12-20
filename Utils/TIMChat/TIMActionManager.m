//
//  TIMActionManager.m
//  Weex
//
//  Created by macOS on 2017/11/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "TIMActionManager.h"

@implementation TIMActionManager

+ (void)PostConversationWithLastMessage:(TIMConversation *)conversation{
    if ([conversation getUnReadMessageNum] > 0){
        TIMMessage *msg = [[conversation getLastMsgs:1] lastObject];
        
        if (msg){
            NSMutableDictionary *message = [NSMutableDictionary new];
            [message setObject:@"receive" forKey:@"type"];
            [message setObject:msg forKey:@"msg"];
            [message setObject:@"success" forKey:@"result"];
            [message setObject:[conversation getReceiver] forKey:@"receiver"];
            
            CJPostNotification(CJNOTIFICATION_IM_ON_NEWMESSAGE, message);
        }
    }
}

+ (void)PostAllConversationWithLastMessage{
    NSArray *conversationList = [[TIMManager sharedInstance] getConversationList];
    for (TIMConversation *conversation in conversationList){
        [self PostConversationWithLastMessage:conversation];
    }
}
@end
