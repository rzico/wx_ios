//
//  AppDelegate+Navigator.m
//  Weex
//
//  Created by macOS on 2017/12/20.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "AppDelegate+Navigator.h"
#import "CJLoginViewController.h"
#import "FriendshipManager.h"
#import "IMManager.h"

@implementation AppDelegate (Navigator)


- (void)presentLoginViewController{
    static BOOL isLoading = false;
    if (isLoading){
        return;
    }
    isLoading = true;
    UIViewController *rootViewController = self.window.rootViewController;
    void (^login)(void) = ^{
        WXPerformBlockOnMainThread(^{
            NSString *loginJSPath = [DOCUMENT_PATH stringByAppendingPathComponent:@"resource/view/index.js"];
            CJLoginViewController *loginViewController = [[CJLoginViewController alloc] initWithSourceURL:[NSURL fileURLWithPath:loginJSPath]];
            [rootViewController presentViewController:[[WXRootViewController alloc] initWithRootViewController:loginViewController] animated:true completion:^{
                isLoading = false;
            }];
        });
    };
    if (rootViewController.presentedViewController){
        if (![rootViewController.presentedViewController isKindOfClass:[CJLoginViewController class]]){
            [rootViewController.presentedViewController dismissViewControllerAnimated:NO completion:^{
                login();
            }];
        }else{
            isLoading = false;
        }
    }else{
        login();
    }
}

- (void)logOut:(CJLogOutComplete)complete{
    //退出选择账号页面
    if ([[UIViewController topViewController] isKindOfClass:NSClassFromString(@"TZPhotoPickerController")]){
        [[UIViewController topViewController] dismissViewControllerAnimated:NO completion:nil];
    }
    
    //清空tabbar内堆栈
    CJPostNotification(CJNOTIFICATION_TABBAR_RESET, nil);
    
    //清空根控制器堆栈
    [self popToRootViewController];
    
    //退出IM
    [[TIMManager sharedInstance] logout:nil fail:nil];
    
    //移除本地账号信息
    [CJUserManager removeUser];
    
    //退出当前账号
    [CJNetworkManager PostHttp:HTTPAPI(@"login/logout") Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([[responseObject objectForKey:@"type"] isEqualToString:@"success"] && [[responseObject objectForKey:@"content"] isEqualToString:@"注销成功"]){
                if (complete){
                    complete(true);
                }
            }
        }
        [SharedAppDelegate presentLoginViewController];
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SharedAppDelegate presentLoginViewController];
        if (complete){
            complete(false);
        }
    }];
}

- (void)playSoundOnNewMessage{
    if ([[self topViewController] isKindOfClass:[IMAChatViewController class]]){
        AudioServicesPlaySystemSound(1003);
    }else{
        AudioServicesPlaySystemSound(1007);
    }
}

- (UINavigationController *)navigationViewController{
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]){
        return (UINavigationController *)self.window.rootViewController;
    }else{
        return nil;
    }
}

- (UIViewController *)topViewController{
    if ([self navigationViewController]){
        return [self navigationViewController].topViewController;
    }else{
        return nil;
    }
}

- (void)pushViewController:(UIViewController *)viewController{
    viewController.hidesBottomBarWhenPushed = true;
    if ([self navigationViewController]){
        [[self navigationViewController] pushViewController:viewController animated:true];
    }
}

- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title{
    @autoreleasepool{
        viewController.hidesBottomBarWhenPushed = true;
        if ([self navigationViewController]){
            [[self navigationViewController] pushViewController:viewController withBackTitle:title animated:true];
        }
    }
}

- (UIViewController *)popViewController{
    return [[self navigationViewController] popViewControllerAnimated:true];
}

- (NSArray *)popToRootViewController{
    if ([[self navigationViewController] presentedViewController]){
        [[[self navigationViewController] presentedViewController] dismissViewControllerAnimated:false completion:nil];
    }
    return [[self navigationViewController] popToRootViewControllerAnimated:false];
}

- (NSArray *)popToViewController:(UIViewController *)viewController{
    return [[self navigationViewController] popToViewController:viewController animated:true];
}

- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion{
    UIViewController *top = [self topViewController];
    
    if (vc.navigationController == nil)
    {
        NavigationViewController *nav = [[NavigationViewController alloc] initWithRootViewController:vc];
        [top presentViewController:nav animated:animated completion:completion];
    }
    else
    {
        [top presentViewController:vc animated:animated completion:completion];
    }
}

- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion{
    if (vc.navigationController != [self navigationViewController])
    {
        [vc dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [vc.navigationController popViewControllerAnimated:YES];
    }
}

- (void)pushToChatViewControllerWith:(IMAUser *)user{
    [FriendshipManager getUserProfile:user.userId succ:^(TIMUserProfile *profile) {
        NSString *nickName = profile.remark.length > 0 ? profile.remark : profile.nickname;
        user.icon = profile.faceURL;
        user.nickName = nickName;
        
        [self popToRootViewController];
        
        ChatViewController *vc = [[CustomChatUIViewController alloc] initWith:user];
        
        if ([user isC2CType]){
            TIMConversation *imconv = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:user.userId];
            if ([imconv respondsToSelector:@selector(getUnReadMessageNum)]){
                if ([imconv getUnReadMessageNum] > 0){
                    [vc modifySendInputStatus:SendInputStatus_Send];
                    [imconv setReadMessage:nil succ:nil fail:nil];
                }
            }
        }
        
        vc.hidesBottomBarWhenPushed = true;
        
        [[self navigationViewController] pushViewController:vc withBackTitle:@"返回" animated:true];
    }];
}
@end
