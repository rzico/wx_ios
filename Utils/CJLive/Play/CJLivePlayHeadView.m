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
        [self setFans:0];
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
    
    self.fansLabel = [[UILabel alloc] init];
    [self.fansLabel setFont:[UIFont systemFontOfSize:10]];
    [self.fansLabel setTextColor:[UIColor whiteColor]];
    [self.fansLabel setBackgroundColor:[UIColor clearColor]];
    [self.fansLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:self.fansLabel];
    
    self.attentionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.attentionBtn setImage:[UIImage imageNamed:@"Live-content"] forState:UIControlStateNormal];
    [self.attentionBtn addTarget:self action:@selector(onClickAttentionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.attentionBtn];
}

- (void)layout{
    [self.iconView sizeWith:CGSizeMake(self.height * 0.8, self.height * 0.8)];
    [self.iconView.layer setCornerRadius:self.height * 0.4];
    [self.iconView alignParentLeftWithMargin:self.height * 0.1];
    [self.iconView layoutParentVerticalCenter];
    
    [self.attentionBtn sizeWith:CGSizeMake((self.height - 5) * 2.06, self.height - 5)];
    [self.attentionBtn alignParentRightWithMargin:self.height * 0.1];
    [self.attentionBtn layoutParentVerticalCenter];
    [self.attentionBtn.layer setCornerRadius:self.attentionBtn.height * 0.5];
    
    
    [self.titleLabel sizeWith:CGSizeMake(self.attentionBtn.x - self.iconView.width, self.height * 0.5 - 1)];
    [self.titleLabel alignParentTop];
    [self.titleLabel layoutToRightOf:self.iconView];
    
    [self.fansLabel sizeWith:CGSizeMake(self.attentionBtn.x - self.iconView.width, self.height * 0.5 - 1)];
    [self.fansLabel alignParentBottom];
    [self.fansLabel layoutToRightOf:self.iconView];
}

- (void)setTitle:(NSString *)title{
    [self.titleLabel setText:title];
}

- (void)setAttention:(BOOL)isAttention{
    UIImage *image = isAttention ? [UIImage imageNamed:@"Live-didContent"] : [UIImage imageNamed:@"Live-content"];
    [self.attentionBtn setImage:image forState:UIControlStateNormal];
}

- (void)setFans:(int)fans{
    [self.fansLabel setText:[NSString stringWithFormat:@"粉丝:%@",[self countFormat:fans]]];
}

- (NSString *)countFormat:(int)count{
    NSString *strCount = nil;
    if (count > 10000){
        strCount = [NSString stringWithFormat:@"%.2fw",count * 1.0 / 10000.0];
    }else if (count > 1000){
        strCount = [NSString stringWithFormat:@"%.2fk",count * 1.0 / 1000.0];
    }else{
        strCount = [NSString stringWithFormat:@"%d",count];
    }
    return strCount;
}

- (void)onClickAttentionBtn:(id)sender{
    if ([self.delegate respondsToSelector:@selector(CJLivePlayOnClickAttention)]){
        [self.delegate CJLivePlayOnClickAttention];
    }
}
@end
