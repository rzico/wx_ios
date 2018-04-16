//
//  CJNotificationCenter.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#ifndef CJNotificationCenter_h
#define CJNotificationCenter_h

#define CJRegisterNotification(Sel,Name)        [[NSNotificationCenter defaultCenter] addObserver:self selector:Sel name:Name object:nil]
#define CJPostNotification(name,info)           [[NSNotificationCenter defaultCenter] postNotificationName:name object:self userInfo:info]
#define CJRemoveNotification(Name)              [[NSNotificationCenter defaultCenter] removeObserver:self name:Name object:nil];

#define CJNOTIFICATION_INITIALIZED              @"CJNOTIFICATION_INITIALIZED"
#define CJNOTIFICATION_TABBAR_RESET             @"CJNOTIFICATION_TABBAR_RESET"
#define CJNOTIFICATION_TABBAR_RELOAD            @"CJNOTIFICATION_TABBAR_RELOAD"
#define CJNOTIFICATION_IM_UNREAD_COUNT          @"CJNOTIFICATION_IM_UNREAD_COUNT"
#define CJNOTIFICATION_IM_ON_NEWMESSAGE         @"CJNOTIFICATION_IM_ON_NEWMESSAGE"
#define CJNOTIFICATION_WX_SEND_Global_EVENT     @"CJNOTIFICATION_WX_SEND_Global_EVENT"


#define CJNOTIFICATION_GROUP_MESSAGE            @"CJNOTIFICATION_GROUP_MESSAGE"
#endif /* CJNotificationCenter_h */
