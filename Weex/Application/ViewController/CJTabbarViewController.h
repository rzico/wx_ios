//
//  CJTabbarViewController.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJWeexViewController.h"

@interface CJTabbarViewController : UITabBarController

- (instancetype)initWithJsDictionary:(NSDictionary *)dic;

@property (nonatomic, readwrite) CGFloat tabBarHeight;
@property (nonatomic, readwrite, copy) UIColor *normalColor;
@property (nonatomic, readwrite, copy) UIColor *selectedColor;
@property (nonatomic, assign) BOOL isLoaded;

@end
