//
//  CJYinpiaoView.h
//  Weex
//
//  Created by 郭书智 on 2018/4/28.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJYinpiaoViewDelegate<NSObject>

@optional

- (void)CJYinpiaoViewOnClick;

@end

@interface CJYinpiaoView : UIView

@property (nonatomic, strong) UILabel *yinpiaoLabel;

- (void)setYinpiao:(NSInteger)yinpiao;

@property (nonatomic, strong) id<CJYinpiaoViewDelegate> delegate;

@end
