//
//  PresentModel.h
//  BaoUU
//
//  Created by 吴小虑 on 2017/10/27.
//  Copyright © 2017年 Mr.Dai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PresentModelAble.h"

@interface PresentModel : NSObject<PresentModelAble>

@property (copy, nonatomic) NSString *sender;
@property (copy, nonatomic) NSString *giftName;
@property (copy, nonatomic) NSString *icon;
@property (copy, nonatomic) NSString *giftImageName;
@property (assign, nonatomic) NSInteger giftNumber;

+ (instancetype)modelWithSender:(NSString *)sender
                       giftName:(NSString *)giftName
                           icon:(NSString *)icon
                  giftImageName:(NSString *)giftImageName;

@end
