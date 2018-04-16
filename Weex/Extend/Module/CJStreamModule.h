//
//  CJStreamModule.h
//  Weex
//
//  Created by macOS on 2017/12/19.
//  Copyright © 2017年 rzico. All rights reserved.
//


#import <WXModuleProtocol.h>

@interface CJStreamModule : NSObject <WXModuleProtocol>

- (void)fetch:(NSDictionary *)options callback:(WXModuleCallback)callback progressCallback:(WXModuleKeepAliveCallback)progressCallback;
- (void)sendHttp:(NSDictionary*)param callback:(WXModuleCallback)callback DEPRECATED_MSG_ATTRIBUTE("Use fetch method instead.");

@end
