//
//  CJTextCell.m
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJTextCell.h"

@implementation CJTextCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self setupView];
    }
    return self;
}

+ (NSString *)reuseIdentifier
{
    return NSStringFromClass([self class]);
}

- (void)setSelected:(BOOL)selected
{
    if(selected){
        self.label.textColor = [UIColor colorWithHex:0x0accac];
    }
    else{
        self.label.textColor = [UIColor whiteColor];
    }
}

- (void)setupView
{
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.label = [[UILabel alloc] initWithFrame:self.bounds];
    self.label.textColor = [UIColor whiteColor];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
}

@end
