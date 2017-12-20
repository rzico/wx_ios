//
//  IWXToast.h
//  Weex
//
//  Created by 郭书智 on 2017/9/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWXToastInfo.h"
#import "IWXToastManager.h"
#import <WXUtility.h>

@interface IWXToast : NSObject
- (void)showToast:(id)message withInstance:(WXSDKInstance *)instance;

@property (nonatomic, strong) WXSDKInstance *instance;

@end
