//
//  CJShareManager.h
//  Weex
//
//  Created by macOS on 2017/11/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ShareComplete)(id result);

@interface CJShareManager : NSObject

@property (nonatomic, strong) NSDictionary *option;
@property (nonatomic, assign) ShareComplete complete;

+ (void)shareWithWeixin:(NSDictionary *)option complete:(ShareComplete)complete;
+ (void)shareWithPasteBoard:(NSDictionary *)option complete:(ShareComplete)complete;
+ (void)shareWithBrowser:(NSDictionary *)option complete:(ShareComplete)complete;
@end
