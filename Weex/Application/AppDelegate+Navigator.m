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
#import "CJRouterViewController.h"
#import <WeexSDK/WeexSDK.h>

@implementation AppDelegate (Navigator)


- (void)presentLoginViewController{
    if (self.router.rootViewController){
        UINavigationController *nav = (UINavigationController *)self.router.rootViewController;
        if ([nav.topViewController isKindOfClass:[CJLoginViewController class]]){
            return;
        }
    }
    [self transToRouterWindowWithUIViewcontroller:[[CJLoginViewController alloc] init]];
}

- (void)transToRouterWindowWithUIViewcontroller:(UIViewController *)viewcontroller{
    [self.window endEditing:YES];
    if (![[UIApplication sharedApplication].keyWindow isKindOfClass:[CJRouterWindow class]]){
        WXPerformBlockOnMainThread(^{
            self.window.windowLevel = UIWindowLevelNormal;
            [self.window resignFirstResponder];
            
            
            self.router.rootViewController = [[WXRootViewController alloc] initWithRootViewController:viewcontroller];
            [viewcontroller.navigationController setNavigationBarHidden:true];
            self.router.windowLevel = UIWindowLevelStatusBar - 1;
            self.router.hidden = false;
            
            self.router.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 1);
            
            [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.router.center = self.center;
                self.router.frame = [UIScreen mainScreen].bounds;
                [self.router makeKeyAndVisible];
            } completion:^(BOOL finished) {
                self.window.hidden = true;
            }];
        });
    }
}

- (void)transToMainWindow{
    WXPerformBlockOnMainThread(^{
        [self.router endEditing:YES];
        [self.router resignFirstResponder];
        
        self.window.hidden = false;
        
        
        [UIView animateWithDuration:0.3f delay:0.1f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.router.center = self.center;
            self.router.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 1);
            [self.window makeKeyAndVisible];
        } completion:^(BOOL finished) {
            self.router.rootViewController = nil;
            self.window.windowLevel = UIWindowLevelStatusBar - 1;
            self.router.windowLevel = UIWindowLevelNormal;
            self.router.hidden = true;
        }];
    });
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
//        AudioServicesPlaySystemSound(1007);
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
