//
//  CJRouterTabbar.h
//  Weex
//
//  Created by macOS on 2018/1/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <JSONModel.h>
#import "CJRouterTabbarTab.h"

@interface CJRouterTabbar : JSONModel

@property (nonatomic, strong) CJRouterTabbarTab *tab1;
@property (nonatomic, strong) CJRouterTabbarTab *tab2;
@property (nonatomic, strong) CJRouterTabbarTab *tab3;
@property (nonatomic, strong) CJRouterTabbarTab *tab4;
@property (nonatomic, strong) CJRouterTabbarTab *tab5;

@end
