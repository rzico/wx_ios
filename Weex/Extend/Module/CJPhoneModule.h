//
//  WXPhoneModule.h
//  Weex
//
//  Created by macOS on 2017/11/30.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJBaseModule.h"

@interface CJPhoneModule : CJBaseModule

- (void)tel:(NSString *)number callback:(WXModuleCallback)callback;
- (void)sms:(NSString *)phone content:(NSString *)content callback:(WXModuleCallback)callback;
@end
