//
//  CJTextCell.h
//  Weex
//
//  Created by 郭书智 on 2018/4/4.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJTextCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;
- (void)setSelected:(BOOL)selected;
+ (NSString *)reuseIdentifier;

@end
