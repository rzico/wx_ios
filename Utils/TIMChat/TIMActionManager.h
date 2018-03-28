//
//  TIMActionManager.h
//  Weex
//
//  Created by macOS on 2017/11/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIMActionManager : NSObject

+ (void)PostConversationWithLastMessage:(TIMConversation *)conversation;
+ (void)PostAllConversationWithLastMessage;
@end
