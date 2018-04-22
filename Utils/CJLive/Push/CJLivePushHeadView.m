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
        [self setAttentionCount:0];
    }
    return self;
}

- (void)createSubViews{
    self.iconView = [[UIImageView alloc] init];
    [self.iconView.layer setMasksToBounds:true];
    [self addSubview:self.iconView];
    
    self.fansLabel = [[UILabel alloc] init];
    [self.fansLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.fansLabel setTextColor:[UIColor whiteColor]];
    [self.fansLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.fansLabel];
    
    self.attentionLabel = [[UILabel alloc] init];
    [self.attentionLabel setFont:[UIFont systemFontOfSize:10.0]];
    [self.attentionLabel setTextColor:[UIColor whiteColor]];
    [self.attentionLabel setBackgroundColor:[UIColor clearColor]];
    [self addSubview:self.attentionLabel];
}

- (void)layout{
    [self.iconView sizeWith:CGSizeMake(self.height, self.height)];
    [self.iconView alignParentLeft];
    [self.iconView.layer setCornerRadius:self.height * 0.5];
    
    [self.fansLabel sizeWith:CGSizeMake(self.width - self.height, self.height * 0.5 - 1)];
    [self.fansLabel layoutToRightOf:self.iconView];
    [self.fansLabel alignParentTopWithMargin:1.0];
    
    [self.attentionLabel sizeEqualTo:self.fansLabel];
    [self.attentionLabel alignLeft:self.fansLabel];
    [self.attentionLabel alignBottom:self.iconView];
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

- (void)setAttentionCount:(NSInteger)count{
    [self.attentionLabel setText:[NSString stringWithFormat:@"关注:%@",[self countFormat:count]]];
}
@end
