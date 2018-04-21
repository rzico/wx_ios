//
//  CJPublicKeyManager.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDRSAWrapper.h"
#import "CJPublicKeyData.h"

typedef void(^encryptCallBack)(NSString *result);

@interface CJPublicKeyManager : NSObject

+ (void)encrypt:(NSString *)data withCallBack:(encryptCallBack)callBack;

@end
