//
//  IMManager.m
//  Weex
//
//  Created by macOS on 2017/12/20.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "IMManager.h"

@interface IMManager () <UIAlertViewDelegate>

@end

@implementation IMManager

+ (IMManager *)sharedInstance{
    static IMManager * shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [[IMManager alloc] init];
    });
    return shareInstance;
}

- (void) loginWithUser:(NSDictionary *)user loginOption:(IMManagerLoginOption)option andBlock:(void (^)(BOOL success))finish{
    static NSTimeInterval lastLogin = 0;
    if ([[TIMManager sharedInstance] getLoginStatus] == TIM_STATUS_LOGINING){
        if (finish){
            finish(NO);
        }
        return;
    }
    if (!user){
        if (finish){
            finish(NO);
        }
        return;
    }
    if (option == IMManagerLoginOptionDefault){
        if ([[TIMManager sharedInstance] getLoginStatus] != TIM_STATUS_LOGOUT){
            if (finish){
                finish(YES);
            }
            return;
        }
    }else if (option == IMManagerLoginOptionTimeout){
        if ([[NSDate date] timeIntervalSince1970] - lastLogin < 180){
            if (finish){
                finish(YES);
            }
            return;
        }
    }
    lastLogin = [[NSDate date] timeIntervalSince1970];
    NSLog(@"unlogin\nloginUser=%@",user);
    IMALoginParam *loginParam = [IMALoginParam new];
    [IMAPlatform configWith:loginParam.config];
    loginParam.identifier = [user objectForKey:@"userId"];
    loginParam.userSig = [user objectForKey:@"userSig"];
    loginParam.appidAt3rd = kSdkAppId;
    
    if (option == IMManagerLoginOptionOffline){
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[TIMManager sharedInstance] initStorage:loginParam succ:^{
                if (finish){
                    finish(YES);
                }
            } fail:^(int code, NSString *msg) {
                [self failedInitTIM:@"数据初始化失败" title:@"错误"];
            }];
        });
    }else{
        [[TIMManager sharedInstance] login:loginParam succ:^{
            NSLog(@"login success");
            [[IMAPlatform sharedInstance] configOnLoginSucc:loginParam];
            
            [SharedAppDelegate registNotification];
            
            //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(90 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //            [self loginWithUser:[UserManager getUser] loginOption:IMManagerLoginOptionTimeout andBlock:nil];
            //        });
            
            if (finish){
                finish(YES);
            }
        } fail:^(int code, NSString *msg) {
            NSLog(@"errormsg=%@",msg);
            if (code == ERR_IMSDK_KICKED_BY_OTHERS){
                [self loginWithUser:[CJUserManager getUser] loginOption:IMManagerLoginOptionForce andBlock:nil];
            }else{
                [self failedInitTIM:@"连接聊天服务器失败" title:DisplayName];
                if (finish){
                    finish(NO);
                }
            }
        }];
    }
}

- (void)failedInitTIM:(NSString *)error title:(NSString *)title{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:error delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([alertView.title isEqualToString:@"错误"]){
        exit(0);
    }
}

+ (NSInteger)getUnReadCount{
    NSArray *conversationList = [[TIMManager sharedInstance] getConversationList];
    NSInteger count = 0;
    for (TIMConversation *conversation in conversationList){
        if ([conversation getReceiver].length > 0){
            count += [conversation getUnReadMessageNum];
        }
    }
    return count;
}
@end
