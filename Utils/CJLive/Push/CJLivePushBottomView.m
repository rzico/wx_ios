//
//  CJLivePushBottomView.m
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePushBottomView.h"

@implementation CJLivePushBottomView{
    BOOL    isTorchOn;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self createSubViews];
        [self layout];
    }
    return self;
}

- (void)createSubViews{
    self.filterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.filterBtn setBackgroundImage:[UIImage imageNamed:@"filter"] forState:UIControlStateNormal];
    [self.filterBtn addTarget:self action:@selector(filterBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.filterBtn];
    
    self.turnCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.turnCameraBtn setBackgroundImage:[UIImage imageNamed:@"turnCamera"] forState:UIControlStateNormal];
    [self.turnCameraBtn addTarget:self action:@selector(turnCameraBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.turnCameraBtn];
    
    self.toggleTorchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.toggleTorchBtn setBackgroundImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
    [self.toggleTorchBtn addTarget:self action:@selector(toggleTorchBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.toggleTorchBtn];
    
    self.giftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.giftBtn setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
    [self.giftBtn setImage:[UIImage imageNamed:@"Live_Gift"] forState:UIControlStateNormal];
    [self.giftBtn addTarget:self action:@selector(giftBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.giftBtn];
}
    
- (void)layout{
    [self.filterBtn sizeWith:CGSizeMake(self.height, self.height)];
    [self.filterBtn.layer setCornerRadius:self.height * 0.5];
    [self.filterBtn alignParentLeftWithMargin:20.0];
    
    [self.giftBtn sizeWith:CGSizeMake(self.height, self.height)];
    [self.giftBtn.layer setCornerRadius:self.height * 0.5];
    [self.giftBtn layoutToRightOf:self.filterBtn margin:20.0];
    
    [self.turnCameraBtn sizeWith:CGSizeMake(self.height, self.height)];
    [self.turnCameraBtn.layer setCornerRadius:self.height * 0.5];
    [self.turnCameraBtn layoutToRightOf:self.giftBtn margin:20.0];
    
    [self.toggleTorchBtn sizeWith:CGSizeMake(self.height, self.height)];
    [self.toggleTorchBtn.layer setCornerRadius:self.height * 0.5];
    [self.toggleTorchBtn layoutToRightOf:self.turnCameraBtn margin:20.0];
}
    
- (void)filterBtnOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJLivePushBottomOnClickFilter)]){
        [_delegate CJLivePushBottomOnClickFilter];
    }
}

- (void)turnCameraBtnOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJLivePushBottomOnClickTurnCamera)]){
        [_delegate CJLivePushBottomOnClickTurnCamera];
    }
}

- (void)toggleTorchBtnOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJLivePushBottomOnClickToggleTorch)]){
        [_delegate CJLivePushBottomOnClickToggleTorch];
    }
}

- (void)giftBtnOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJLivePushBottomOnClickGift)]){
        [_delegate CJLivePushBottomOnClickGift];
    }
}
@end
