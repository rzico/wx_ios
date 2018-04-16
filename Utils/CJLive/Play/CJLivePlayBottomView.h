//
//  CJLivePlayBottomView.h
//  Weex
//
//  Created by 郭书智 on 2018/4/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CJLivePlayBottomViewDelegate <NSObject>

@optional

- (void)CJLivePlayBottomOnClickMsgPlaceBtn;

- (void)CJLivePlayBottomOnClickGiftBtn;

- (void)CJLivePlayBottomOnClickPraiseBtn;

@end

@interface CJLivePlayBottomView : UIView

@property (nonatomic, strong) UIButton *msgPlaceBtn;

@property (nonatomic, strong) UIButton *giftBtn;

@property (nonatomic, strong) UIButton *praiseBtn;

@property (nonatomic, weak) id<CJLivePlayBottomViewDelegate> delegate;
@end
