//
//  CJLiveMessageViewCell.m
//  Weex
//
//  Created by 郭书智 on 2018/4/7.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLiveMessageViewCell.h"

#define CJLiveMessageViewCellFont [UIFont systemFontOfSize:13]
#define CJLiveMessageViewLineSpace 5
#define CJLiveMessageBadgeWidth 15
#define CJLiveMessageNickNameColor 0x00ffff

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24);

@implementation CJLiveMessageViewCell{
//    UILabel *nickNameLbl;
    UILabel *contentLbl;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:NSStringFromClass([self class])];
    if (self){
        [self setupView];
    }
    return self;
}

- (void)setupView{
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor colorWithHex:0 alpha:0.1];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
//    nickNameLbl = [[UILabel alloc] init];
//    nickNameLbl.font = CJLiveMessageViewCellFont;
//    nickNameLbl.textColor = [UIColor blueColor];
//    nickNameLbl.numberOfLines = 0;
//    [self.contentView addSubview:nickNameLbl];
    
    
    contentLbl = [[UILabel alloc] init];
    contentLbl.font = CJLiveMessageViewCellFont;
    contentLbl.textColor = [UIColor colorWithHex:0xffd705];
    contentLbl.numberOfLines = 0;
    [contentLbl setClipsToBounds:true];
    [self.contentView addSubview:contentLbl];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:false animated:false];
}

+ (NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

- (void)setData:(CJLiveMessageModel *)data{
    _data = data;
    NSAttributedString *attributedString = [CJLiveMessageViewCell getAttributedStringWithData:data];
    contentLbl.attributedText = attributedString;
    contentLbl.frame = CGRectMake(5, 5, CJLiveMessageCellWidth, [CJLiveMessageViewCell getHeightWithAttributedString:attributedString]);
}


+ (NSAttributedString *)getAttributedStringWithData:(CJLiveMessageModel *)data{
    if (data.messageType == CJLiveMessageTypeTip){
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
        CGFloat width = 0;
        if (data.nickName){
            NSString *nickName = [[data.nickName replaceUnicode] stringByAppendingString:@"  "];
            NSAttributedString *nickNameAttributedString = [CJLiveMessageViewCell getTextAttribute:nickName color:[UIColor colorWithHex:CJLiveMessageNickNameColor] headIndent:0];
            [attributeStr appendAttributedString:nickNameAttributedString];
            width = [CJLiveMessageViewCell getWidthWithAttributedString:nickNameAttributedString];
        }
        NSString *message = [data.message replaceUnicode];
        [attributeStr appendAttributedString:[CJLiveMessageViewCell getTextAttribute:message color:[UIColor colorWithHex:0xffd705] headIndent:(!data.nickName ? 0 : width + 5)]];
        return attributeStr;
    }else if (data.messageType == CJLiveMessageTypeText){
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
        NSString *nickName = [[data.nickName replaceUnicode] stringByAppendingString:@":  "];
        NSString *message = [data.message replaceUnicode];
        CGFloat width = 0;
        if (data.VIP){
            NSString *VIP = [data.VIP stringByAppendingString:@"  "];
            NSAttributedString *VIPAttributeStr = [CJLiveMessageViewCell getTextAttribute:VIP color:[UIColor colorWithHex:0xf4d29a] headIndent:0];
            [attributeStr appendAttributedString:VIPAttributeStr];
            width = [CJLiveMessageViewCell getWidthWithAttributedString:VIPAttributeStr];
        }
        NSAttributedString *nickNameAttributedString = [CJLiveMessageViewCell getTextAttribute:nickName color:[UIColor colorWithHex:CJLiveMessageNickNameColor] headIndent:0];
        [attributeStr appendAttributedString:nickNameAttributedString];
        width += [CJLiveMessageViewCell getWidthWithAttributedString:nickNameAttributedString];
        [attributeStr appendAttributedString:[CJLiveMessageViewCell getTextAttribute:message color:[UIColor colorWithHex:0xffd705] headIndent:width + 5]];
        return attributeStr;
    }else if (data.messageType == CJLiveMessageTypeGift){
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
        NSString *nickName = [[data.nickName replaceUnicode] stringByAppendingString:@"  "];
//        NSString *message = [NSString stringWithFormat:@"打赏给主播%@ X%zd", [data.message replaceUnicode],data.count];
        NSString *message = [NSString stringWithFormat:@"给主播%@", [data.message replaceUnicode]];
        NSAttributedString *nickNameAttributedString = [CJLiveMessageViewCell getTextAttribute:nickName color:[UIColor colorWithHex:CJLiveMessageNickNameColor] headIndent:0];
        [attributeStr appendAttributedString:nickNameAttributedString];
        CGFloat width = [CJLiveMessageViewCell getWidthWithAttributedString:nickNameAttributedString];
        [attributeStr appendAttributedString:[CJLiveMessageViewCell getTextAttribute:message color:[UIColor redColor] headIndent:width + 5]];
        return attributeStr;
    }else if (data.messageType == CJLiveMessageTypeEnter){
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
        NSString *nickName = [[data.nickName replaceUnicode] stringByAppendingString:@"  "];
        NSString *message = @"加入房间";
        NSAttributedString *nickNameAttributedString = [CJLiveMessageViewCell getTextAttribute:nickName color:[UIColor colorWithHex:CJLiveMessageNickNameColor] headIndent:0];
        [attributeStr appendAttributedString:nickNameAttributedString];
        CGFloat width = [CJLiveMessageViewCell getWidthWithAttributedString:nickNameAttributedString];
        [attributeStr appendAttributedString:[CJLiveMessageViewCell getTextAttribute:message color:[UIColor colorWithHex:0xffd705] headIndent:width + 5]];
        return attributeStr;
    }else{
        return nil;
    }
}

+ (CGFloat)getWidthWithAttributedString:(NSAttributedString *)str{
    return [str boundingRectWithSize:CGSizeMake(CJLiveMessageCellWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.width;
}

+ (CGFloat)getHeightWithAttributedString:(NSAttributedString *)str{
    return [str boundingRectWithSize:CGSizeMake(CJLiveMessageCellWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size.height;
}

+ (CGFloat)getHeightWithData:(CJLiveMessageModel *)data{
    NSAttributedString *str = [self getAttributedStringWithData:data];
    return [self getHeightWithAttributedString:str];
}

+ (NSAttributedString *)getTextAttribute:(NSString *)text color:(UIColor *)color headIndent:(CGFloat)headIndent{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:CJLiveMessageViewLineSpace];
    [style setAlignment:NSTextAlignmentLeft];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    if (headIndent > 0){
        [style setFirstLineHeadIndent:headIndent];
    }
    NSDictionary *dic = @{NSFontAttributeName:CJLiveMessageViewCellFont, NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:color};
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:text attributes:dic];
    return attributeStr;
}
@end
