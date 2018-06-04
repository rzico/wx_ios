//
//  CJLivePlayModel.h
//  Weex
//
//  Created by 郭书智 on 2018/4/13.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "JSONModel.h"

@interface CJLivePlayModel : JSONModel

//follow = 0;
//frontcover = "http://cdn.rzico.com/upload/images/2018/04/13/4331361713DCA13CC099D416BC75CBFA.jpg";
//gift = 312;
//headpic = "http://wx.qlogo.cn/mmopen/vi_32/DYAIOgq83eqU0RbgHv1yOsl5FKpWkjmweIL0AOPTWDOQgpVOvMkvia2Kic4UqkW1sv3B3Nl8UtOObfoL4GweWicUA/0";
//hlsPlayUrl = "<null>";
//id = 111;
//likeCount = 0;
//liveId = 131;
//liveMemberId = 45;
//location = "<null>";
//nickname = "*";
//online = "<null>";
//playUrl = "rtmp://22303.liveplay.myqcloud.com/live/22303_10332";
//pushUrl = "rtmp://22303.livepush.myqcloud.com/live/22303_10332?bizid=22303&txSecret=f7e5e388ce60157675671a4b4503612b&txTime=5AD1AA70";
//status = "<null>";
//title = "Live Title";
//viewerCount = 35;

@property (nonatomic, assign) BOOL follow;
@property (nonatomic, copy) NSString *frontcover;
@property (nonatomic, assign) long gift;
@property (nonatomic, copy) NSString *headpic;
@property (nonatomic, copy) NSString *hlsPlayUrl;
@property (nonatomic, copy) NSString *Id;
@property (nonatomic, assign) long likeCount;
@property (nonatomic, assign) long liveId;
@property (nonatomic, assign) long liveMemberId;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *online;
@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, copy) NSString *pushUrl;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) long viewerCount;
@property (nonatomic, assign) long fans;

+ (instancetype)modelWithDictionary:(NSDictionary *)dic;
@end
