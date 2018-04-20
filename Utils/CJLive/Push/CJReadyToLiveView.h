//
//  CJReadyToLiveView.h
//  Weex
//
//  Created by 郭书智 on 2018/4/3.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJReadyToLiveDelegate <NSObject>

@optional

- (void)CJReadyToLiveOnClickChangeImageButton;

- (void)CJReadyToLiveOnClickBeginLiveButton;

- (void)CJReadyToLiveOnClickRuleButton;

@end

@interface CJReadyToLiveView : UIView

@property (nonatomic, strong) UITextField *titleLabel;

@property (nonatomic, assign) BOOL isRecord;

@property (nonatomic, assign) BOOL isAgreen;

@property (nonatomic, assign) BOOL isChoosedImage;

@property (nonatomic, weak) id<CJReadyToLiveDelegate> delegate;

@property (nonatomic, assign) CGRect kbHideFrame;

@property (strong, nonatomic) UIImageView  *imageView;

- (void)setImage:(UIImage *)image;

@end
