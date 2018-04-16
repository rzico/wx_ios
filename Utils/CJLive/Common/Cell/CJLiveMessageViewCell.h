//
//  CJLiveMessageViewCell.h
//  Weex
//
//  Created by 郭书智 on 2018/4/7.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJLiveMessageModel.h"

#define CJLiveMessageCellWidth ([UIScreen getWidth] * 0.7)

@interface CJLiveMessageViewCell : UITableViewCell

@property (nonatomic, strong) CJLiveMessageModel *data;

@property (nonatomic, assign) CGFloat cellHeight;

+ (NSString *)reuseIdentifier;

+ (CGFloat)getHeightWithData:(CJLiveMessageModel *)data;
@end
