//
//  CJRouter.h
//  Weex
//
//  Created by macOS on 2018/1/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <JSONModel.h>
#import "CJRouterPage.h"
#import "CJRouterTabbar.h"

@interface CJRouter : JSONModel

@property (nonatomic, strong) NSArray<CJRouterPage *> *page;
@property (nonatomic, strong) CJRouterTabbar *tabbar;

+ (instancetype)shareInstance;

@end
