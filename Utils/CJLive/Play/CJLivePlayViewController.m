//
//  CJLivePlayViewController.m
//  Weex
//
//  Created by 郭书智 on 2018/4/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePlayViewController.h"
#import <TXLivePlayer.h>
#import <TXLivePlayConfig.h>

#import "CJWeexViewController.h"
#import <WXRootViewController.h>

#import "CJLivePlayHeadView.h"
#import "CJAudienceView.h"
#import "CJLiveMessageViewCell.h"
#import "CJYinpiaoView.h"

#import "CJLivePlayBottomView.h"

#import "RCDLiveInputBar.h"
#import "LiveGiftView.h"


#import "PresentModel.h"
#import "OLImageView.h"
#import "OLImage.h"
#import "PresentView.h"
#import "CustonCell.h"

#import <OCBarrage.h>
@interface CJLivePlayViewController ()<CJAudienceViewDelegate, UITableViewDelegate, UITableViewDataSource, CJLivePlayBottomViewDelegate, RCTKInputBarControlDelegate, LiveGiftViewDelegate, PresentViewDelegate, CJLivePlayHeadDelegate, TXLivePlayListener>

@property (nonatomic, strong) TXLivePlayer *txLivePlayer;

@property (nonatomic, strong) CJLivePlayHeadView        *headView;
@property (nonatomic, strong) CJAudienceView            *audienceView;
@property (nonatomic, strong) UITableView               *messageView;
@property (nonatomic, strong) CJLivePlayBottomView      *bottomView;
@property (nonatomic, strong) LiveGiftView              *giftView;
@property (nonatomic, strong) CJYinpiaoView             *yinpiaoView;

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

@property (nonatomic, strong) OCBarrageManager          *barrageManager;
@end

@implementation CJLivePlayViewController{
    CGRect                  _videoWidgetFrame;
    UIView                  *_mVideoContainer;
    TXLivePlayConfig        *_config;
    BOOL                    _isPlaying;
    BOOL                    _isPause;
    UIImageView             *backgroundImage;
    
    CGFloat                 _viewWidth;
    CGFloat                 _viewHeight;
    
    RCDLiveInputBar         *_inputBar;
    
    
    double                  currentInterl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPlayerView];
    [self setupLogicView];
    
    //键盘消失事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    CJRegisterNotification(@selector(onNewMessage:), CJNOTIFICATION_GROUP_MESSAGE);
    
    _messageList = [[NSMutableArray alloc] init];
    
    [self.headView.iconView sd_setImageWithURL:[NSURL URLWithString:self.anchor.headpic]];
    [self.headView setTitle:self.anchor.title];
    [self.audienceView setAudience:self.anchor.viewerCount];
    [self.headView setAttention:self.anchor.follow];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self start];
        [self enterLiveRoom];
    });
    
    [self.yinpiaoView setYinpiao:self.anchor.gift];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)keyboardWillHide:(NSNotification *)notification{
    [_inputBar setHidden:true];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    if (_giftView){
        for (UITouch *touch in touches){
            NSLog(@"touch=%@",[touch.view class]);
            CGPoint location = [touch locationInView:nil];
            if (location.y < _giftView.y){
                [self hideGiftView];
            }
        }
    }else if (!_inputBar.isHidden){
        for (UITouch *touch in touches){
            CGPoint location = [touch locationInView:nil];
            if (location.y < _inputBar.y){
                [self.view endEditing:true];
            }
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPlayerView{
    _videoWidgetFrame = [UIScreen mainScreen].bounds;
    
    _mVideoContainer = [[UIView alloc] initWithFrame:_videoWidgetFrame];
    [self.view insertSubview:_mVideoContainer atIndex:0];
    
    _txLivePlayer = [[TXLivePlayer alloc] init];
    _txLivePlayer.delegate = self;
    [_txLivePlayer setupVideoWidget:CGRectZero containView:_mVideoContainer insertIndex:0];
    
    _config = [[TXLivePlayConfig alloc] init];
    _config.playerPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    [_txLivePlayer setConfig:_config];
    
    self.view.backgroundColor = [UIColor blackColor];
    _mVideoContainer.backgroundColor = [UIColor blackColor];
}

- (void)setupLogicView{
    UIButton *closeBtn = [[UIButton alloc] init];
    [closeBtn setImage:[UIImage imageNamed:@"live-out"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(exitLivePlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    
    [closeBtn sizeWith:CGSizeMake(54, 30)];
    [closeBtn alignParentRight];
    [closeBtn alignParentTopWithMargin:[UIScreen getStatusBarHeight] + 10];
    
    self.headView = [[CJLivePlayHeadView alloc] initWithFrame:CGRectMake(0, 0, 150, 32)];
    [self.headView.iconView setBackgroundColor:[UIColor redColor]];
    self.headView.delegate = self;
    [self.view addSubview:self.headView];
    
    [self.headView alignParentLeftWithMargin:10.0];
    [self.headView alignTop:closeBtn];
    
    
    self.audienceView = [[CJAudienceView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    self.audienceView.delegate = self;
    [self.view addSubview:self.audienceView];
    
    [self.audienceView alignParentRight];
    [self.audienceView layoutBelow:closeBtn margin:10.0];
    
    self.yinpiaoView = [[CJYinpiaoView alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    [self.view addSubview:self.yinpiaoView];
    
    [self.yinpiaoView alignLeft:self.headView];
    [self.yinpiaoView layoutBelow:self.headView margin:10];
    
    self.messageView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.messageView.delegate = self;
    self.messageView.dataSource = self;
    self.messageView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.messageView.backgroundColor = [UIColor clearColor];
    //        [_messageView registerClass:[CJLiveMessageViewCell class] forCellReuseIdentifier:[CJLiveMessageViewCell reuseIdentifier]];
    [self.messageView setShowsVerticalScrollIndicator:false];
    [self.messageView setShowsHorizontalScrollIndicator:false];
    [self.view addSubview:self.messageView];
    
    [self.messageView sizeWith:CGSizeMake(CJLiveMessageCellWidth + 10, 200)];
    [self.messageView alignParentLeftWithMargin:10];
    
    self.bottomView = [[CJLivePlayBottomView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen getWidth], 40)];
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    
    [self.bottomView alignParentBottomWithMargin:20];
    
    [self.messageView layoutAbove:self.bottomView margin:10];
    
    
    
    
    
    self.presentView = [[PresentView alloc]init];
    self.presentView.delegate = self;
    self.presentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.presentView];
    [self.presentView sizeWith:CGSizeMake(200, 200)];
    [self.presentView layoutAbove:self.messageView];
    [self.presentView alignParentLeft];
    
    self.barrageManager = [[OCBarrageManager alloc] init];
    [self.view addSubview:self.barrageManager.renderView];
    [self.barrageManager.renderView sizeWith:CGSizeMake([UIScreen getWidth], self.messageView.y - 40 - self.headView.y - self.headView.height)];
    [self.barrageManager.renderView layoutAbove:self.messageView margin:20];
    
    _inputBar = [[RCDLiveInputBar alloc] initWithFrame:CGRectMake(0, [UIScreen getHeight] - 50, [UIScreen getWidth], 50)];
    _inputBar.delegate = self;
    _inputBar.backgroundColor = [UIColor clearColor];
    _inputBar.hidden = true;
    [self.view addSubview:_inputBar];
    
    //启动弹幕
    [self.barrageManager start];
    
}

- (void)enterLiveRoom{
    CJLiveMessageModel *message = [[CJLiveMessageModel alloc] init];
    message.messageType = CJLiveMessageTypeTip;
    message.message = @"倡导绿色直播，封面和直播内容涉及色情、低俗、暴力、引诱、暴露等都将被封停账号，同时禁止直播闹事，集会。文明直播，从我做起【网警24小时在线巡查】\n安全提示：若涉及本系统以外的交易操作，请一定要先核实对方身份，谨防受骗！";
    [self appendMessage:message];
    [self sendMsg:CJLiveMessageTypeEnter message:@"加入房间"];
}

- (void)onNewMessage:(NSNotification *)notification{
    NSLog(@"%@",notification.userInfo);
    NSString *type = [notification.userInfo objectForKey:@"type"];
    if ([type equalsString:@"gag"]){//禁言
        [self sendMsg:CJLiveMessageTypeGag message:[notification.userInfo objectForKey:@"info"]];
    }else if ([type equalsString:@"kick"]){
        [self sendMsg:CJLiveMessageTypeKick message:[notification.userInfo objectForKey:@"info"]];
    }else if ([type equalsString:@"SYSTEM_DELETE"]){
        [SVProgressHUD showInfoWithStatus:@"直播已结束"];
        [self exitLivePlay];
    }else if ([type equalsString:@"SYSTEM_KICK"]){
        [SVProgressHUD showInfoWithStatus:@"您已被请离直播间"];
        [self exitLivePlay];
    }else if ([type equalsString:@"message"]){
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
                        if ([elemData objectForKey:@"vip"] && [[elemData objectForKey:@"vip"] length] > 0){
                            data.VIP = [elemData objectForKey:@"vip"];
                        }
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
                                        [self.audienceView setAudience:++self.anchor.viewerCount];
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
                                data.messageType = CJLiveMessageTypeTip;
                                data.message = CJLiveMessageKickString;
                                [self appendMessage:data];
                                if ([data.userId equalsString:[CJUserManager getUserId]]){
                                    [SVProgressHUD showInfoWithStatus:@"您已被请离直播间"];
                                    [self exitLivePlay];
                                }
                                break;
                            }
                        }else if ([[dic objectForKey:@"cmd"] equalsString:@"CustomFollowMsg"]){
                            if (i+1 < msg.elemCount){
                                data.messageType = CJLiveMessageTypeTip;
                                data.message = [elemData objectForKey:@"text"];
                                [self appendMessage:data];
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

- (void)onreceiveGift:(CJLiveMessageModel *)data{
    [self showGiftGif:data.message giftID:nil senderName:data.nickName senderHeadUrl:data.icon isSelf:false];
    [self appendMessage:data];
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

- (void)start{
    __weak __typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        int result = [weakSelf.txLivePlayer startPlay:weakSelf.anchor.playUrl type:PLAY_TYPE_LIVE_RTMP];
        if (result != 0){
            return;
        }
        //        [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
        //        [_txLivePlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
        [weakSelf.txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
        [weakSelf.txLivePlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
        self->_isPlaying = true;
        self->_isPause = false;
    });
}

- (void)stop{
    if (_isPlaying || _isPause){
        [_txLivePlayer stopPlay];
        [_txLivePlayer removeVideoWidget];
        _txLivePlayer.delegate = nil;
        _isPlaying = false;
        _isPause = false;
    }
}

- (void)pause{
    if (_isPlaying && !_isPause){
        [_txLivePlayer pause];
        _isPlaying = false;
        _isPause = true;
    }
}

- (void)resume{
    if (!_isPlaying && _isPause){
        [_txLivePlayer resume];
        _isPlaying = true;
        _isPause = false;
    }
}

- (void)sendMsg:(CJLiveMessageType)type message:(NSString *)message{
    TIMMessage *msg = [[TIMMessage alloc] init];
    
    TIMCustomElem *custElem = [[TIMCustomElem alloc] init];
    NSError *error = nil;
    
    NSData *data = nil;
    
    NSString *Id = [NSString stringWithFormat:@"%zu",[CJUserManager getUid]];
    if (type == CJLiveMessageTypeGift){
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomGifMsg",
                                                         @"data":@{@"cmd":@"CustomGifMsg",@"nickName":self.user.nickName,@"headPic":self.user.logo,@"id":Id}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
    }else if(type == CJLiveMessageTypeText || type == CJLiveMessageTypeTip || type == CJLiveMessageTypeEnter){
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomTextMsg",
                                                         @"data":@{@"cmd":@"CustomTextMsg",@"nickName":self.user.nickName,@"headPic":self.user.logo,@"id":Id,@"vip":!self.user.VIP ? @"" : self.user.VIP}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
    }else if (type == CJLiveMessageTypeGag){
        NSArray *arr = [message componentsSeparatedByString:@"|"];
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomGagMsg",
                                                         @"data":@{@"cmd":@"CustomGagMsg",@"nickName":arr[1],@"headPic":self.user.logo,@"id":[NSNumber numberWithInteger:0],@"imid":arr[0],@"text":CJLiveMessageGagString,@"time":arr[2]}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
    }else if (type == CJLiveMessageTypeKick){
        NSArray *arr = [message componentsSeparatedByString:@"|"];
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomKickMsg",
                                                         @"data":@{@"cmd":@"CustomKickMsg",@"nickName":arr[1],@"headPic":self.user.logo,@"id":[NSNumber numberWithInteger:0],@"imid":arr[0],@"text":CJLiveMessageKickString,@"time":@""}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
    }else if (type == CJLiveMessageTypeFollow){
        NSArray *arr = [message componentsSeparatedByString:@"|"];
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomFollowMsg",
                                                         @"data":@{@"cmd":@"CustomFollowMsg",@"nickName":arr[1],@"headPic":self.user.logo,@"id":@"0",@"imid":arr[0],@"text":CJLiveMessageFollowString,@"time":@""}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
    }else if (type == CJLiveMessageTypeUnFollow){
        NSArray *arr = [message componentsSeparatedByString:@"|"];
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomFollowMsg",
                                                         @"data":@{@"cmd":@"CustomFollowMsg",@"nickName":arr[1],@"headPic":self.user.logo,@"id":@"0",@"imid":arr[0],@"text":CJLiveMessageUnFollowString,@"time":@""}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
    }else if (type == CJLiveMessageTypeBarrage){
        data = [NSJSONSerialization dataWithJSONObject:@{@"cmd":@"CustomBarrageMsg",
                                                         @"data":@{@"cmd":@"CustomBarrageMsg",@"nickName":self.user.nickName,@"headPic":self.user.logo,@"id":Id,@"imid":@"",@"text":message,@"time":@""}}
                                               options:NSJSONWritingPrettyPrinted
                                                 error:&error];
        [custElem setData:data];
        [msg addElem:custElem];
    }
    
    
    
    TIMTextElem *textElem = [[TIMTextElem alloc] init];
    switch (type) {
        case CJLiveMessageTypeGag:
            textElem.text = CJLiveMessageGagString;
            break;
        case CJLiveMessageTypeKick:
            textElem.text = CJLiveMessageKickString;
            break;
        case CJLiveMessageTypeFollow:
            textElem.text = CJLiveMessageFollowString;
            break;
        case CJLiveMessageTypeUnFollow:
            textElem.text = CJLiveMessageUnFollowString;
            break;
        default:
            textElem.text = message;
            break;
    }
    
    
    
    [msg addElem:textElem];
    
    TIMConversation *conv = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:self.groupId];
    [conv sendMessage:msg succ:^{
        if (type == CJLiveMessageTypeText || type == CJLiveMessageTypeBarrage){
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = self.user.nickName;
            model.messageType = CJLiveMessageTypeText;
            model.message = message;
            model.userId = [NSString stringWithFormat:@"%zu",[CJUserManager getUid]];
            model.VIP = self.user.VIP;
            [self appendMessage:model];
        }else if (type == CJLiveMessageTypeGift){
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = self.user.nickName;
            model.messageType = CJLiveMessageTypeGift;
            model.message = message;
            model.userId = [NSString stringWithFormat:@"%zu",[CJUserManager getUid]];
            [self appendMessage:model];
            [self showGiftGif:message giftID:nil senderName:self.user.nickName senderHeadUrl:self.anchor.headpic isSelf:true];
        }else if (type == CJLiveMessageTypeEnter){
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = self.user.nickName;
            model.messageType = CJLiveMessageTypeEnter;
            model.userId = [NSString stringWithFormat:@"%zu",[CJUserManager getUid]];
            [self appendMessage:model];
        }else if (type == CJLiveMessageTypeGag){
            NSArray *arr = [message componentsSeparatedByString:@"|"];
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = arr[1];
            model.messageType = CJLiveMessageTypeTip;
            model.message = textElem.text;
            [self appendMessage:model];
        }else if (type == CJLiveMessageTypeKick){
            NSArray *arr = [message componentsSeparatedByString:@"|"];
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = arr[1];
            model.messageType = CJLiveMessageTypeTip;
            model.message = textElem.text;
            [self appendMessage:model];
        }else if (type == CJLiveMessageTypeFollow || type == CJLiveMessageTypeUnFollow){
            NSArray *arr = [message componentsSeparatedByString:@"|"];
            CJLiveMessageModel *model = [[CJLiveMessageModel alloc] init];
            model.nickName = arr[1];
            model.messageType = CJLiveMessageTypeTip;
            model.message = textElem.text;
            [self appendMessage:model];
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"send msg error%d,%@",code,msg);
    }];
}


- (void)sendGiftMsg:(NSString *)msg{
    [self sendMsg:CJLiveMessageTypeGift message:msg];
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
    
    NSArray *imageArray =  @[[UIImage imageNamed:@"mao-zi_icon"], [UIImage imageNamed:@"zb_m-m_icon"], [UIImage imageNamed:@"zb_mai-ke-feng_icon"], [UIImage imageNamed:@"zb_mei-gui-hua_icon"], [UIImage imageNamed:@"zb_yin-liao_icon"], [UIImage imageNamed:@"zn_huang-guan_icon"]];
    UIImage *praseimage= imageArray[rand()%(5+1)];
    imageView.image =praseimage;
    imageView.frame = CGRectMake([UIScreen getWidth] - startX, -100, 35 * scale, 35 * scale);
    
    
    [UIView setAnimationDidStopSelector:@selector(onAnimationComplete:finished:context:)];
    [UIView setAnimationDelegate:self];
    [UIView commitAnimations];
}

- (void)onAnimationComplete:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    
    UIImageView *imageView = (__bridge UIImageView *)(context);
    [imageView removeFromSuperview];
}

- (void)showGiftList{
    //获取账户信息
    NSString *url = [NSString stringWithFormat:@"%@?id=%ld",HTTPAPI(@"user/view"),[CJUserManager getUid]];
    [CJNetworkManager GetHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
            CJLivePlayUserModel *user = [CJLivePlayUserModel modelWithDictionary:[responseObject objectForKey:@"data"]];
            self.user = user;
            [LiveGiftView getGiftList:^(NSArray *giftList) {
                self.giftView = [[NSBundle mainBundle] loadNibNamed:@"LiveGiftView" owner:self options:0][0];
                [self.giftView resetViews];
                self.giftView.delegate = self;
                self.giftView.hidden = NO;
                self->currentInterl = self.user.balance;
                self.giftView.currentInterl.text = [NSString stringWithFormat:@"%.2lf",self.user.balance];
                [self.view addSubview:self.giftView];
                
                [self.giftView sizeWith:CGSizeMake([UIScreen getWidth], 240)];
                [self.giftView alignParentBottom];
                [self.giftView alignParentLeft];
            }];
            
            [self.bottomView setHidden:true];
            
            
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
        }
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
    }];
    
    
    
}

- (void)hideGiftView{
    if (_giftView != nil) {
        [UIView animateWithDuration:1 animations:^{
            [self->_giftView alignBottom:self->_mVideoContainer];
        } completion:^(BOOL finished) {
            [self->_giftView removeFromSuperview];
            self->_giftView = nil;
            [self.bottomView setHidden:false];
        }];
    }
}

- (void)exitLivePlay{
    [self stop];
    [self.barrageManager stop];
    NSString *url = [NSString stringWithFormat:@"%@?id=%@",HTTPAPI(@"live/quit"),self.groupId];
    [CJNetworkManager PostHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"quit=%@",responseObject);
        [self quit];
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"quit=%@",error);
        [self quit];
    }];
    
}

- (void)quit{
    [[TIMGroupManager sharedInstance] quitGroup:self.groupId succ:^{
        [self dismissViewControllerAnimated:true completion:nil];
    } fail:^(int code, NSString *msg) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
}

#pragma mark TXLivePlayListener
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param{
    if (EvtID == PLAY_ERR_NET_DISCONNECT){
        [SVProgressHUD showErrorWithStatus:@"获取视频流失败"];
        [self exitLivePlay];
    }
}

- (void)onNetStatus:(NSDictionary *)param{
    NSLog(@"CJonNetStatus=%@",param);
}

#pragma mark - HeadView Delegate
- (void)CJLivePlayOnClickAttention{
    BOOL isAttention = !self.anchor.follow;
    NSString *url = nil;
    url = isAttention ? [NSString stringWithFormat:@"%@?authorId=%ld",HTTPAPI(@"member/follow/add"),self.anchor.liveMemberId] :
    [NSString stringWithFormat:@"%@?authorId=%ld",HTTPAPI(@"member/follow/delete"),self.anchor.liveMemberId];
    [CJNetworkManager PostHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSLog(@"attention:%@",responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]] && ([[responseObject objectForKey:@"content"] equalsString:@"关注成功"] || [[responseObject objectForKey:@"content"] equalsString:@"取消成功"])){
            self.anchor.follow = isAttention;
            [self.headView setAttention:isAttention];
            [self sendMsg:isAttention ? CJLiveMessageTypeFollow : CJLiveMessageTypeUnFollow message:[NSString stringWithFormat:@"%@|%@",[CJUserManager getUserId],self.user.nickName]];
        }else{
            [SVProgressHUD showErrorWithStatus:@"网络不稳定，请稍后再试"];
        }
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"网络不稳定，请稍后再试"];
    }];
}

#pragma mark - GiftView Delegate
- (void)sendGift:(NSInteger)interlValue title:(NSString *)title giftID:(NSString *)giftID giftNum:(NSInteger)giftNum{
    [self.giftView.sendBtn setEnabled:false];
    for (int i = 0; i < giftNum; i ++){
        NSString *url = [NSString stringWithFormat:@"%@?id=%@&liveId=%ld",HTTPAPI(@"live/gift/submit"),giftID,self.anchor.liveId];
        [CJNetworkManager PostHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            [self.giftView.sendBtn setEnabled:true];
            if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
                [self sendGiftMsg:title];
                self->currentInterl -= [[responseObject objectForKey:@"data"] floatValue];
                
                self.giftView.currentInterl.text = [NSString stringWithFormat:@"%.2lf",self->currentInterl];
                NSLog(@"sendgift=%@",responseObject);
            }else{
                [SVProgressHUD showErrorWithStatus:@"赠送失败"];
            }
        } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            [self.giftView.sendBtn setEnabled:true];
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
        }];
        
    }
}

#pragma mark - InputBar Delegate
- (void)onInputBarControlContentSizeChanged:(CGRect)frame withAnimationDuration:(CGFloat)duration andAnimationCurve:(UIViewAnimationCurve)curve{
    
}

- (void)onInputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
}

- (void)onTouchSendButton:(NSString *)text{
    [_inputBar setInputBarStatus:RCDLiveBottomBarDefaultStatus];
    [_inputBar clearInputView];
    if (self.bottomView.bulletSwitch.isOn){
        NSString *url = [NSString stringWithFormat:@"%@?liveId=%ld",HTTPAPI(@"live/gift/barrage"),self.anchor.liveId];
        [CJNetworkManager PostHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
                [self sendMsg:CJLiveMessageTypeBarrage message:text];
                [self appendBarrageMessage:self.user.nickName message:text];
            }else{
                [SVProgressHUD showErrorWithStatus:@"发送弹幕失败，请检查余额或稍后再试"];
            }
        } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
        }];
    }else{
        [self sendMsg:CJLiveMessageTypeText message:text];
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

#pragma mark - MessageView Delegate
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
        NSString *userId = _messageList[index].userId;
        NSString *nickName = _messageList[index].nickName;
        if (userId){
            long uId = [userId longLongValue];
            userId = [NSString stringWithFormat:@"u%ld",uId + 10200];
            [[TIMGroupManager sharedInstance] getGroupMembersInfo:self.groupId members:[NSArray arrayWithObject:userId] succ:^(NSArray *members) {
                if (members.count > 0){
                    TIMGroupMemberInfo *info = [members firstObject];
                    CJWeexViewController *weex = [[CJWeexViewController alloc] init];
                    NSString *url = [NSString stringWithFormat:@"file://view/live/host.js?id=%ld&groupId=%@&nickName=%@&isUser=true&hasGag=%@",uId, self.groupId, [nickName URLEncodedString], info.silentUntil > 0 ? @"true" : @"false"];
                    url = [url rewriteURL];
                    weex.url = [NSURL URLWithString:url];
                    [weex render:nil];
                    [self presentViewController:[[WXRootViewController alloc]initWithRootViewController:weex] animated:true completion:nil];
                    NSLog(@"memberInfo=%@",members);
                }
            } fail:^(int code, NSString *msg) {
                NSLog(@"memberInfo=%d,%@",code,msg);
            }];
        }
    }
    return nil;
}

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

#pragma mark - CJLiveBottomView Delegate
- (void)CJLivePlayBottomOnClickMsgPlaceBtn{
    [_inputBar setHidden:false];
    [_inputBar setInputBarStatus:RCDLiveBottomBarKeyboardStatus];
}

- (void)CJLivePlayBottomOnClickGiftBtn{
    [self showGiftList];
}

- (void)CJLivePlayBottomOnClickPraiseBtn{
    [self praiseHeart];
}

#pragma mark - PresentView Delegate
- (PresentViewCell *)presentView:(PresentView *)presentView cellOfRow:(NSInteger)row
{
    return [[CustonCell alloc] initWithRow:row];
}

- (void)presentView:(PresentView *)presentView configCell:(PresentViewCell *)cell model:(id<PresentModelAble>)model
{
    CustonCell *customCell = (CustonCell *)cell;
    [customCell setModel:(PresentModel *)model];
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

- (void)showGiftGif:(NSString *)title giftID:(NSString *)giftID senderName:(NSString *)senderName senderHeadUrl:(NSString *)senderHeadUrl isSelf:(BOOL)isSelf{
    [LiveGiftView getGiftList:^(NSArray *giftList) {
        if (giftList){
            for (id gift in giftList){
                if ([gift isKindOfClass:[NSDictionary class]]){
                    if ([title containsString:[gift objectForKey:@"name"]]){
                        [self showGifWebView:[gift objectForKey:@"animation"] giftName:[gift objectForKey:@"name"] name:senderName headUrl:senderHeadUrl giftID:[NSString stringWithFormat:@"%ld",[[gift objectForKey:@"id"] longValue]] giftSmallName:[gift objectForKey:@"animation"] isSelf:isSelf];
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
@end
