//
//  IWXToastInfo.h
//  Weex
//
//  Created by 郭书智 on 2017/9/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IWXToastInfo : NSObject

@property (nonatomic, strong) UIView *toastView;
@property (nonatomic, weak) UIView *superView;
@property (nonatomic, assign) double duration;

@end
