//
//  CJLivePlayHeadView.h
//  Weex
//
//  Created by 郭书智 on 2018/4/13.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJLivePlayHeadDelegate <NSObject>

@optional

- (void)CJLivePlayOnClickAttention;

@end


@interface CJLivePlayHeadView : UIView

@property (nonatomic, strong) UIImageView*  iconView;

@property (nonatomic, strong) UILabel*      titleLabel;

@property (nonatomic, strong) UILabel*      fansLabel;

@property (nonatomic, strong) UIButton*     attentionBtn;

- (void)setIconImage:(UIImage *)image;

- (void)setTitle:(NSString *)title;

- (void)setFans:(int)fans;

- (void)setAttention:(BOOL)isAttention;

@property (nonatomic, weak) id<CJLivePlayHeadDelegate> delegate;

@end
