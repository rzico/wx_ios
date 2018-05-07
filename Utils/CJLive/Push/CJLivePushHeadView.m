//
//  CJLiveHeadView.m
//  Weex
//
//  Created by 郭书智 on 2018/4/3.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePushHeadView.h"

@implementation CJLivePushHeadView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setBackgroundColor:[UIColor colorWithHex:0 alpha:0.2]];
        [self.layer setCornerRadius:self.height * 0.5];
        [self createSubViews];
        [self layout];
        [self setFansCount:0];
    }
    return self;
}

- (void)createSubViews{
    self.iconView = [[UIImageView alloc] init];
    [self.iconView.layer setMasksToBounds:true];
    [self addSubview:self.iconView];
    
    self.nickNameLabel = [[UILabel alloc] init];
    [self.nickNameLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.nickNameLabel setTextColor:[UIColor whiteColor]];
    [self.nickNameLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.nickNameLabel];
    
    
    self.fansLabel = [[UILabel alloc] init];
    [self.fansLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.fansLabel setTextColor:[UIColor whiteColor]];
    [self.fansLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.fansLabel];
}

- (void)layout{
    [self.iconView sizeWith:CGSizeMake(self.height * 0.8, self.height * 0.8)];
    [self.iconView alignParentLeftWithMargin:self.height * 0.1];
    [self.iconView layoutParentVerticalCenter];
    [self.iconView.layer setCornerRadius:self.height * 0.4];
    
    [self.nickNameLabel sizeWith:CGSizeMake(self.width - self.height - 5, self.height * 0.5 - 1)];
    [self.nickNameLabel layoutToRightOf:self.iconView margin:5];
    [self.nickNameLabel alignParentTopWithMargin:1.0];
    
    
    [self.fansLabel sizeEqualTo:self.nickNameLabel];
    [self.fansLabel layoutToRightOf:self.iconView margin:5];
    [self.fansLabel alignParentTopWithMargin:1.0];
    [self.fansLabel alignBottom:self.iconView];
}

- (void)setIconImage:(UIImage *)image{
    [self.iconView setImage:image];
}

- (NSString *)countFormat:(NSInteger)count{
    NSString *strCount = nil;
    if (count > 10000){
        strCount = [NSString stringWithFormat:@"%.2fw",count * 1.0 / 10000.0];
    }else if (count > 1000){
        strCount = [NSString stringWithFormat:@"%.2fk",count * 1.0 / 1000.0];
    }else{
        strCount = [NSString stringWithFormat:@"%zd",count];
    }
    return strCount;
}

- (void)setFansCount:(NSInteger)count{
    [self.fansLabel setText:[NSString stringWithFormat:@"粉丝:%@",[self countFormat:count]]];
}

- (void)setNickName:(NSString *)nickName{
    [self.nickNameLabel setText:nickName];
}
@end
