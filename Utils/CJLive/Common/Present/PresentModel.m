//
//  PresentModel.m
//  BaoUU
//
//  Created by 吴小虑 on 2017/10/27.
//  Copyright © 2017年 Mr.Dai. All rights reserved.
//

#import "PresentModel.h"

@implementation PresentModel

+ (instancetype)modelWithSender:(NSString *)sender giftName:(NSString *)giftName icon:(NSString *)icon giftImageName:(NSString *)giftImageName
{
    PresentModel *model = [[PresentModel alloc] init];
    model.sender        = sender;
    model.giftName      = giftName;
    model.icon          = icon;
    model.giftImageName = giftImageName;
    return model;
}

@end

