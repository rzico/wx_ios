//
//  UIDevice+Info.h
//  Weex
//
//  Created by macOS on 2017/11/30.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIDevice (Info)

+ (NSString *)currentDeviceModel;
+ (BOOL)isIphoneX;
+ (NSString *)getUserAgent;
@end
