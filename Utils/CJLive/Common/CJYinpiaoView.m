//
//  CJYinpiaoView.m
//  Weex
//
//  Created by 郭书智 on 2018/4/28.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJYinpiaoView.h"

@implementation CJYinpiaoView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setBackgroundColor:[UIColor colorWithHex:0 alpha:0.2]];
        [self.layer setCornerRadius:self.height * 0.5];
        [self createSubViews];
        [self layout];
        [self setYinpiao:0];
    }
    return self;
}

- (void)createSubViews{
    self.yinpiaoLabel = [[UILabel alloc] init];
    self.yinpiaoLabel.font = [UIFont systemFontOfSize:11];
    self.yinpiaoLabel.textColor = [UIColor whiteColor];
    self.yinpiaoLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.yinpiaoLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(yinpiaoLabelOnClick:)];
    [self addGestureRecognizer:tap];
}

- (void)layout{
    [self.yinpiaoLabel sizeWith:self.size];
}

- (void)setYinpiao:(NSInteger)yinpiao{
    [self.yinpiaoLabel setText:[NSString stringWithFormat:@"碳币:%zd",yinpiao]];
}

- (void)yinpiaoLabelOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJYinpiaoViewOnClick)]){
        [_delegate CJYinpiaoViewOnClick];
    }
}

@end
