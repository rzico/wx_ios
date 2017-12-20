//
//  AppDelegate.h
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WXApi.h>

typedef void(^WXAuthComplete)(SendAuthResp *resp);
typedef void(^WXPayComplete)(PayResp *resp);
typedef void(^WXShareComplete)(SendMessageToWXResp *resp);
typedef void(^CJLogOutComplete)(BOOL success);

@interface AppDelegate : UIResponder <UIApplicationDelegate, WXApiDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) WXAuthComplete wxAuthComplete;
@property (strong, nonatomic) WXPayComplete wxPayComplete;
@property (strong, nonatomic) WXShareComplete wxShareComplete;
@property (strong, nonatomic) CJLogOutComplete wxLogOutComplete;

@property (strong, nonatomic) NSDictionary *userInfo;

- (void)registNotification;

@end

