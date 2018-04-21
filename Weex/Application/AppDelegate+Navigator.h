//
//  AppDelegate+Navigator.h
//  Weex
//
//  Created by macOS on 2017/12/20.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IMAUser;



@interface AppDelegate (Navigator)

- (void)presentLoginViewController;
- (void)logOut:(CJLogOutComplete)complete;
- (void)playSoundOnNewMessage;

- (UINavigationController *)navigationViewController;
- (UIViewController *)topViewController;
- (void)pushViewController:(UIViewController *)viewController;
- (NSArray *)popToViewController:(UIViewController *)viewController;
- (void)pushViewController:(UIViewController *)viewController withBackTitle:(NSString *)title;
- (UIViewController *)popViewController;
- (NSArray *)popToRootViewController;
- (void)presentViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissViewController:(UIViewController *)vc animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)pushToChatViewControllerWith:(IMAUser *)user;

- (void)transToRouterWindowWithUIViewcontroller:(UIViewController *)viewcontroller;
- (void)transToMainWindow;
@end
