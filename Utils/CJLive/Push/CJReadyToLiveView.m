//
//  CJReadyToLiveView.m
//  Weex
//
//  Created by 郭书智 on 2018/4/3.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJReadyToLiveView.h"

@interface CJReadyToLiveView ()

@property (strong, nonatomic) UIButton     *addImageBtn;

@property (strong, nonatomic) UIButton     *changeImageBtn;

@property (strong, nonatomic) UIView       *line;

@property (strong, nonatomic) UIButton     *beginToLiveBtn;

@property (strong, nonatomic) UIButton     *agreenBtn;

@property (strong, nonatomic) UIButton     *ruleBtn;

@property (strong, nonatomic) UIButton     *recordBtn;

@end

@implementation CJReadyToLiveView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self){
        [self createSubViews];
        [self layout];
        [self.changeImageBtn setHidden:true];
        _isChoosedImage = false;
    }
    return self;
}


- (void)createSubViews{
    self.imageView = [[UIImageView alloc] init];
    [self.imageView setImage:[UIImage imageNamed:@"dashedLine"]];
    [self.imageView setContentMode:UIViewContentModeScaleToFill];
    [self addSubview:self.imageView];
    
    self.addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addImageBtn setImage:[UIImage imageNamed:@"addImage"] forState:UIControlStateNormal];
    [self.addImageBtn setTitle:@"设置封面图" forState:UIControlStateNormal];
    [self.addImageBtn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
    [self.addImageBtn setTitleColor:[UIColor colorWithHex:0x4c4a4b] forState:UIControlStateNormal];
    [self.addImageBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [self.addImageBtn addTarget:self action:@selector(changeImageBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.addImageBtn];
    
    self.changeImageBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.changeImageBtn setTitle:@"更改封面图" forState:UIControlStateNormal];
    [self.changeImageBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.changeImageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.changeImageBtn setBackgroundColor:[UIColor colorWithHex:0 alpha:0.3]];
    [self.changeImageBtn addTarget:self action:@selector(changeImageBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.changeImageBtn];
    
    self.titleLabel = [[UITextField alloc] init];
    [_titleLabel setPlaceholder:@"请输入标题(长度不超过20)"];
    [_titleLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self addSubview:self.titleLabel];
    
    self.line = [[UIView alloc] init];
    [self.line setBackgroundColor:[UIColor colorWithHex:0xf2f2f2]];
    [self addSubview:self.line];
    
    self.beginToLiveBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.beginToLiveBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [self.beginToLiveBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0]];
    [self.beginToLiveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.beginToLiveBtn setBackgroundColor:[UIColor colorWithHex:0xdddddd]];
    [self.beginToLiveBtn addTarget:self action:@selector(beginToLiveBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.beginToLiveBtn];
    
    self.recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordBtn setTitle:@"是否录制" forState:UIControlStateNormal];
    [self.recordBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self.recordBtn setImage:[UIImage imageNamed:@"unChoose"] forState:UIControlStateNormal];
    [self.recordBtn setImage:[UIImage imageNamed:@"didChoose"] forState:UIControlStateSelected];
    [self.recordBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.recordBtn setTitleColor:[UIColor colorWithRed:76/255.0 green:74/255.0 blue:75/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.recordBtn setBackgroundColor:[UIColor clearColor]];
    [self.recordBtn addTarget:self action:@selector(recordBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.recordBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.recordBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self addSubview:self.recordBtn];
    
    self.agreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.agreenBtn setTitle:@"同意" forState:UIControlStateNormal];
    [self.agreenBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self.agreenBtn setImage:[UIImage imageNamed:@"unChoose"] forState:UIControlStateNormal];
    [self.agreenBtn setImage:[UIImage imageNamed:@"didChoose"] forState:UIControlStateSelected];
    [self.agreenBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    [self.agreenBtn setTitleColor:[UIColor colorWithRed:76/255.0 green:74/255.0 blue:75/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.agreenBtn setBackgroundColor:[UIColor clearColor]];
    [self.agreenBtn addTarget:self action:@selector(agreenBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.agreenBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.agreenBtn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self addSubview:self.agreenBtn];
    
    self.ruleBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.ruleBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0]];
    [self.ruleBtn setTitle:@"《泥炭直播管理条例》" forState:UIControlStateNormal];
    [self.ruleBtn setTitleColor:[UIColor colorWithHex:0xe65a53] forState:UIControlStateNormal];
    [self.ruleBtn setBackgroundColor:[UIColor clearColor]];
    [self.ruleBtn addTarget:self action:@selector(ruleBtnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.ruleBtn];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self addGestureRecognizer:tap];
}

- (void)layout{
    [self.imageView sizeWith:CGSizeMake(200, 120)];
    [self.imageView layoutParentHorizontalCenter];
    [self.imageView marginParentTop:self.imageView.left];
    
    [self.addImageBtn sizeWith:CGSizeMake(self.imageView.width, 30)];
    [self.addImageBtn alignCenterOf:self.imageView];
    
    [self.changeImageBtn sizeWith:CGSizeMake(self.imageView.width, 30)];
    [self.changeImageBtn alignLeft:self.imageView];
    [self.changeImageBtn alignBottom:self.imageView];
    
    [self.titleLabel sizeWith:CGSizeMake(self.imageView.width, 20)];
    [self.titleLabel alignBottom:self.imageView margin:-40];
    [self.titleLabel layoutParentHorizontalCenter];
    
    [self.line sizeWith:CGSizeMake(self.titleLabel.width, 1)];
    [self.line alignBottom:self.titleLabel margin:-4];
    [self.line alignLeft:self.titleLabel];
    
    [self.beginToLiveBtn sizeWith:CGSizeMake(self.imageView.width, 50)];
    [[self.beginToLiveBtn layer] setCornerRadius:self.beginToLiveBtn.height * 0.5];
    [self.beginToLiveBtn alignBottom:self.line margin:-70];
    [self.beginToLiveBtn layoutParentHorizontalCenter];
    
    [self.recordBtn sizeWith:CGSizeMake(100, 26)];
    [self.recordBtn alignLeft:self.imageView margin:10.0];
    [self.recordBtn alignBottom:self.beginToLiveBtn margin:-40];
    
    [self.agreenBtn sizeWith:CGSizeMake(50, 26)];
    [self.agreenBtn alignLeft:self.imageView margin:10.0];
    [self.agreenBtn alignBottom:self.recordBtn margin:-40];
    
    [self.ruleBtn sizeWith:CGSizeMake(125, 26)];
    [self.ruleBtn alignTop:self.agreenBtn];
    [self.ruleBtn alignRight:self.agreenBtn margin:-130];
    
    [self setHeight:self.ruleBtn.y + self.ruleBtn.height + self.imageView.y];
}

- (void)changeImageBtnOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJReadyToLiveOnClickChangeImageButton)]){
        [_delegate CJReadyToLiveOnClickChangeImageButton];
    }
}

- (void)beginToLiveBtnOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJReadyToLiveOnClickBeginLiveButton)]){
        [_delegate CJReadyToLiveOnClickBeginLiveButton];
    }
}

- (void)recordBtnOnClick:(id)sender{
    [sender setSelected:![sender isSelected]];
    self.isRecord = [sender isSelected];
}

- (void)agreenBtnOnClick:(id)sender{
    [sender setSelected:![sender isSelected]];
    self.isAgreen = [sender isSelected];
    if (_isAgreen){
        [self.beginToLiveBtn setBackgroundColor:[UIColor colorWithHex:0xdd4242]];
        [self.beginToLiveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [self.beginToLiveBtn setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        [self.beginToLiveBtn setTitleColor:[UIColor colorWithHex:0xdddddd] forState:UIControlStateNormal];
    }
}

- (void)ruleBtnOnClick:(id)sender{
    if ([_delegate respondsToSelector:@selector(CJReadyToLiveOnClickRuleButton)]){
        [_delegate CJReadyToLiveOnClickRuleButton];
    }
}

- (void)setImage:(UIImage *)image{
    [self.imageView setImage:image];
    if (image && self.addImageBtn){
        [self.addImageBtn removeFromSuperview];
        self.addImageBtn = nil;
        [self.changeImageBtn setHidden:false];
        _isChoosedImage = true;
    }
}

- (void)endEditing{
    [self.titleLabel resignFirstResponder];
}
@end
