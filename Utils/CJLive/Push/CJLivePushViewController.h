//
//  CJLivePushViewController.h
//  Weex
//
//  Created by 郭书智 on 2018/4/3.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <TXLivePush.h>
#import "CJLivePlayUserModel.h"

typedef void(^CJLivePushOnComplete)(id data);

/**
 推流模块主控制器,承载了渲染view,逻辑view,以及相关逻辑,同时也是SDK层事件通知的接收者
 */
@interface CJLivePushViewController : UIViewController

/**
 推流地址
 */
@property (nonatomic, copy) NSString *            rtmpUrl;


/**
 推流配置
 */
@property (nonatomic, strong) TXLivePushConfig *    txLivePushConfig;


/**
 推流实例
 */
@property (nonatomic, strong) TXLivePush *          txLivePublisher;


/**
 聊天界面
 */
@property (nonatomic, strong) UITableView *         messageView;


/**
 群聊ID
 */
@property (nonatomic, copy) NSString *              groupId;


/**
 标题
 */
@property (nonatomic, copy) NSString *              liveTitle;


/**
 封面
 */
@property (nonatomic, copy) NSString *              frontCover;


/**
 头像
 */
@property (nonatomic, copy) NSString *              headIcon;


/**
 主播信息
 */
@property (nonatomic, strong) CJLivePlayUserModel * anchor;


/**
 是否需要自定义设置
 */
@property (nonatomic, assign) BOOL                  isNativeConfig;


/**
 是否录制
 */
@property (nonatomic, assign) BOOL                  isRecord;



/**
 直播结束回调
 */
@property (nonatomic, strong) CJLivePushOnComplete  onComplete;
@end
