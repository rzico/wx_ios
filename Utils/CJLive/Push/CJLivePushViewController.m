//
//  CJLivePushViewController.m
//  Weex
//
//  Created by 郭书智 on 2018/4/3.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePushViewController.h"
#import <sys/types.h>
#import <sys/sysctl.h>

#import <TZImagePickerController.h>
#import "CJAliOSSManager.h"

#import "CJWeexViewController.h"
#import <WXRootViewController.h>

#import "CJReadyToLiveView.h"
#import "CJLivePushHeadView.h"
#import "CJAudienceView.h"
#import "CJLivePushBottomView.h"
#import "CJLiveBeautySettingPanel.h"
#import "CJYinpiaoView.h"

#import "CJLiveProtocolViewController.h"


#import "CJLiveMessageViewCell.h"


#import "PresentModel.h"
#import "OLImageView.h"
#import "OLImage.h"
#import "PresentView.h"
#import "CustonCell.h"
#import "LiveGiftView.h"


#import "FriendshipManager.h"

#import <OCBarrage.h>

#import "CJGameViewController.h"
@interface CJLivePushViewController ()<TXLivePushListener, CJLivePushBottomViewDelegate, CJReadyToLiveDelegate, CJLiveBeautySettingPanelDelegate, CJAudienceViewDelegate, UITableViewDelegate, UITableViewDataSource, PresentViewDelegate>{
    NSTimeInterval  _dlTime;
    NSLock          *_dlLock;
}

@property (nonatomic, strong) CJReadyToLiveView         *readyToLiveView;
@property (nonatomic, strong) CJLivePushHeadView        *headView;
@property (nonatomic, strong) CJAudienceView            *audienceView;
@property (nonatomic, strong) CJLivePushBottomView      *bottomView;
@property (nonatomic, strong) CJYinpiaoView             *yinpiaoView;

@property (nonatomic, strong) CJLiveBeautySettingPanel  *beautyPanel;



@property (nonatomic, strong) NSMutableArray<CJLiveMessageModel *>            *messageList;


@property (nonatomic, strong) PresentView               *presentView;
@property (nonatomic, assign) NSInteger                 currentGiftId;
@property (nonatomic, copy)   NSString                  *currentGiftSernderName;
@property (nonatomic, assign) NSInteger                 number;
@property (nonatomic, assign) BOOL                      isShowGif;
@property (nonatomic, strong) OLImageView               *Aimv;
@property (nonatomic, weak)   NSTimer                   *giftTimer;
@property (nonatomic, weak)   NSTimer                   *audienceTimer;
@property (nonatomic, weak)   NSTimer                   *timeLabelTimer;
@property (nonatomic, assign) int                       timeCount;

@property (nonatomic, strong) UILabel                   *timeLabel;

@property (nonatomic, strong) OCBarrageManager          *barrageManager;

@property (nonatomic, strong) CJGameViewController      *gameVC;
@end

@implementation CJLivePushViewController{
    BOOL        _camera_switch;
    BOOL        _torch_switch;
    
    float       _beauty_level;
    float       _whitening_level;
    float       _eye_level;
    float       _face_level;
    
    UIView      *_videoParentView;
    
    BOOL        _isPreviewing;
    
    
    BOOL _appIsInterrupt;
    BOOL _appIsInActive;
    BOOL _appIsBackground;
    
    
    long likeCount;
    long follow;
    long viewerCount;
    long yinpiao;
    
    NSString *gameUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self createSubViews];
    [self initLivePublisher];
    
    //键盘出现事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    //键盘消失事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterruption:) name:AVAudioSessionInterruptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitLive) name:UIApplicationWillTerminateNotification object:nil];
    
    CJRegisterNotification(@selector(onNewMessage:), CJNOTIFICATION_GROUP_MESSAGE);
    CJRegisterNotification(@selector(onLoadGame:), CJNOTIFICATION_LIVE_LOADGAME);
    
    _messageList = [[NSMutableArray alloc] init];
}

- (void)handleInterruption:(NSNotification *)notification {
    AVAudioSessionInterruptionType type = [notification.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (AVAudioSessionInterruptionTypeBegan == type) {
        _appIsInterrupt = YES;
        [_txLivePublisher pausePush];
        NSLog(@"AVAudioSessionInterruptionTypeBegan");
    }
    if (AVAudioSessionInterruptionTypeEnded == type) {
        _appIsInterrupt = NO;
        if (!_appIsBackground && !_appIsInActive && !_appIsInterrupt)
            [_txLivePublisher resumePush];
        NSLog(@"AVAudioSessionInterruptionTypeEnd");
        
    }
}

- (void)releaseObjects{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.view removeSubviews];
    [self setRtmpUrl:nil];
    [self setTxLivePushConfig:nil];
    [self setTxLivePublisher:nil];
    [self setMessageView:nil];
    [self setGroupId:nil];
    [self setLiveTitle:nil];
    [self setHeadIcon:nil];
    [self setReadyToLiveView:nil];
    [self setHeadView:nil];
    [self setAudienceView:nil];
    [self setBottomView:nil];
    [self setBeautyPanel:nil];
    [self setMessageList:nil];
    [self setPresentView:nil];
    [self setAimv:nil];
    [self setGiftTimer:nil];
    [self setAudienceTimer:nil];
    [self setTimeLabelTimer:nil];
    [self setTimeLabel:nil];
    [self setYinpiaoView:nil];
}

- (void)dealloc{
    NSLog(@"Live Room Dealloc");
}

- (void)onAppWillResignActive:(NSNotification *)notification {
    _appIsInActive = YES;
    [_txLivePublisher pausePush];
}

- (void)onAppDidBecomeActive:(NSNotification *)notification {
    _appIsInActive = NO;
    if (!_appIsBackground && !_appIsInActive && !_appIsInterrupt)
        [_txLivePublisher resumePush];
}

- (void)onAppDidEnterBackGround:(NSNotification *)notification {
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        
    }];
    
    _appIsBackground = YES;
    [_txLivePublisher pausePush];
    
}

- (void)onAppWillEnterForeground:(NSNotification *)notification {
    _appIsBackground = NO;
    if (!_appIsBackground && !_appIsInActive && !_appIsInterrupt) [_txLivePublisher resumePush];
}

- (void)sendMsg:(CJLiveMessageType)type Id:(NSString *)Id nickName:(NSString *)nickName message:(NSString *)message{
    TIMMessage *msg = [[TIMMessage alloc] init];
    
    TIMCustomElem *custElem = [[TIMCustomElem alloc] init];
    TIMTextElem *textElem = [[TIMTextElem alloc] init];
    
    NSError *error = nil;
    
    NSData *data = nil;
    if (type == CJLiveMessageTypeGag){
        int time = [message intValue];
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomGagMsg",
                                                         @"data":@{@"cmd":@"CustomGagMsg",@"nickName":nickName,@"headPic":@"",@"id":@"0",@"imid":Id,@"text":time > 1 ? CJLiveMessageGagString : CJLiveMessageUnGagString,@"time":message}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
        
        textElem.text = time > 1 ? CJLiveMessageGagString : CJLiveMessageUnGagString;
        [msg addElem:textElem];
    }else if (type == CJLiveMessageTypeKick){
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomKickMsg",
                                                         @"data":@{@"cmd":@"CustomKickMsg",@"nickName":nickName,@"headPic":@"",@"id":@"0",@"imid":Id,@"text":CJLiveMessageKickString,@"time":@""}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
        
        textElem.text = CJLiveMessageKickString;
        [msg addElem:textElem];
    }else if (type == CJLiveMessageTypeGame){
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomGameMsg",
                                                         @"data":@{@"cmd":@"CustomGameMsg",@"text":message,@"type":Id}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
        
        textElem.text = message;
        [msg addElem:textElem];
    }
    
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:self.groupId];
    [conv sendMessage:msg succ:^{
        if (type == CJLiveMessageTypeGag){
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = nickName;
            
            int time = [message intValue];
            
            model.messageType = CJLiveMessageTypeTip;
            model.message = time > 1 ? CJLiveMessageGagString : CJLiveMessageUnGagString;
            
            [self appendMessage:model];
        }else if (type == CJLiveMessageTypeKick){
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = nickName;
            model.messageType = CJLiveMessageTypeTip;
            model.message = CJLiveMessageKickString;
            
            [self appendMessage:model];
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"send msg error%d,%@",code,msg);
    }];
}

- (void)gagUser:(NSString *)Id time:(int)time{
    [[TIMGroupManager sharedInstance] modifyGroupMemberInfoSetSilence:self.groupId user:Id stime:time > 1 ? time : 0 succ:^{
        
    } fail:^(int code, NSString *msg) {
        
    }];
}

- (void)kickUser:(NSString *)Id{
    
}

- (void)onLoadGame:(NSNotification *)notification{
    _appIsInterrupt = NO;
    [_txLivePublisher resumePush];
    NSString *url = [notification.userInfo objectForKey:@"url"];
    [self loadGame:url];
}

- (void)loadGame:(NSString *)url{
    gameUrl = url;
    
    [self sendMsg:CJLiveMessageTypeGame Id:@"load" nickName:nil message:url];
    
    
    [CJNetworkManager GetHttp:[NSString stringWithFormat:@"%@%@",WXCONFIG_INTERFACE_PATH,url] Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
            self.gameVC = [[CJGameViewController alloc] initWithType:CJGameTypeHalfView];
            [self addChild:self.gameVC inRect:CGRectMake(0, 0, [UIScreen getWidth], [UIScreen getWidth] * 0.5625)];
            [self.view addSubview:self.gameVC.view];
            self.gameVC.view.frame = CGRectMake(0, [UIDevice isIphoneX] ? [UIScreen getHeight] - [UIScreen getWidth] * 0.5625 - 34 : [UIScreen getHeight] - [UIScreen getWidth] * 0.5625, [UIScreen getWidth], [UIDevice isIphoneX] ? [UIScreen getWidth] * 0.5625 + 34 : [UIScreen getWidth] * 0.5625);
            [self.gameVC didMoveToParentViewController:self];
            NSDictionary *data = [responseObject objectForKey:@"data"];
            [self.bottomView setGameBtnState];
            [self.gameVC loadWithUrl:[data objectForKey:@"url"] video:[data objectForKey:@"video"] method:@"GET" callback:^{
                [self.bottomView setGameBtnState];
                self->gameUrl = nil;
                [self sendMsg:CJLiveMessageTypeGame Id:@"exit" nickName:nil message:url];
                [self resetSubViews];
                self.gameVC = nil;
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self setSubViews];
            });
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络不稳定，请稍后再试"];
        }
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"网络不稳定，请稍后再试"];
    }];
}

- (void)setSubViews{
    [self.bottomView layoutAbove:self.gameVC.view margin:5.0];
    [self.beautyPanel layoutAbove:self.gameVC.view];
    [self.messageView layoutAbove:self.bottomView margin:10];
    [self.presentView layoutAbove:self.messageView];
    [self.barrageManager.renderView sizeWith:CGSizeMake([UIScreen getWidth], self.messageView.y - 40 - self.headView.y - self.headView.height)];
    [self.barrageManager.renderView layoutAbove:self.messageView margin:20];
//    NSUInteger beautyPanelHeight = [CJLiveBeautySettingPanel getHeight];
//    self.beautyPanel.frame = CGRectMake(0, self.view.height - beautyPanelHeight, [UIScreen getWidth], beautyPanelHeight);
}

- (void)resetSubViews{
    [self.bottomView alignParentBottomWithMargin:20.0];
    NSUInteger beautyPanelHeight = [CJLiveBeautySettingPanel getHeight];
    self.beautyPanel.frame = CGRectMake(0, self.view.height - beautyPanelHeight, [UIScreen getWidth], beautyPanelHeight);
    [self.messageView layoutAbove:self.bottomView margin:10];
    [self.presentView layoutAbove:self.messageView];
    [self.barrageManager.renderView sizeWith:CGSizeMake([UIScreen getWidth], self.messageView.y - 40 - self.headView.y - self.headView.height)];
    [self.barrageManager.renderView layoutAbove:self.messageView margin:20];
}

- (void)onNewMessage:(NSNotification *)notification{
    NSLog(@"%@",notification.userInfo);
    NSString *type = [notification.userInfo objectForKey:@"type"];
    if ([type equalsString:@"gag"]){//禁言
        CJLiveMessageModel *data = [[CJLiveMessageModel alloc] init];
        data.messageType = CJLiveMessageTypeTip;
        
        NSString *gagInfo = [notification.userInfo objectForKey:@"info"];
        NSArray *arr = [gagInfo componentsSeparatedByString:@"|"];
        NSString *Id = arr[0];
        NSString *nickName = arr[1];
        data.nickName = nickName;
        int time = [arr[2] intValue];
        [self sendMsg:CJLiveMessageTypeGag Id:Id nickName:nickName message:arr[2]];
        [self gagUser:Id time:time];
    }else if ([type equalsString:@"kick"]){
        NSDictionary *kickInfo = [notification.userInfo objectForKey:@"data"];
        [self sendMsg:CJLiveMessageTypeKick Id:[kickInfo objectForKey:@"id"] nickName:[kickInfo objectForKey:@"nickName"] message:nil];
    }
    else if ([type equalsString:@"message"]){
        TIMMessage *msg = [notification.userInfo objectForKey:@"msg"];
        if ([[[msg getConversation] getReceiver] equalsString:self.groupId]){
            CJLiveMessageModel *data = [[CJLiveMessageModel alloc] init];
            for (int i = 0; i < msg.elemCount; i ++){
                TIMElem *elem = [msg getElem:i];
                if ([elem isKindOfClass:[TIMCustomElem class]]){
                    //自定义消息
                    TIMCustomElem *customElem = (TIMCustomElem *)elem;
                    NSDictionary *dic = [NSDictionary dictionaryWithJsonData:[customElem data]];
                    NSLog(@"custom=%@",dic);
                    if ([dic objectForKey:@"data"]){
                        NSDictionary *elemData = [dic objectForKey:@"data"];
                        data.nickName = [elemData objectForKey:@"nickName"];
                        data.icon = [elemData objectForKey:@"headPic"];
                        data.Id = [elemData objectForKey:@"id"];
                        data.userId = [elemData objectForKey:@"imid"];
                        data.VIP = [elemData objectForKey:@"vip"];
                        if ([[dic objectForKey:@"cmd"] equalsString:@"CustomGifMsg"]){
                            //礼物消息
                            if (i+1 < msg.elemCount){
                                TIMElem *next = [msg getElem:i+1];
                                if ([next isKindOfClass:[TIMTextElem class]]){
                                    data.messageType = CJLiveMessageTypeGift;
                                    data.message = [(TIMTextElem *)next text];
                                    [self onreceiveGift:data];
                                    break;
                                }
                            }
                        }else if ([[dic objectForKey:@"cmd"] equalsString:@"CustomTextMsg"]){
                            if (i+1 < msg.elemCount){
                                TIMElem *next = [msg getElem:i+1];
                                if ([next isKindOfClass:[TIMTextElem class]]){
                                    NSString *text = [(TIMTextElem *)next text];
                                    data.message = text;
                                    if ([text equalsString:@"加入房间"]){
                                        data.messageType = CJLiveMessageTypeEnter;
                                        [self.audienceView setAudience:++viewerCount];
                                        
                                        if (gameUrl != nil){
                                            [self sendMsg:CJLiveMessageTypeGame Id:@"load" nickName:nil message:gameUrl];
                                        }
                                        
                                        
                                    }else{
                                        data.messageType = CJLiveMessageTypeText;
                                    }
                                    [self appendMessage:data];
                                    break;
                                }
                            }
                        }else if ([[dic objectForKey:@"cmd"] equalsString:@"CustomGagMsg"]){
                            if (i+1 < msg.elemCount){
                                NSString *time = [elemData objectForKey:@"time"];
                                [self gagUser:data.userId time:[time intValue]];
                                data.messageType = CJLiveMessageTypeTip;
                                if ([time intValue] > 1){
                                    data.message = CJLiveMessageGagString;
                                }else{
                                    data.message = CJLiveMessageUnGagString;
                                }
                                [self appendMessage:data];
                                break;
                            }
                        }else if ([[dic objectForKey:@"cmd"] equalsString:@"CustomKickMsg"]){
                            if (i+1 < msg.elemCount){
                                [self kickUser:data.userId];
                                data.messageType = CJLiveMessageTypeTip;
                                data.message = CJLiveMessageKickString;
                                [self appendMessage:data];
                                break;
                            }
                        }else if ([[dic objectForKey:@"cmd"] equalsString:@"CustomFollowMsg"]){
                            if (i+1 < msg.elemCount){
                                [self kickUser:data.userId];
                                data.messageType = CJLiveMessageTypeTip;
                                data.message = [elemData objectForKey:@"text"];
                                if ([data.message containsString:@"取消"]){
                                    self.anchor.fans --;
                                }else{
                                    self.anchor.fans ++;
                                }
                                [self.headView setFansCount:self.anchor.fans];
                                [self appendMessage:data];
                                break;
                            }
                        }else if ([[dic objectForKey:@"cmd"] equalsString:@"CustomBarrageMsg"]){
                            if (i+1 < msg.elemCount){
                                data.messageType = CJLiveMessageTypeTip;
                                data.message = [elemData objectForKey:@"text"];
                                [self appendMessage:data];
                                [self appendBarrageMessage:data.nickName message:data.message];
                                break;
                            }
                        }
                        
                    }
                }else if ([elem isKindOfClass:[TIMTextElem class]]){
                    data.message = [(TIMTextElem *)elem text];;
                    data.messageType = CJLiveMessageTypeTip;
                    [self appendMessage:data];
                    break;
                }
            }
        }
    }
}

- (void)appendBarrageMessage:(NSString *)nickName message:(NSString *)message{
    OCBarrageTextDescriptor *textDescriptor = [[OCBarrageTextDescriptor alloc] init];
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] init];
    nickName = [[nickName replaceUnicode] stringByAppendingString:@": "];
    message = [message replaceUnicode];
    
    NSDictionary *nickNameDic = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName:[UIColor colorWithHex:0x00ffff]};
    NSAttributedString *nickNameAttributedString = [[NSAttributedString alloc] initWithString:nickName attributes:nickNameDic];
    [attributeStr appendAttributedString:nickNameAttributedString];
    
    NSDictionary *messageDic = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:17], NSForegroundColorAttributeName:[UIColor colorWithHex:0xffd705]};
    NSAttributedString *messageAttributedString = [[NSAttributedString alloc] initWithString:message attributes:messageDic];
    [attributeStr appendAttributedString:messageAttributedString];
    
    textDescriptor.attributedText = attributeStr;
    textDescriptor.strokeColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    textDescriptor.strokeWidth = -1;
    textDescriptor.animationDuration = arc4random()%5 + 5;
    textDescriptor.barrageCellClass = [OCBarrageTextCell class];
    
    [self.barrageManager renderBarrageDescriptor:textDescriptor];
}

- (void)initLivePublisher{
    _txLivePushConfig = [[TXLivePushConfig alloc] init];
    _txLivePushConfig.frontCamera = true;
    
    //由于iphone4s及以下机型前置摄像头不支持540p，故iphone4s及以下采用360p
    _txLivePushConfig.videoResolution = [self isSuitableMachine:5] ? VIDEO_RESOLUTION_TYPE_540_960 : VIDEO_RESOLUTION_TYPE_360_640;
    //码率自适应
    _txLivePushConfig.enableAutoBitrate = false;
    _txLivePushConfig.videoBitratePIN = 1000;
    //硬件加速
    _txLivePushConfig.enableHWAcceleration = true;
    
    //后台推流
    _txLivePushConfig.pauseFps = 10;
    _txLivePushConfig.pauseTime = 300;
    _txLivePushConfig.pauseImg = [UIImage imageNamed:@"pause_publish.jpg"];
    
    //回声消除
    _txLivePushConfig.enableAEC = true;
    
    //耳返
    _txLivePushConfig.enableAudioPreview = true;


    //水印
//    _txLivePushConfig.watermark = [UIImage imageNamed:@"BaoUULivelogo"];
//    _txLivePushConfig.watermarkNormalization = CGRectMake(0.1, 0.1, 0.1, 0);

    
    _txLivePublisher = [[TXLivePush alloc] initWithConfig:_txLivePushConfig];
    
    
    _camera_switch = false;
    _torch_switch = false;
    _beauty_level = 9;
    _whitening_level = 3;
    [_txLivePublisher setBeautyStyle:BEAUTY_STYLE_SMOOTH beautyLevel:_beauty_level whitenessLevel:_whitening_level ruddinessLevel:0];
    
    
    if (!TARGET_IPHONE_SIMULATOR){
        __weak typeof(self) weakSelf = self;
        [weakSelf startPreview];
    }
    
    
}

- (void)createSubViews{
    //视频画面的父view
    _videoParentView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_videoParentView];
    
    if (self.isNativeConfig){
        self.readyToLiveView = [[CJReadyToLiveView alloc] initWithFrame:CGRectMake(0, 0, 280, 400)];
        self.readyToLiveView.backgroundColor = [UIColor whiteColor];
        self.readyToLiveView.center = self.view.center;
        self.readyToLiveView.layer.cornerRadius = 10.0;
        self.readyToLiveView.clipsToBounds = true;
        self.readyToLiveView.delegate = self;
        [self.view addSubview:_readyToLiveView];
        
        self.readyToLiveView.kbHideFrame = self.readyToLiveView.frame;
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setBeginToLive];
        });
    }
    
    
    
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"live-out"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(exitLive) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    
    [closeBtn sizeWith:CGSizeMake(54, 30)];
    [closeBtn alignParentRight];
    [closeBtn alignParentTopWithMargin:[UIScreen getStatusBarHeight] + 10];
    
    self.headView = [[CJLivePushHeadView alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    [self.headView.iconView setBackgroundColor:[UIColor redColor]];
    
    [self.view addSubview:self.headView];
    
    [self.headView alignParentLeftWithMargin:10.0];
    [self.headView alignTop:closeBtn];
    
    
    self.audienceView = [[CJAudienceView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    self.audienceView.delegate = self;
    [self.view addSubview:self.audienceView];
    
    [self.audienceView alignVerticalCenterOf:closeBtn];
    [self.audienceView layoutToLeftOf:closeBtn margin:10.0];
    
    
    self.yinpiaoView = [[CJYinpiaoView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [self.view addSubview:self.yinpiaoView];
    
    [self.yinpiaoView alignLeft:self.headView];
    [self.yinpiaoView layoutBelow:self.headView margin:10];
    
    
    self.bottomView = [[CJLivePushBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen getWidth], 40)];
    [self.view addSubview:self.bottomView];
    self.bottomView.delegate = self;
    [self.bottomView alignParentBottomWithMargin:20.0];
    
    self.bottomView.toggleTorchBtn.hidden = true;
    [self.bottomView setUserInteractionEnabled:false];
    
    NSUInteger beautyPanelHeight = [CJLiveBeautySettingPanel getHeight];
    self.beautyPanel = [[CJLiveBeautySettingPanel alloc] initWithFrame:CGRectMake(0, self.view.height - beautyPanelHeight, [UIScreen getWidth], beautyPanelHeight)];
    self.beautyPanel.hidden = true;
    self.beautyPanel.delegate = self;
    [self.beautyPanel resetValues];
    [self.view addSubview:self.beautyPanel];
    
    
    self.timeLabel = [[UILabel alloc] init];
    [self.timeLabel setTextAlignment:NSTextAlignmentRight];
    [self.timeLabel setFont:[UIFont systemFontOfSize:12]];
    [self.timeLabel setTextColor:[UIColor colorWithHex:0xdd4242]];
    [self.view addSubview:self.timeLabel];
    
    
    [self.timeLabel setText:@"00:00"];
    
    [self.timeLabel sizeWith:CGSizeMake(100, 13)];
    [self.timeLabel layoutBelow:self.headView margin:10];
    [self.timeLabel alignParentRightWithMargin:5];
    
    self.timeCount = 0;
    
    
    [self.headView setFansCount:self.anchor.fans];
    [self.headView setNickName:self.anchor.nickName];
}

- (void)creatTimeLabelTimer{
    self.timeLabelTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showLiveTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.timeLabelTimer forMode:NSDefaultRunLoopMode];
}

- (void)destroyTimeLabelTimer{
    if (self.timeLabelTimer) {
        [self.timeLabelTimer invalidate];
        self.timeLabelTimer = nil;
    }
}

- (void)showLiveTime{
    self.timeCount++;
    
    self.timeLabel.text = [NSString stringWithFormat:@"直播中:%02d:%02d",self.timeCount/60,self.timeCount%60];
}

- (BOOL)startPreview{
    AVAuthorizationStatus statusVideo = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (statusVideo == AVAuthorizationStatusDenied) {
        //        [self toastTip:@"获取摄像头权限失败，请前往隐私-相机设置里面打开应用权限"];
        //        [_logicView closeVCWithError:kErrorMsgOpenCameraFailed Alert:YES Result:NO];
        return NO;
    }
    
    //是否有麦克风权限
    AVAuthorizationStatus statusAudio = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (statusAudio == AVAuthorizationStatusDenied) {
        //        [self toastTip:@"获取麦克风权限失败，请前往隐私-麦克风设置里面打开应用权限"];
        //        [_logicView closeVCWithError:kErrorMsgOpenMicFailed Alert:YES Result:NO];
        return NO;
    }
    
    if(_txLivePublisher != nil)
    {
        _txLivePublisher.delegate = self;
        [self.txLivePublisher setVideoQuality:VIDEO_QUALITY_HIGH_DEFINITION adjustBitrate:NO adjustResolution:NO];
        if (!_isPreviewing) {
            [_txLivePublisher startPreview:_videoParentView];
            _isPreviewing = YES;
        }
        
        [_txLivePublisher setEyeScaleLevel:_eye_level];
        [_txLivePublisher setFaceScaleLevel:_face_level];
        [_txLivePublisher setMirror:false];
        [[UIApplication sharedApplication] setIdleTimerDisabled:false];
    }
    return YES;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.headView.iconView sd_setImageWithURL:[NSURL URLWithString:self.headIcon]];
}

#pragma mark - Message View
- (void)addMessageView{
    if (_messageView == nil){
        _messageView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _messageView.delegate = self;
        _messageView.dataSource = self;
        _messageView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _messageView.backgroundColor = [UIColor clearColor];
//        [_messageView registerClass:[CJLiveMessageViewCell class] forCellReuseIdentifier:[CJLiveMessageViewCell reuseIdentifier]];
        [_messageView setShowsVerticalScrollIndicator:false];
        [_messageView setShowsHorizontalScrollIndicator:false];
        [self.view addSubview:_messageView];
        
        [_messageView sizeWith:CGSizeMake(CJLiveMessageCellWidth + 10, 200)];
        [_messageView alignParentLeftWithMargin:10];
        [_messageView layoutAbove:_bottomView margin:10];
    }
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    CGFloat height = keyboardRect.size.height;
    // 键盘动画时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.readyToLiveView && ![self.readyToLiveView isHidden]){
        CGRect frame = _readyToLiveView.kbHideFrame;
        frame.origin.y = ([[UIScreen mainScreen] bounds].size.height - height) - _readyToLiveView.frame.size.height;
        //视图上浮
        [UIView animateWithDuration:duration animations:^{
            self.readyToLiveView.frame = frame;
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tap];
}

- (void)hideKeyboard:(UITapGestureRecognizer *)tap{
    [self.view endEditing:true];
    [self.view removeGestureRecognizer:tap];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    // 键盘动画时间
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (self.readyToLiveView && ![self.readyToLiveView isHidden]){
        if (self.readyToLiveView && ![self.readyToLiveView isHidden]){
            //视图下沉恢复原状
            [UIView animateWithDuration:duration animations:^{
                self.readyToLiveView.frame = self.readyToLiveView.kbHideFrame;
            }];
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (!self.beautyPanel.isHidden){
        for (UITouch *touch in touches){
            if (![touch.view.class isKindOfClass:[self.beautyPanel class]]){
                self.bottomView.hidden = false;
                self.beautyPanel.hidden = true;
                self.messageView.hidden = false;
                break;
            }
        }
    }
    
//    [self praiseHeart];
    
    
    
//    [self showGifWebView:@"gift-666" giftName:@"666" name:@"sender" headUrl:@"https://www.baidu.com/s?tn=baidu&rsv_idx=1&wd=%E4%BA%9A%E7%89%B9%E5%85%B0%E8%92%82%E6%96%AF%E7%AC%AC%E4%B8%80%E5%AD%A3&rsv_cq=%E7%BE%8E%E5%89%A7&rsv_dl=0_right_recom_21121&euri=3bc0794e54b746d4853e77217a79bc46" giftID:1 giftSmallName:@"gift-666" isSelf:false];
    
//    TIMConversation *grp = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:self.groupId];
//
//    TIMMessage *message = [[TIMMessage alloc] init];
//    TIMTextElem *text_elem = [[TIMTextElem alloc] init];
//    [text_elem setText:@"this is a text message"];
//    [message addElem:text_elem];
//
//    [grp sendMessage:message succ:^{
//        NSLog(@"SendMsg Succ");
//    } fail:^(int code, NSString *msg) {
//        NSLog(@"SendMsg Failed:%d->%@", code, msg);
//    }];
}




#pragma mark - ReadyToLive Delegate
- (void)CJReadyToLiveOnClickChangeImageButton{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowCrop = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    //是否允许拍照
    imagePickerVc.allowTakePicture = YES;
    //照片排序
    imagePickerVc.sortAscendingByModificationDate = NO;
    
    imagePickerVc.isStatusBarDefault = YES;
    
    imagePickerVc.allowPickingOriginalPhoto = NO;
    
    imagePickerVc.isSelectOriginalPhoto = NO;
    
    imagePickerVc.naviBgColor = [UIColor colorWithHex:UINavigationBarColor];
    
    imagePickerVc.naviTitleColor = [UIColor colorWithHex:UINavigationBarColor];
    
    imagePickerVc.cropRect = CGRectMake(0, ([UIScreen getHeight] - [UIScreen getWidth] * 0.8) * 0.5, [UIScreen getWidth], [UIScreen getWidth] * 0.8);
    
    
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        [self.readyToLiveView setImage:[photos firstObject]];
    }];
    
    [self presentViewController:imagePickerVc animated:true completion:nil];
}

- (void)CJReadyToLiveOnClickRuleButton{
    CJLiveProtocolViewController *liveProtocolVC = [[CJLiveProtocolViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:liveProtocolVC];
    [self presentViewController:nav animated:true completion:nil];
}

- (void)CJReadyToLiveOnClickBeginLiveButton{
#ifdef DEBUG
    self.readyToLiveView.titleLabel.text = @"Live Title";
    self.readyToLiveView.isChoosedImage = true;
    self.readyToLiveView.imageView.image = [UIImage imageNamed:@"pause_publish.jpg"];
    self.readyToLiveView.isAgreen = true;
#endif
    
    
    
    if (!self.readyToLiveView.isAgreen){
        [SVProgressHUD showErrorWithStatus:@"同意《泥炭直播管理条例》后才能开始直播"];
        return;
    }
    if (!self.readyToLiveView.isChoosedImage){
        [SVProgressHUD showErrorWithStatus:@"请选择直播封面"];
        return;
    }
    if (self.readyToLiveView.titleLabel.text.length == 0){
        [SVProgressHUD showErrorWithStatus:@"请输入直播标题"];
        return;
    }
    if (self.readyToLiveView.titleLabel.text.length > 20){
        [SVProgressHUD showErrorWithStatus:@"直播标题过长，请重新输入"];
        return;
    }
    
    [self getLiveInfo:^(BOOL success, NSString *error) {
        if (success){
            [self readyToBeginLive];
        }else{
            NSLog(@"error=%@",error);
            [SVProgressHUD dismiss];
            [SVProgressHUD showErrorWithStatus:error];
        }
    }];

    
}

- (void)readyToBeginLive{
    self.isRecord = self.readyToLiveView.isRecord;
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.readyToLiveView.frame = CGRectMake(self.readyToLiveView.left, self.readyToLiveView.bottom, self.readyToLiveView.width, 0);
    } completion:^(BOOL finished) {
        [self.readyToLiveView removeFromSuperview];
        self.readyToLiveView = nil;
    }];
    
    [self setBeginToLive];
}


- (void)setBeginToLive{
    UIButton *beginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.readyToLiveView){
        beginButton.frame = CGRectMake(self.readyToLiveView.left, self.readyToLiveView.bottom, self.readyToLiveView.width, 50);
    }else{
        [beginButton sizeWith:CGSizeMake(280, 50)];
        [beginButton setCenter:self.view.center];
    }
    beginButton.layer.cornerRadius = 25;
    beginButton.layer.masksToBounds = YES;
    beginButton.backgroundColor = [UIColor colorWithHex:0xdd4242];
    [beginButton setTitle:[NSString stringWithFormat:@"开始直播"] forState:UIControlStateNormal];
    beginButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    beginButton.titleLabel.textColor = [UIColor whiteColor];
    [beginButton addTarget:self action:@selector(beginToLive:) forControlEvents:UIControlEventTouchUpInside];
    CAAnimation *animation =[Animations opacity:[NSNumber numberWithFloat:1.0f] fromValue:[NSNumber numberWithFloat:0.0f] time:1.0f];
    [beginButton.layer addAnimation:animation forKey:@"benginBtnAnimation"];
    [self.view addSubview:beginButton];
}

- (void)beginToLive:(id)sender{
    [sender removeFromSuperview];
    [self createAVChatRoom:^(BOOL success, int code, NSString *msg) {
        if (success){
            [self getLivePlayInfo:^(BOOL success, NSString *error) {
                if (success){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.bottomView setUserInteractionEnabled:true];
                        
                        //@"rtmp://10714.livepush.myqcloud.com/live/10714_test?bizid=10714&txSecret=c5efc53ffef6a2ce9a56e0dcf2d7c267&txTime=5AE73D7F"
                        
                        NSString *pushUrl = [NSString stringWithFormat:@"%@%@",self.rtmpUrl,self.isRecord ? @"&record=hls" : @""];
                        
                        [self.txLivePublisher startPush:pushUrl];
                        
                        [self addMessageView];
                        
                        self.presentView = [[PresentView alloc]init];
                        self.presentView.delegate = self;
                        self.presentView.backgroundColor = [UIColor clearColor];
                        [self.view addSubview:self.presentView];
                        [self.presentView sizeWith:CGSizeMake(200, 200)];
                        [self.presentView layoutAbove:self.messageView];
                        [self.presentView alignParentLeft];
                        
                        
                        [self creatTimeLabelTimer];
                        
                        
                        self.barrageManager = [[OCBarrageManager alloc] init];
                        [self.view addSubview:self.barrageManager.renderView];
                        [self.barrageManager.renderView sizeWith:CGSizeMake([UIScreen getWidth], self.messageView.y - 40 - self.headView.y - self.headView.height)];
                        [self.barrageManager.renderView layoutAbove:self.messageView margin:20];
                        [self.barrageManager start];
                        
#ifdef DEBUG
                        [self gagUser:@"u12079" time:0];
#endif
                        
                        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"CJLiveState"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                    });
                }else{
                    if ([error equalsString:@"接口数据返回错误"]){
                        [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
                    }else{
                        [SVProgressHUD showErrorWithStatus:error];
                    }
                    [self exitLive];
                }
            }];
        }else{
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"创建直播间失败(%d)",code]];
            [self exitLive];
        }
    }];
//    [SVProgressHUD showErrorWithStatus:@"创建房间失败"];
}

- (void)getLivePlayInfo:(void(^)(BOOL success, NSString *error))complete{
    NSString *api = HTTPAPI(@"live/play");
    NSString *groupId = self.groupId;
    NSString *lat = @"";
    NSString *lng = @"";
    NSString *record = @"false";
    
    NSString *url = [NSString stringWithFormat:@"%@?id=%@&lat=%@&lng=%@&record=%@",api,groupId,lat,lng,record];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [CJNetworkManager PostWithRequest:request Success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
            NSLog(@"服务器返回:%@",responseObject);
            NSDictionary *data = [responseObject objectForKey:@"data"];
            if (data && [data objectForKey:@"pushUrl"]){
                self.rtmpUrl = [data objectForKey:@"pushUrl"];
                follow = [[NSString stringWithFormat:@"%@",[data objectForKey:@"follow"]] longLongValue];
                likeCount = [[NSString stringWithFormat:@"%@",[data objectForKey:@"likeCount"]] longLongValue];
                viewerCount = [[NSString stringWithFormat:@"%@",[data objectForKey:@"viewerCount"]] longLongValue];
                yinpiao = [[NSString stringWithFormat:@"%@",[data objectForKey:@"gift"]] longLongValue];
                [self.yinpiaoView setYinpiao:self->yinpiao];
                [self refreshRoomMember];
                complete(true, nil);
            }else{
                //未找到Key
                complete(false, @"未找到Key");
            }
        }else{
            //接口数据返回错误
            if ([[responseObject objectForKey:@"type"] equalsString:@"error"]){
                complete(false, [responseObject objectForKey:@"content"]);
            }else{
                complete(false, @"接口数据返回错误");
            }
        }
    } andFalse:^(NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        //请求接口错误
        complete(false, @"请求接口错误");
    }];
}

- (void)refreshRoomMember{
    [self.headView setFansCount:self.anchor.fans];
    [self.headView setNickName:self.anchor.nickName];
    [self.audienceView setAudience:viewerCount];
}

- (void)getLiveInfo:(void(^)(BOOL success, NSString *error))complete{
    [self uploadCoverImage:^(BOOL success, NSString *imgUrl) {
        if (success){
            self.liveTitle = self.readyToLiveView.titleLabel.text;
            self.frontCover = imgUrl;
            complete(success, nil);
        }else{
            //上传封面失败
            complete(false, @"上传封面失败");
        }
    }];
}

- (void)createLiveRoomWithTitle:(NSString *)title frontCover:(NSString *)frontCover complete:(void(^)(BOOL success, NSString *error))complete{
    NSString *api = HTTPAPI(@"live/create");
    NSString *location = @"";
    
    NSString *url = [NSString stringWithFormat:@"%@?title=%@&frontcover=%@&location=%@",api,[title URLEncodedString],frontCover,location];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    [CJNetworkManager PostWithRequest:request Success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
            NSLog(@"服务器返回:%@",responseObject);
            NSDictionary *data = [responseObject objectForKey:@"data"];
            if (data && [data objectForKey:@"liveId"] && [data objectForKey:@"headpic"] && [data objectForKey:@"title"]){
                self.groupId = [NSString stringWithFormat:@"%@",[data objectForKey:@"liveId"]];
                [self.headView.iconView sd_setImageWithURL:[NSURL URLWithString:[data objectForKey:@"headpic"]]];
                self.liveTitle = [data objectForKey:@"title"];
                [self.audienceView setAudience:[[data objectForKey:@"viewerCount"] integerValue]];
                [self.headView setFansCount:self.anchor.fans];
                [self.headView setNickName:self.anchor.nickName];
                
                complete(true, nil);
            }else{
                //未找到Key
                complete(false, @"未找到Key");
            }
        }else{
            //接口数据返回错误
            complete(false, @"接口数据返回错误");
        }
    } andFalse:^(NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        //请求接口错误
        complete(false, @"请求接口错误");
    }];
}

- (void)uploadCoverImage:(void(^)(BOOL success, NSString *imgUrl))complete{
    UIImage *image = self.readyToLiveView.imageView.image;
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    [[CJAliOSSManager defautManager] uploadObjectAsyncWithData:imageData progress:^(NSString *percent) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD showProgress:[percent floatValue] status:@"正在上传封面"];
            NSLog(@"upload=%@",percent);
        });
    } complete:^(CJAliOSSUploadResult result, NSString *url) {
        if (result == CJAliOSSUploadResultSuccess){
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismissWithDelay:0.5 completion:^{
                    complete(true, url);
                }];
            });
        }else{
            //上传封面失败
            complete(false, nil);
        }
    }];
}

- (void)createAVChatRoom:(void(^)(BOOL success, int code, NSString *msg))complete{
    if ([[TIMManager sharedInstance] getLoginStatus] == TIM_STATUS_LOGINED){
        TIMCreateGroupInfo *info = [TIMCreateGroupInfo alloc];
        info.groupType = @"AVChatRoom";
        info.group = self.groupId;
        info.groupName = self.liveTitle;
        
        [[TIMGroupManager sharedInstance] createGroup:info succ:^(NSString *groupId) {
            self.groupId = groupId;
            complete(true,0,nil);
            NSLog(@"create group success:%@",groupId);
        } fail:^(int code, NSString *msg) {
            if (code == 10025){
                self.groupId = info.group;
                complete(true,0,nil);
                NSLog(@"create group error:%@",msg);
            }else{
                NSLog(@"create group error:%d %@",code,msg);
                complete(false,code,msg);
            }
        }];
    }else{
        complete(false, 0, @"IM未登录");
    }
}

- (void)exitLive{
    if (gameUrl){
        //[self.gameVC destroy];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请您关闭游戏后再退出直播!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        if (self.groupId){
            [[TIMGroupManager sharedInstance] deleteGroup:self.groupId succ:^{
                NSLog(@"delete group success");
            } fail:^(int code, NSString *msg) {
                NSLog(@"delete group error:%d,%@",code,msg);
            }];
            NSString *url = [NSString stringWithFormat:@"%@?id=%@",HTTPAPI(@"live/stop"),self.groupId];
            [CJNetworkManager PostHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                [self quit];
                NSLog(@"exitLive=%@",responseObject);
            } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                NSLog(@"exitLive=%@",error);
                [self quit];
            }];
        }else{
            [self quit];
        }
    }
}

- (void)quit{
    [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"CJLiveState"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.barrageManager stop];
    [self.txLivePublisher stopPush];
    [self.txLivePublisher stopPreview];
    self.txLivePublisher.delegate = nil;
    self.txLivePublisher = nil;
    [self releaseObjects];
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)appendMessage:(CJLiveMessageModel *)data{
    [self.messageView beginUpdates];
    [self.messageList addObject:data];
    NSIndexPath *index1 = [NSIndexPath indexPathForRow:self.messageList.count * 2 - 2 inSection:0];
    NSIndexPath *index2 = [NSIndexPath indexPathForRow:self.messageList.count * 2 - 1 inSection:0];
    NSArray *indexArr = [NSArray arrayWithObjects:index1,index2, nil];
    [self.messageView insertRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationBottom];
    [self.messageView endUpdates];
    [self.messageView scrollToRowAtIndexPath:index2 atScrollPosition:UITableViewScrollPositionBottom animated:false];
}

- (void)onreceiveGift:(CJLiveMessageModel *)data{
    [self showGiftGif:data.message giftID:nil senderName:data.nickName senderHeadUrl:data.icon isSelf:false];
    [self appendMessage:data];
}


#pragma mark - PresentView Delegate
- (PresentViewCell *)presentView:(PresentView *)presentView cellOfRow:(NSInteger)row
{
    return [[CustonCell alloc] initWithRow:row];
}

- (void)presentView:(PresentView *)presentView configCell:(PresentViewCell *)cell model:(id<PresentModelAble>)model
{
    CustonCell *customCell = (CustonCell *)cell;
    customCell.model = model;
}

- (void)presentView:(PresentView *)presentView didSelectedCellOfRowAtIndex:(NSUInteger)index
{
    CustonCell *cell = [presentView cellForRowAtIndex:index];
    NSLog(@"你点击了：%@", cell.model.giftName);
}

- (void)presentView:(PresentView *)presentView animationCompleted:(NSInteger)shakeNumber model:(id<PresentModelAble>)model
{
    
    NSLog(@"%@礼物的连送动画执行完成 X%zd", model.giftName, model.giftNumber);
}

- (void)praiseHeart{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(self.view.bounds.size.width - 39, self.view.bounds.size.height - 100, 30, 30);
    imageView.image = [UIImage imageNamed:@"mao-zi_icon"];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    
    
    CGFloat startX = round(random() % 200);
    CGFloat scale = round(random() % 2) + 1.0;
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    int imageName = round(random() % 7);
    NSLog(@"%.2f - %.2f -- %d",startX,scale,imageName);
    
    
    
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    [UIView setAnimationDuration:7 * speed];

    NSArray *imageArray =  @[[UIImage imageNamed:@"mao-zi_icon"], [UIImage imageNamed:@"zb_m-m-dà_icon"], [UIImage imageNamed:@"zb_mai-ke-feng_icon"], [UIImage imageNamed:@"zb_mei-gui-hua_icon"], [UIImage imageNamed:@"zb_yin-liao_icon"], [UIImage imageNamed:@"zn_huang-guan_icon"]];
    UIImage *praseimage= imageArray[rand()%(5+1)];
    imageView.image =praseimage;
    imageView.frame = CGRectMake([UIScreen getWidth] - startX, -100, 35 * scale, 35 * scale);


    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)praiseGift{
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(self.view.bounds.size.width - 39, self.view.bounds.size.height - 100, 30, 30);
    imageView.image = [UIImage imageNamed:@"gift"];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.clipsToBounds = YES;
    [self.view addSubview:imageView];
    
    
    CGFloat startX = round(random() % 200);
    CGFloat scale = round(random() % 2) + 1.0;
    CGFloat speed = 1 / round(random() % 900) + 0.6;
    int imageName = round(random() % 2);
    NSLog(@"%.2f - %.2f -- %d",startX,scale,imageName);
    
    [UIView beginAnimations:nil context:(__bridge void *_Nullable)(imageView)];
    [UIView setAnimationDuration:7 * speed];
    
    imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"gift%d.png",imageName]];
    imageView.frame = CGRectMake([UIScreen getWidth] - startX, -100, 35 * scale, 35 * scale);
    
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [imageView removeFromSuperview];
}

- (void)showGiftGif:(NSString *)title giftID:(NSString *)giftID senderName:(NSString *)senderName senderHeadUrl:(NSString *)senderHeadUrl isSelf:(BOOL)isSelf{
    [LiveGiftView getGiftList:^(NSArray *giftList) {
        if (giftList){
            for (id gift in giftList){
                if ([gift isKindOfClass:[NSDictionary class]]){
                    if ([title containsString:[gift objectForKey:@"name"]]){
                        [self showGifWebView:[gift objectForKey:@"animation"] giftName:[gift objectForKey:@"name"] name:senderName headUrl:senderHeadUrl giftID:[NSString stringWithFormat:@"%ld",[[gift objectForKey:@"id"] integerValue]] giftSmallName:[gift objectForKey:@"animation"] isSelf:isSelf];
                        self->yinpiao += [[NSString stringWithFormat:@"%@",[gift objectForKey:@"price"]] longLongValue];
                        [self.yinpiaoView setYinpiao:self->yinpiao];
                        break;
                    }
                }
            }
        }
    }];
//    if ([title rangeOfString:@"送了【666】"].location != NSNotFound || [giftID isEqualToString : @"1"]) {
//        [self showGifWebView:@"gift-666" giftName:@"666" name:senderName headUrl:senderHeadUrl giftID:1 giftSmallName:@"gift-666" isSelf:isSelf];
//    } else if ([title rangeOfString:@"送了【棒棒糖】"].location != NSNotFound || [giftID isEqualToString : @"2"]) {
//        [self showGifWebView:@"gift-suger" giftName:@"棒棒糖"  name:senderName headUrl:senderHeadUrl giftID:2 giftSmallName:@"gift-suger" isSelf:isSelf];
//    }
//    else if ([title rangeOfString:@"送了【爱心】"].location != NSNotFound || [giftID isEqualToString : @"3"]) {
//        [self showGifWebView:@"gift-love" giftName:@"爱心"  name:senderName headUrl:senderHeadUrl giftID:3 giftSmallName:@"gift-love-small" isSelf:isSelf];
//    }
//    else if ([title rangeOfString:@"送了【玫瑰】"].location != NSNotFound || [giftID isEqualToString : @"4"]) {
//        [self showGifWebView:@"gift-rose" giftName:@"玫瑰"  name:senderName headUrl:senderHeadUrl giftID:4 giftSmallName:@"gift-rose-small" isSelf:isSelf];
//    }
//    else if ([title rangeOfString:@"送了【么么哒】"].location != NSNotFound || [giftID isEqualToString : @"5"]) {
//        [self showGifWebView:@"gift-lip" giftName:@"么么哒"  name:senderName headUrl:senderHeadUrl giftID:5 giftSmallName:@"gift-lip" isSelf:isSelf];
//    }
//    else if ([title rangeOfString:@"送了【萌萌哒】"].location != NSNotFound || [giftID isEqualToString : @"6"]) {
//        [self showGifWebView:@"gift-MMD" giftName:@"萌萌哒"  name:senderName headUrl:senderHeadUrl giftID:6 giftSmallName:@"gift-MMD-small" isSelf:isSelf];
//    }
//    else if ([title rangeOfString:@"送了【甜甜圈】"].location != NSNotFound || [giftID isEqualToString : @"7"]) {
//        [self showGifWebView:@"gift-breah" giftName:@"甜甜圈"  name:senderName headUrl:senderHeadUrl giftID:7 giftSmallName:@"gift-breah-small" isSelf:isSelf];
//    }
//    else if ([title rangeOfString:@"送了【女神称号】"].location != NSNotFound || [giftID isEqualToString : @"8"]) {
//        [self showGifWebView:@"gift-god" giftName:@"女神称号"  name:senderName headUrl:senderHeadUrl giftID:8 giftSmallName:@"gift-god-small" isSelf:isSelf];
//    }
}
#pragma 显示git礼物图
- (void)showGifWebView:(NSString *)gifImageName giftName:(NSString *)giftName name:(NSString *)name headUrl:(NSString *)headUrl giftID:(NSInteger)giftID giftSmallName:(NSString *)giftSmallName isSelf:(BOOL)isSelf{
    if (self.currentGiftId != giftID || ![self.currentGiftSernderName isEqualToString:name]) {
        self.currentGiftId = giftID;
        self.currentGiftSernderName = name;
        self.number = 1;
    }else{
        self.number += 1;
    }
    PresentModel *model = [PresentModel modelWithSender:name giftName:giftName icon:headUrl giftImageName:giftSmallName];
    model.giftNumber = self.number;
    [_presentView insertPresentMessages:@[model] showShakeAnimation:YES];
    
    if (self.isShowGif) {
        return;
    }
    self.isShowGif = YES;
    
    //    self.Aimv = [[OLImageView alloc] initWithImage:[OLImage imageNamed:[NSString stringWithFormat:@"%@.gif",gifImageName]]];
    self.Aimv = [[OLImageView alloc] initWithImage:[OLImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:gifImageName]]]];
    [self.Aimv setFrame:CGRectMake(([UIScreen getWidth] - self.Aimv.image.size.width*2/3)/2, 160, self.Aimv.image.size.width*2/3, self.Aimv.image.size.height*2/3)];
    [self.Aimv setUserInteractionEnabled:YES];
    [self.view  addSubview:self.Aimv];
    self.giftTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(stopGif) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.giftTimer forMode:NSDefaultRunLoopMode];
    
}



- (void)stopGif{
    [self.Aimv removeFromSuperview];
    self.isShowGif = NO;
}

#pragma mark - Bottom Delegate
- (void)CJLivePushBottomOnClickFilter{
    self.beautyPanel.hidden = false;
    self.bottomView.hidden = true;
    self.messageView.hidden = true;
}

- (void)CJLivePushBottomOnClickTurnCamera{
    [self.bottomView.toggleTorchBtn setHidden:!self.bottomView.toggleTorchBtn.isHidden];
    [self.txLivePublisher switchCamera];
    if (self.bottomView.toggleTorchBtn.isHidden && _torch_switch){
        [self CJLivePushBottomOnClickToggleTorch];
    }
}

- (void)CJLivePushBottomOnClickToggleTorch{
    _torch_switch = !_torch_switch;
    [_txLivePublisher toggleTorch:_torch_switch];
}

- (void)CJLivePushBottomOnClickGift{
    CJWeexViewController *weex = [[CJWeexViewController alloc] init];
    NSString *url = [NSString stringWithFormat:@"file://view/live/gifts.js?liveId=%@",self.groupId];
    url = [url rewriteURL];
    weex.url = [NSURL URLWithString:url];
    [weex render:nil];
    [self presentViewController:[[WXRootViewController alloc]initWithRootViewController:weex] animated:true completion:nil];
}

- (void)CJLivePushBottomOnClickGame{
    if (!_bottomView.gameBtn.isSelected){
        _appIsInterrupt = YES;
        [_txLivePublisher pausePush];
        CJWeexViewController *weex = [[CJWeexViewController alloc] init];
        NSString *url = @"file://view/game/open.js";
        url = [url rewriteURL];
        weex.url = [NSURL URLWithString:url];
        [weex render:nil];
        [self presentViewController:[[WXRootViewController alloc]initWithRootViewController:weex] animated:true completion:nil];
    }else{
        [self.gameVC destroy];
    }
    
}

#pragma mark - BeautySettingPanelDelegate
- (void)onSetBeautyStyle:(int)beautyStyle beautyLevel:(float)beautyLevel whitenessLevel:(float)whitenessLevel ruddinessLevel:(float)ruddinessLevel{
    [_txLivePublisher setBeautyStyle:beautyStyle beautyLevel:beautyLevel whitenessLevel:whitenessLevel ruddinessLevel:ruddinessLevel];
}

- (void)onSetEyeScaleLevel:(float)eyeScaleLevel {
    [_txLivePublisher setEyeScaleLevel:eyeScaleLevel];
}

- (void)onSetFaceScaleLevel:(float)faceScaleLevel {
    [_txLivePublisher setFaceScaleLevel:faceScaleLevel];
}

- (void)onSetFilter:(UIImage *)filterImage {
    [_txLivePublisher setFilter:filterImage];
}


- (void)onSetGreenScreenFile:(NSURL *)file {
    [_txLivePublisher setGreenScreenFile:file];
}

- (void)onSelectMotionTmpl:(NSString *)tmplName inDir:(NSString *)tmplDir {
    [_txLivePublisher selectMotionTmpl:tmplName inDir:tmplDir];
}

- (void)onSetFaceVLevel:(float)vLevel{
    [_txLivePublisher setFaceVLevel:vLevel];
}

- (void)onSetFaceShortLevel:(float)shortLevel{
    [_txLivePublisher setFaceShortLevel:shortLevel];
}

- (void)onSetNoseSlimLevel:(float)slimLevel{
    [_txLivePublisher setNoseSlimLevel:slimLevel];
}

- (void)onSetChinLevel:(float)chinLevel{
    [_txLivePublisher setChinLevel:chinLevel];
}

- (void)onSetMixLevel:(float)mixLevel{
    [_txLivePublisher setSpecialRatio:mixLevel / 10.0];
}

#pragma mark - TxLivePush Delegate
- (void)onPushEvent:(int)EvtID withParam:(NSDictionary *)param{
    
}

- (void)onNetStatus:(NSDictionary *)param{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MessageView Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _messageList.count * 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *NullCell = @"CJNullCell";
    if (indexPath.row % 2 == 1){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NullCell];
        if (!cell){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NullCell];
            cell.backgroundColor = [UIColor clearColor];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        return cell;
    }else{
//        CJLiveMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CJLiveMessageViewCell reuseIdentifier] forIndexPath:indexPath];
        CJLiveMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[CJLiveMessageViewCell reuseIdentifier]];
        if (!cell){
            cell = [[CJLiveMessageViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        [cell setData:_messageList[indexPath.row / 2]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 2 == 1){
        return 3;
    }else{
        return [CJLiveMessageViewCell getHeightWithData:_messageList[indexPath.row / 2]] + 10;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 2 == 0){
        NSInteger index = indexPath.row / 2;
        NSString *userId = _messageList[index].Id;
        NSString *nickName = _messageList[index].nickName;
        if (userId){
            long uId = [userId longLongValue];
            userId = [NSString stringWithFormat:@"u%ld",uId + 10200];
            CJWeexViewController *weex = [[CJWeexViewController alloc] init];
            NSString *url = [NSString stringWithFormat:@"file://view/live/host.js?id=%ld&groupId=%@&nickName=%@&isUser=false",uId, self.groupId, [nickName URLEncodedString]];
            url = [url rewriteURL];
            weex.url = [NSURL URLWithString:url];
            [weex render:nil];
            [self presentViewController:[[WXRootViewController alloc]initWithRootViewController:weex] animated:true completion:nil];
        }
    }
    return nil;
}

-(BOOL)isSuitableMachine:(int)targetPlatNum
{
    int mib[2] = {CTL_HW, HW_MACHINE};
    size_t len = 0;
    char* machine;
    
    sysctl(mib, 2, NULL, &len, NULL, 0);
    
    machine = (char*)malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString* platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    if ([platform length] > 6) {
        NSString * platNum = [NSString stringWithFormat:@"%C", [platform characterAtIndex: 6 ]];
        return ([platNum intValue] >= targetPlatNum);
    } else {
        return NO;
    }
    
}
@end
