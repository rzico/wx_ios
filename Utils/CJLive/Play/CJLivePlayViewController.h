//
//  CJLivePlayViewController.h
//  Weex
//
//  Created by 郭书智 on 2018/4/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CJLivePlayModel.h"
#import "CJLivePlayUserModel.h"

/**
 播放模块主控制器
 */
@interface CJLivePlayViewController : UIViewController

/**
 群组Id
 */
@property NSString *            groupId;


/**
 自己信息
 */
@property (nonatomic, strong)   CJLivePlayUserModel *user;

/**
 主播信息
 */
@property (nonatomic, strong)   CJLivePlayModel *anchor;
@end
