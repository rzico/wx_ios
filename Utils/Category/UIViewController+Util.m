//
//  UIViewController+Util.m
//  Weex
//
//  Created by 郭书智 on 2017/10/8.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "UIViewController+Util.h"

@implementation UIViewController (Util)

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
