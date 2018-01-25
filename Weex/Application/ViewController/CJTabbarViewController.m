//
//  CJTabbarViewController.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJTabbarViewController.h"
#import <WXRootViewController.h>
#import "CJUserManager.h"
#import "CJRouterViewController.h"

@interface CJTabbarViewController ()<UITabBarControllerDelegate>

@property (nonatomic, strong) NSURL *addJs;
@property (nonatomic, strong) NSURL *friendJs;
@property (nonatomic, strong) NSURL *homeJs;
@property (nonatomic, strong) NSURL *memberJs;
@property (nonatomic, strong) NSURL *messageJs;
@property (nonatomic, strong) CJWeexViewController *homeVC;
@property (nonatomic, strong) CJWeexViewController *friendVC;
@property (nonatomic, strong) CJWeexViewController *messageVC;
@property (nonatomic, strong) CJWeexViewController *memberVC;

@end

@implementation CJTabbarViewController

- (instancetype)initWithJsDictionary:(NSDictionary *)dic{
    self = [self init];
    
    if (!dic){
        dic = [[NSDictionary alloc] initWithContentsOfFile:[DOCUMENT_PATH stringByAppendingPathComponent:@"router.plist"]];
    }
    
    NSString *temp = [NSString string];
    
    temp = [dic objectForKey:@"home"] ? [dic objectForKey:@"home"] : @"file://view/home/index.js";
    temp = [temp rewriteURL];
    _homeJs = [temp hasPrefix:@"/"] ? [NSURL fileURLWithPath:temp] : [NSURL URLWithString:temp];
    
    temp = [dic objectForKey:@"friend"] ? [dic objectForKey:@"friend"] : @"file://view/friend/list.js";
    temp = [temp rewriteURL];
    _friendJs = [temp hasPrefix:@"/"] ? [NSURL fileURLWithPath:temp] : [NSURL URLWithString:temp];
    
    temp = [dic objectForKey:@"add"] ? [dic objectForKey:@"add"] : @"file://view/member/editor/editor.js";
    temp = [temp rewriteURL];
    _addJs = [temp hasPrefix:@"/"] ? [NSURL fileURLWithPath:temp] : [NSURL URLWithString:temp];
    
    temp = [dic objectForKey:@"message"] ? [dic objectForKey:@"message"] : @"file://view/message/list.js";
    temp = [temp rewriteURL];
    _messageJs = [temp hasPrefix:@"/"] ? [NSURL fileURLWithPath:temp] : [NSURL URLWithString:temp];
    
    temp = [dic objectForKey:@"member"] ? [dic objectForKey:@"member"] : @"file://view/member/index.js";
    temp = [temp rewriteURL];
    _memberJs = [temp hasPrefix:@"/"] ? [NSURL fileURLWithPath:temp] : [NSURL URLWithString:temp];
    
    [self setUp];
    return self;
}

- (void)setUp{
    self.delegate = self;
    CGFloat height = self.view.height - 49;
    if ([UIDevice isIphoneX]){
        height -= 34;
    }
    self.automaticallyAdjustsScrollViewInsets = NO;
    _homeVC = [[CJWeexViewController alloc] initWithUrl:_homeJs];
    [_homeVC setLabel:@"home"];
    [_homeVC setViewHeight:height];
    [_homeVC render:nil];
    
    _friendVC = [[CJWeexViewController alloc] initWithUrl:_friendJs];
    [_friendVC setLabel:@"friend"];
    [_friendVC setViewHeight:height];
    [_friendVC render:nil];
    
    _messageVC = [[CJWeexViewController alloc] initWithUrl:_messageJs];
    [_messageVC setLabel:@"message"];
    [_messageVC setViewHeight:height];
    [_messageVC render:nil];
    
    _memberVC = [[CJWeexViewController alloc] initWithUrl:_memberJs];
    [_memberVC setLabel:@"member"];
    [_memberVC setViewHeight:height];
    [_memberVC render:nil];
    
    
    _isLoaded = NO;
    
    self.viewControllers = @[[[WXRootViewController alloc] initWithRootViewController:_homeVC],
                             [[WXRootViewController alloc] initWithRootViewController:_friendVC],
                             [[WXRootViewController alloc] initWithRootViewController:[UIViewController new]],
                             [[WXRootViewController alloc] initWithRootViewController:_messageVC],
                             [[WXRootViewController alloc] initWithRootViewController:_memberVC]
                             ];
    [self setupTabBar];
}

- (void) viewDidLoad{
    [super viewDidLoad];
    CJRegisterNotification(@selector(resetViews), CJNOTIFICATION_TABBAR_RESET);
    CJRegisterNotification(@selector(reloadViews), CJNOTIFICATION_TABBAR_RELOAD);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    WXRootViewController *rootVC = (WXRootViewController *)viewController;
    UIViewController *controller = [rootVC.viewControllers firstObject];
    if ([controller isKindOfClass:[CJWeexViewController class]]){
        CJWeexViewController *vc = (CJWeexViewController *)controller;
        if (vc.label && [vc.label isEqualToString:@"home"]){
            return true;
        }else{
            if ([CJUserManager getUid] > 0){
                return true;
            }else{
                [SharedAppDelegate presentLoginViewController];
                return false;
            }
        }
    }
    return false;
}

- (void)viewWillLayoutSubviews{
    self.navigationController.navigationBarHidden = YES;
    self.edgesForExtendedLayout=UIRectEdgeNone;
    [super viewWillLayoutSubviews];
    if (!self.tabBarHeight){
        return;
    }
    
    
    self.tabBar.frame = ({
        CGRect frame = self.tabBar.frame;
        CGFloat tabBarHeight = self.tabBarHeight;
        frame.size.height = tabBarHeight;
        frame.origin.y = self.view.frame.size.height - tabBarHeight;
        frame;
    });
    
    
}

- (void)setupTabBar{
    NSArray *titleArray = [[NSArray alloc] initWithObjects:@"首页",@"好友",@"",@"消息",@"我的", nil];
    NSArray *imageArray = [[NSArray alloc] initWithObjects:@"ico_home",@"ico_friend",@"",@"ico_msg",@"ico_my", nil];
    
    [UITabBar appearance].translucent = NO;
    
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *obj, NSUInteger idx, BOOL *stop){
        [self setTabBarItem:obj Title:[titleArray objectAtIndex:idx] TitleSize:10 FontName:@"Arial" NormalImage:[imageArray objectAtIndex:idx] NormalColor:[UIColor colorWithHex:0x444444] SelectedImage:[NSString stringWithFormat:@"%@%@",[imageArray objectAtIndex:idx],@"_focus"] SelectedColor:[UIColor colorWithHex:UINavigationBarColor]];
        obj.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -4);
        
        if (self.viewControllers.count % 2 == 1){
            if (idx == self.viewControllers.count / 2){
                obj.tabBarItem.enabled = NO;
            }
        }
    }];
    
    if (self.viewControllers.count % 2 == 1){
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-30 , -10, 60, 60)];
        
        button.layer.cornerRadius = 30;
        button.layer.masksToBounds = YES;
        
        [button setBackgroundColor:[UIColor whiteColor]];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setImage:[UIImage imageNamed:@"ico_add"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"ico_add"] forState:UIControlStateHighlighted];
        [self.tabBar addSubview:button];
        [self.tabBar bringSubviewToFront:button];
        [button addTarget:self action:@selector(selectImagePicker) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = (self.normalColor == NULL ? [UIColor grayColor] : self.normalColor);
    selectedAttrs[NSForegroundColorAttributeName] = (self.selectedColor == NULL ? [UIColor blueColor] : self.selectedColor);
    UITabBarItem *tabBar = [UITabBarItem appearance];
    [tabBar setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBar setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    
    [self.tabBar setBackgroundImage:[UIImage new]];
    [self.tabBar setBackgroundColor:[UIColor clearColor]];
    [self.tabBar setShadowImage:[UIImage createImageWithColor:[UIColor colorWithHex:0xdddddd] frame:CGRectMake(0, 0, [UIScreen getWidth], 0.5)]];
    //    [self.tabBar setShadowImage:[UIImage imageNamed:@"tapbar_top_line"]];
}

- (void)setTabBarItem:(UIViewController *)tabBarViewController
                Title:(NSString *)title
            TitleSize:(CGFloat)size
             FontName:(NSString *)fontName
          NormalImage:(NSString *)normalImage
          NormalColor:(UIColor *)normalColor
        SelectedImage:(NSString *)selectedImage
        SelectedColor:(UIColor *)selectedColor{
    
    UITabBarItem *tabBarItem = tabBarViewController.tabBarItem;
    
    [tabBarItem setTitle:title];
    
    tabBarItem = [tabBarItem initWithTitle:title
                                     image:[[UIImage imageNamed:normalImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                             selectedImage:[[UIImage imageNamed:selectedImage] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    
    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:normalColor,NSFontAttributeName:[UIFont fontWithName:fontName size:size]} forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:selectedColor,NSFontAttributeName:[UIFont fontWithName:fontName size:size]} forState:UIControlStateSelected];
    
}


- (void)selectImagePicker {
    if ([CJUserManager getUid] > 0){
        CJRouterViewController *editorVc = [[CJRouterViewController alloc] initWithUrl:_addJs];
        [editorVc render:nil];
        [SharedAppDelegate transToRouterWindowWithUIViewcontroller:editorVc];
//        [[self navigationController] pushViewController:editorVc animated:YES];
    }else{
        [SharedAppDelegate presentLoginViewController];
    }
}

- (void)didReceiveMemoryWarning{
    
}

- (void)dealloc{
    CJRemoveNotification(CJNOTIFICATION_TABBAR_RESET);
    CJRemoveNotification(CJNOTIFICATION_TABBAR_RELOAD);
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)resetViews{
    dispatch_async(dispatch_get_main_queue(), ^{
        _isLoaded = NO;
        self.selectedIndex = 0;
        for (int i = 0; i < self.viewControllers.count; i ++){
            WXRootViewController *nav = (WXRootViewController *)[self.viewControllers objectAtIndex:i];
            if (nav){
                while (nav.viewControllers.count > 1) {
                    [nav popViewControllerAnimated:NO];
                }
            }
        }
    });
}

- (void)reloadViews{
    [_friendVC render:nil];
    [_messageVC render:nil];
    [_memberVC render:nil];
    _isLoaded = YES;
}
@end
