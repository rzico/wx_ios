//
//  CJLivePlayHeadView.m
//  Weex
//
//  Created by 郭书智 on 2018/4/13.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePlayHeadView.h"

@implementation CJLivePlayHeadView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setBackgroundColor:[UIColor colorWithHex:0 alpha:0.2]];
        [self.layer setCornerRadius:self.height * 0.5];
        [self createSubViews];
        [self layout];
    }
    return self;
}

- (void)createSubViews{
    self.iconView = [[UIImageView alloc] init];
    [self.iconView.layer setMasksToBounds:true];
    [self addSubview:self.iconView];
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.titleLabel];
    
    self.attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.attentionBtn setImage:[UIImage imageNamed:@"Live-content"] forState:UIControlStateNormal];
    [self.attentionBtn addTarget:self action:@selector(onClickAttentionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.attentionBtn];
}

- (void)layout{
    [self.iconView sizeWith:CGSizeMake(self.height, self.height)];
    [self.iconView.layer setCornerRadius:self.height * 0.5];
    [self.iconView alignParentLeft];
    
    [self.attentionBtn sizeWith:CGSizeMake((self.height - 5) * 2.06, self.height - 5)];
    [self.attentionBtn alignParentRightWithMargin:10];
    [self.attentionBtn layoutParentVerticalCenter];
    [self.attentionBtn.layer setCornerRadius:self.attentionBtn.height * 0.5];
    
    
    [self.titleLabel sizeWith:CGSizeMake(self.attentionBtn.x - self.iconView.width, self.height)];
    [self.titleLabel layoutToRightOf:self.iconView];
}

- (void)setTitle:(NSString *)title{
    [self.titleLabel setText:title];
}

- (void)setAttention:(BOOL)isAttention{
    UIImage *image = isAttention ? [UIImage imageNamed:@"Live-didContent"] : [UIImage imageNamed:@"Live-content"];
    [self.attentionBtn setImage:image forState:UIControlStateNormal];
}

- (void)onClickAttentionBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(CJLivePlayOnClickAttention)]){
        [self.delegate CJLivePlayOnClickAttention];
    }
}
@end
