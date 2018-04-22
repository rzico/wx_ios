//
//  CJAmap.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

@interface CJAmap : NSObject

@property (nonatomic, strong) AMapLocationManager *locationManager;

+ (CJAmap *)shareInstance;
- (void)reGeocodeAction:(AMapLocatingCompletionBlock)completionBlock;

@end
