//
//  IWXToastManager.h
//  Weex
//
//  Created by 郭书智 on 2017/9/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IWXToastInfo.h"

@interface IWXToastManager : NSObject

@property (strong, nonatomic) NSMutableArray<IWXToastInfo *> *toastQueue;
@property (strong, nonatomic) UIView *toastingView;

+ (IWXToastManager *)sharedManager;

@end
