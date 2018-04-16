//
//  UIDevice+Info.h
//  Weex
//
//  Created by 郭书智 on 2018/3/16.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Info)

+ (NSString *)currentDeviceModel;
+ (BOOL)isIphoneX;
+ (NSString *)getUserAgent;

@end
