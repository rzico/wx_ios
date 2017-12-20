//
//  AppDelegate.m
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "AppDelegate.h"
#import "CJTabbarViewController.h"
#import <WXRootViewController.h>
#import "IMManager.h"
#import "TIMActionManager.h"

@interface AppDelegate ()

@property (nonatomic, assign) BOOL isLoaded;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    CJRegisterNotification(@selector(onInitialized:),CJNOTIFICATION_INITIALIZED);
    [self checkNetwork];
    _isLoaded = false;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [NSClassFromString(@"MainViewController") new];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)checkNetwork{
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWiFi ||
            status == AFNetworkReachabilityStatusReachableViaWWAN){
            //网络连通后处理
            NSLog(@"on connected");
            [[IMManager sharedInstance] loginWithUser:[CJUserManager getUser] loginOption:IMManagerLoginOptionForce andBlock:nil];
        }else{
            //网络不通处理
            NSLog(@"on disconnected");
        }
    }];
    [manager startMonitoring];
}

- (void)onInitialized:(NSNotification *)notification{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CJTabbarViewController *tabBar = [[CJTabbarViewController alloc] initWithJsDictionary:notification.userInfo];
        self.window.rootViewController = [[WXRootViewController alloc] initWithRootViewController:tabBar];
        self.window.rootViewController.view.alpha = 0.0f;
        [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.window.rootViewController.view.alpha = 1.0f;
        } completion:^(BOOL finished) {
            _isLoaded = true;
        }];
    });
}

- (void) onReq:(BaseReq *)req{
    [WXApi sendReq:req];
}

- (void) onResp:(BaseResp *)resp{
    if ([resp isKindOfClass:[SendAuthResp class]]){
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (self.wxAuthComplete){
            self.wxAuthComplete(aresp);
        }
    }else if ([resp isKindOfClass:[PayResp class]]){
        PayResp *payResp = (PayResp *)resp;
        if (self.wxPayComplete){
            self.wxPayComplete(payResp);
        }
    }else if ([resp isKindOfClass:[SendMessageToWXResp class]]){
        SendMessageToWXResp *shareResp = (SendMessageToWXResp *)resp;
        if (self.wxShareComplete){
            self.wxShareComplete(shareResp);
        }
    }
}

- (BOOL)handleOpenURL:(NSURL *)url{
    NSString *newUrlStr = url.absoluteString;
    NSString *schemeHeader = [openURLScheme stringByAppendingString:@"://"];
    if([url.scheme isEqualToString:WECHAT_APPID]) {
        return [WXApi handleOpenURL:url delegate:self];
    }else if ([url.scheme isEqualToString:openURLScheme]){
        if ([newUrlStr isEqualToString:schemeHeader]){
            return YES;
        }else{
            newUrlStr = [newUrlStr stringByReplacingOccurrencesOfString:schemeHeader withString:@""];
            NSArray *pairComponents = [newUrlStr componentsSeparatedByString:@"?"];
            if (pairComponents.count != 2){
                return NO;
            }else{
                NSString *interface = [pairComponents firstObject];
                NSArray *params = [[pairComponents lastObject] componentsSeparatedByString:@"="];
                if ([interface isEqualToString:@"article"]){
                    NSString *articleUrlStr = [NSString stringWithFormat:@"file://view/article/preview.js?articleId=%@&publish=true",[params lastObject]];
                    articleUrlStr = [articleUrlStr rewriteURL];
                    articleUrlStr = [NSString stringWithFormat:@"file://%@",articleUrlStr];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CJWeexViewController *viewController = [[CJWeexViewController alloc] initWithUrl:[NSURL URLWithString:articleUrlStr]];
                        [viewController render:^(BOOL finished) {
                            [(WXRootViewController*)self.window.rootViewController pushViewController:viewController animated:YES];
                        }];
                    });
                    return YES;
                }else if ([interface isEqualToString:@"topic"]){
                    NSString *topicUrlStr = [NSString stringWithFormat:@"file://view/topic/index.js?id=%@",[params lastObject]];
                    topicUrlStr = [topicUrlStr rewriteURL];
                    topicUrlStr = [NSString stringWithFormat:@"file://%@",topicUrlStr];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        CJWeexViewController *viewController = [[CJWeexViewController alloc] initWithUrl:[NSURL URLWithString:topicUrlStr]];
                        [viewController render:^(BOOL finished) {
                            [(WXRootViewController*)self.window.rootViewController pushViewController:viewController animated:YES];
                        }];
                    });
                    return YES;
                }else if ([interface isEqualToString:@"chat"]){
                    NSString *userId = [params lastObject];
                    [self pushToChatViewControllerWith:[[IMAUser alloc] initWith:userId]];
                    return YES;
                }else{
                    return NO;
                }
            }
        }
    }
    return NO;
}


- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [self handleOpenURL:url];
}

- (void)registNotification{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes: (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    self.userInfo = userInfo;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"apnserror=%@",error);
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"deviceToken=%@",[deviceToken description]);
    [[IMAPlatform sharedInstance] configOnAppRegistAPNSWithDeviceToken:deviceToken];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    __block UIBackgroundTaskIdentifier bgTaskID;
    bgTaskID = [application beginBackgroundTaskWithExpirationHandler:^ {
        
        //不管有没有完成，结束background_task任务
        [application endBackgroundTask: bgTaskID];
        bgTaskID = UIBackgroundTaskInvalid;
    }];
    
    [[IMAPlatform sharedInstance] configOnAppEnterBackground];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    void(^finishBlock)() = ^(){
        if ([CJUserManager getUid] > 0){
            [TIMActionManager PostAllConversationWithLastMessage];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.userInfo){
                    if ([[self topViewController] isKindOfClass:[UITabBarController class]]){
                        UITabBarController *tabbar = (UITabBarController *)[self topViewController];
                        tabbar.selectedIndex = 3;
                    }
                }
            });
        }
    };
    
    if ([CJUserManager getUid] > 0){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //等待载入完毕
            while (!_isLoaded) {
                [NSThread sleepForTimeInterval:0.5];
            }
            [[TIMManager sharedInstance] doForeground:^() {
                DebugLog(@"doForegroud Succ");
                finishBlock();
            } fail:^(int code, NSString * err) {
                [[IMManager sharedInstance] loginWithUser:[CJUserManager getUser] loginOption:IMManagerLoginOptionForce andBlock:^(BOOL success) {
                    finishBlock();
                }];
            }];
        });
    }
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
