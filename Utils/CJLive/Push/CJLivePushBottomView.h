//
//  CJLivePushBottomView.h
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJLivePushBottomViewDelegate <NSObject>
    
@optional
    
- (void)CJLivePushBottomOnClickTurnCamera;
    
- (void)CJLivePushBottomOnClickToggleTorch;
    
- (void)CJLivePushBottomOnClickFilter;
    
@end

@interface CJLivePushBottomView : UIView

@property (nonatomic, strong) UIButton  *turnCameraBtn;
    
@property (nonatomic, strong) UIButton  *toggleTorchBtn;
    
@property (nonatomic, strong) UIButton  *filterBtn;

@property (nonatomic, weak) id<CJLivePushBottomViewDelegate> delegate;

@end