//
//  CJGameViewController.h
//  Weex
//
//  Created by 郭书智 on 2018/6/12.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^GameClosedBlock)(void);

typedef NS_ENUM(NSUInteger, CJGameType) {
    CJGameTypeLandscape = 0,
    CJGameTypeHalfView
};

@interface CJGameViewController : UIViewController

@property (nonatomic, assign) CJGameType type;

- (instancetype)initWithType:(CJGameType)type;
- (void)loadWithUrl:(NSString *)url video:(NSString *)video method:(NSString *)method callback:(GameClosedBlock)callback;
- (void)destroy;

@end
