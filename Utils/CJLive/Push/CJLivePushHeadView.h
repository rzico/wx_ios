//
//  CJLiveHeadView.h
//  Weex
//
//  Created by 郭书智 on 2018/4/3.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJLivePushHeadView : UIView

@property (nonatomic, strong) UIImageView*  iconView;

@property (nonatomic, strong) UILabel*      fansLabel;

@property (nonatomic, strong) UILabel*      nickNameLabel;

- (void)setIconImage:(UIImage *)image;

- (void)setFansCount:(NSInteger)count;

- (void)setNickName:(NSString *)nickName;
@end
