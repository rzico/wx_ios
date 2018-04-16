//
//  CJLivePlayBottomView.m
//  Weex
//
//  Created by 郭书智 on 2018/4/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePlayBottomView.h"

@implementation CJLivePlayBottomView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self createSubViews];
        [self layout];
    }
    return self;
}

- (void)createSubViews{
    _msgPlaceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_msgPlaceBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_msgPlaceBtn setTitle:@"聊点什么吧" forState:UIControlStateNormal];
    [_msgPlaceBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
    [_msgPlaceBtn addTarget:self action:@selector(onClickMsgPlaceBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_msgPlaceBtn];
    
    _giftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_giftBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_giftBtn setImage:[UIImage imageNamed:@"Live_Gift"] forState:UIControlStateNormal];
    [_giftBtn addTarget:self action:@selector(onClickGiftBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_giftBtn];
    
    _praiseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_praiseBtn setBackgroundColor:[UIColor darkGrayColor]];
    [_praiseBtn setImage:[UIImage imageNamed:@"Live_Praise"] forState:UIControlStateNormal];
    [_praiseBtn addTarget:self action:@selector(onClickPraiseBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_praiseBtn];
}

- (void)layout{
    [_praiseBtn sizeWith:CGSizeMake(self.height, self.height)];
    [_praiseBtn alignParentRightWithMargin:30];
    [_praiseBtn.layer setCornerRadius:self.height * 0.5];
    
    [_giftBtn sizeWith:CGSizeMake(self.height, self.height)];
    [_giftBtn layoutToLeftOf:_praiseBtn margin:30];
    [_giftBtn.layer setCornerRadius:self.height * 0.5];
    
    [_msgPlaceBtn sizeWith:CGSizeMake(0, self.height)];
    [_msgPlaceBtn alignParentLeftWithMargin:30];
    [_msgPlaceBtn.layer setCornerRadius:self.height * 0.5];
    
    
    _msgPlaceBtn.width = _giftBtn.x - 30 - 30;
    
    
    
}

- (void)onClickMsgPlaceBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(CJLivePlayBottomOnClickMsgPlaceBtn)]){
        [self.delegate CJLivePlayBottomOnClickMsgPlaceBtn];
    }
}

- (void)onClickGiftBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(CJLivePlayBottomOnClickGiftBtn)]){
        [self.delegate CJLivePlayBottomOnClickGiftBtn];
    }
}

- (void)onClickPraiseBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(CJLivePlayBottomOnClickPraiseBtn)]){
        [self.delegate CJLivePlayBottomOnClickPraiseBtn];
    }
}
@end
