//
//  CJAudienceView.m
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJAudienceView.h"

@implementation CJAudienceView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self setBackgroundColor:[UIColor colorWithHex:0 alpha:0.2]];
        [self.layer setCornerRadius:self.height * 0.5];
        [self createSubViews];
        [self layout];
        [self setAudience:0];
    }
    return self;
}

- (void)createSubViews{
    self.audienceLabel = [[UILabel alloc] init];
    self.audienceLabel.font = [UIFont systemFontOfSize:11];
    self.audienceLabel.textColor = [UIColor whiteColor];
    self.audienceLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.audienceLabel];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(audienceLabelOnClick:)];
    [self addGestureRecognizer:tap];
}

- (void)layout{
    [self.audienceLabel sizeWith:self.size];
}

- (void)setAudience:(NSInteger)count{
    if (count > 10000){
        _audienceLabel.text = [NSString stringWithFormat:@"%.2fw",count * 1.0 / 10000.0];
    }else if (count > 1000){
        _audienceLabel.text = [NSString stringWithFormat:@"%.2fk",count * 1.0 / 1000.0];
    }else{
        _audienceLabel.text = [NSString stringWithFormat:@"%zd",count];
    }
}

- (void)audienceLabelOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJAudienceViewOnClickAudienceLabel)]){
        [_delegate CJAudienceViewOnClickAudienceLabel];
    }
}
@end
