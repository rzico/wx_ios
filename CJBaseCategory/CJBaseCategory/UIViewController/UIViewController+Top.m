//
//  UIViewController+Top.m
//  Application
//
//  Created by 郭书智 on 2018/3/26.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import "UIViewController+Top.h"

@implementation UIViewController (Top)

+ (UIViewController *)topViewController{
    UIViewController *resultVC;
    resultVC = [UIViewController _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [UIViewController _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

+ (UIViewController *)_topViewController:(UIViewController *)vc{
    if ([vc isKindOfClass:[UINavigationController class]]){
        return [UIViewController _topViewController:[(UINavigationController *)vc topViewController]];
    }else if ([vc isKindOfClass:[UITabBarController class]]){
        return [UIViewController _topViewController:[(UITabBarController *)vc selectedViewController]];
    }else{
        return vc;
    }
}

@end
