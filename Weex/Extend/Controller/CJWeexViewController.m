 //
//  CJWeexViewController.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJWeexViewController.h"
#import <WeexSDK/WXSDKInstance.h>
#import <WeexSDK/WXSDKEngine.h>
#import <WeexSDK/WXUtility.h>
#import <WeexSDK/WXDebugTool.h>
#import <WeexSDK/WXSDKManager.h>
#import <WeexSDK/WXPrerenderManager.h>
#import <WeexSDK/WXMonitor.h>
#import <WeexSDK/WXTracingManager.h>

#import "CJDatabaseManager.h"
#import "IMManager.h"

@interface CJWeexViewController () <UIScrollViewDelegate, UIWebViewDelegate>

@property (nonatomic, strong) WXSDKInstance *instance;
@property (nonatomic, strong) UIView *weexView;

@property (nonatomic, strong) NSArray *refreshList;
@property (nonatomic, strong) NSArray *refreshList1;
@property (nonatomic, strong) NSArray *refresh;
@property (nonatomic) NSInteger count;

@property (nonatomic, assign) CGFloat weexHeight;
@property (nonatomic, assign) id<UIScrollViewDelegate> originalDelegate;

@end

@implementation CJWeexViewController{
    BOOL isRendered;
}

- (instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    self.url = url;
    self.weexHeight = 0;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setClipsToBounds:true];
    isRendered = false;
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    CJRegisterNotification(@selector(notificationImOnNewMessage:), CJNOTIFICATION_IM_ON_NEWMESSAGE);
    CJRegisterNotification(@selector(notificationImUnreadCount:), CJNOTIFICATION_IM_UNREAD_COUNT);
    CJRegisterNotification(@selector(notificationWXSendGlobalEvent:), CJNOTIFICATION_WX_SEND_Global_EVENT);
    
}

- (void)setViewHeight:(CGFloat)height{
    _weexHeight = height;
}

- (void)closeURL{
    if (_callback){
        if (_data){
            _callback(_data);
        }else{
            _callback(@{@"type":@"error",@"content":@"no data",@"data":@""});
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateInstanceState:WeexInstanceAppear];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self updateInstanceState:WeexInstanceDisappear];
    
    if (!self.navigationController || (self.navigationController.viewControllers.count > 1 &&![self.navigationController.viewControllers containsObject:self])){
        [self closeURL];
        _callback = nil;
        _data = nil;
        [_instance destroyInstance];
        [self.view removeSubviews];
        [self releaseProperties];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (@available(iOS 11.0, *)) {
        // 设置允许摇一摇功能
        [UIApplication sharedApplication].applicationSupportsShakeToEdit = YES;
        [self becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (@available(iOS 11.0, *)) {
        // 设置允许摇一摇功能
        [UIApplication sharedApplication].applicationSupportsShakeToEdit = NO;
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (event.subtype == UIEventSubtypeMotionShake) { // 判断是否是摇动结束
        if (@available(iOS 11.0, *)) {
            NSLog(@"refresh");
            [self render:nil];
        }
    }
    return;
}

- (void)dealloc{
    NSLog(@"dealloc");
}

- (void)releaseProperties{
    _script = nil;
    _url = nil;
    _hotReloadSocket = nil;
    _source = nil;
    _instance = nil;
    _weexView = nil;
    _refresh = nil;
    _refreshList = nil;
    _refreshList1 = nil;
    _originalDelegate = nil;
    _label = nil;
    
    CJRemoveNotification(CJNOTIFICATION_IM_ON_NEWMESSAGE);
    CJRemoveNotification(CJNOTIFICATION_IM_UNREAD_COUNT);
    CJRemoveNotification(CJNOTIFICATION_WX_SEND_Global_EVENT);
}

- (void)updateInstanceState:(WXState)state
{
    if (_instance && _instance.state != state) {
        _instance.state = state;
        
        if (state == WeexInstanceAppear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewappear" params:nil domChanges:nil];
        }
        else if (state == WeexInstanceDisappear) {
            [[WXSDKManager bridgeMgr] fireEvent:_instance.instanceId ref:WX_SDK_ROOT_REF type:@"viewdisappear" params:nil domChanges:nil];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)render:(void(^)(BOOL finished))complete{
    [_instance destroyInstance];
    _instance = [[WXSDKInstance alloc] init];
    if([WXPrerenderManager isTaskExist:[self.url absoluteString]]){
        _instance = [WXPrerenderManager instanceFromUrl:self.url.absoluteString];
    }
    _instance.viewController = self;
    _instance.frame = CGRectMake(0, 0, self.view.width, _weexHeight > 0 ? _weexHeight : self.view.height);
    __weak typeof(self) weakSelf = self;
    _instance.onCreate = ^(UIView *view) {
        [weakSelf.weexView removeFromSuperview];
        weakSelf.weexView = view;
        [weakSelf.view addSubview:weakSelf.weexView];
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, weakSelf.weexView);
    };
    
    _instance.onFailed = ^(NSError *error) {
#ifdef DEBUG
        if ([[error domain] isEqualToString:@"1"]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableString *errMsg=[NSMutableString new];
                [errMsg appendFormat:@"ErrorType:%@\n",[error domain]];
                [errMsg appendFormat:@"ErrorCode:%ld\n",(long)[error code]];
                [errMsg appendFormat:@"ErrorInfo:%@\n", [error userInfo]];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"render failed" message:errMsg delegate:weakSelf cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
                [alertView show];
            });
        }
#endif
        if (complete!=nil){
            complete(false);
        }
    };
    
    _instance.renderFinish = ^(UIView *view) {
        WXLogDebug(@"%@", @"Render Finish...");
        [weakSelf updateInstanceState:WeexInstanceAppear];
        
        if (complete!=nil){
            if (view){
                complete(true);
            }else{
                complete(false);
            }
        }
    };
    
    _instance.updateFinish = ^(UIView *view) {
        WXLogDebug(@"%@", @"Update Finish...");
        
        if (complete){
            if (!view){
                complete(false);
            }
        }
    };
    
    if (!self.url) {
        WXLogError(@"error: render url is nil");
        
        if (complete!=nil){
            complete(false);
        }
        
        return;
    }
    if([WXPrerenderManager isTaskExist:[self.url absoluteString]]){
        WX_MONITOR_INSTANCE_PERF_START(WXPTJSDownload, _instance);
        WX_MONITOR_INSTANCE_PERF_END(WXPTJSDownload, _instance);
        WX_MONITOR_INSTANCE_PERF_START(WXPTFirstScreenRender, _instance);
        WX_MONITOR_INSTANCE_PERF_START(WXPTAllRender, _instance);
        [WXPrerenderManager renderFromCache:[self.url absoluteString]];
        return;
    }
    NSURL *URL = [self testURL: [self.url absoluteString]];
    NSString *randomURL = [NSString stringWithFormat:@"%@%@random=%d",URL.absoluteString,URL.query?@"&":@"?",arc4random()];
    [_instance renderWithURL:[NSURL URLWithString:randomURL] options:@{@"bundleUrl":URL.absoluteString} data:nil];
}


#pragma mark - websocket
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if ([@"refresh" isEqualToString:message]) {
        [self render:nil];
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    
}

#pragma mark - load local device bundle
- (NSURL*)testURL:(NSString*)url
{
    NSRange range = [url rangeOfString:@"_wx_tpl"];
    if (range.location != NSNotFound) {
        NSString *tmp = [url substringFromIndex:range.location];
        NSUInteger start = [tmp rangeOfString:@"="].location;
        NSUInteger end = [tmp rangeOfString:@"&"].location;
        ++start;
        if (end == NSNotFound) {
            end = [tmp length] - start;
        }
        else {
            end = end - start;
        }
        NSRange subRange;
        subRange.location = start;
        subRange.length = end;
        url = [tmp substringWithRange:subRange];
    }
    return [NSURL URLWithString:url];
}

#pragma mark - notification
- (void)notificationRefreshInstance:(NSNotification *)notification {
    [self render:nil];
}

- (void)notificationImOnNewMessage:(NSNotification *)notification{
    TIMMessage *msg = [notification.userInfo objectForKey:@"msg"];
    NSString *type = [notification.userInfo objectForKey:@"type"];
    NSString *result = [notification.userInfo objectForKey:@"result"];
    NSString *receiver = @"";
    NSString *content = @"";
    if ([type isEqualToString:@"send"] || [type isEqualToString:@"draft"] || [type isEqualToString:@"lastmsg"]){
        receiver = [notification.userInfo objectForKey:@"receiver"];
    }else if ([type isEqualToString:@"receive"]){
        receiver = [msg sender];
    }
    NSDate *date = [msg timestamp];
    long createDate = (long)([date timeIntervalSince1970] * 1000);
    TIMConversation *conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:receiver];
    int unread = [conversation getUnReadMessageNum];
    if ([result isEqualToString:@"success"]){
        for (int i = 0; i < msg.elemCount; i ++){
            TIMElem *elem = [msg getElem:i];
            if ([elem isKindOfClass:[TIMFaceElem class]]){
                content = [content stringByAppendingString:@"[表情]"];
            }else if ([elem isKindOfClass:[TIMFileElem class]]){
                content = [content stringByAppendingString:@"[文件]"];
            }else if ([elem isKindOfClass:[TIMImageElem class]]){
                content = [content stringByAppendingString:@"[图片]"];
            }else if ([elem isKindOfClass:[TIMSoundElem class]]){
                content = [content stringByAppendingString:@"[语音]"];
            }else if ([elem isKindOfClass:[TIMVideoElem class]]){
                content = [content stringByAppendingString:@"[视频]"];
            }else if ([elem isKindOfClass:[TIMLocationElem class]]){
                content = [content stringByAppendingString:@"[位置]"];
            }else if ([elem isKindOfClass:[TIMTextElem class]]){
                content = [content stringByAppendingString:[elem valueForKey:@"text"]];
            }else if ([elem isKindOfClass:[TIMProfileSystemElem class]]){
                return;
            }else{
                if ([elem isKindOfClass:[TIMCustomElem class]])
                {
                    CustomElemCmd *elemCmd = [CustomElemCmd parseCustom:(TIMCustomElem *)elem];
                    if (elemCmd)
                    {
                        return;
                    }
                }
                content = [content stringByAppendingString:@"消息"];
                NSLog(@"message=%@",elem);
            }
            
        }
    }else{
        content = @"消息发送失败";
    }
    
    __block NSMutableDictionary *message = [NSMutableDictionary new];
    [message setObject:content forKey:@"content"];
    [message setObject:receiver forKey:@"id"];
    [message setObject:[NSNumber numberWithLong:createDate] forKey:@"createDate"];
    [message setObject:[NSNumber numberWithInt:unread] forKey:@"unRead"];
    
    if ([type isEqualToString:@"draft"]){
        [message setObject:[NSNumber numberWithBool:YES] forKey:@"isDraft"];
    }
    
    int success = [[TIMFriendshipManager sharedInstance] getUsersProfile:[NSArray arrayWithObjects:receiver, nil] succ:^(NSArray *friends) {
        if (friends.count == 1){
            TIMUserProfile *user = [friends firstObject];
            NSString *nickName = user.remark.length > 0 ? user.remark : user.nickname;
            NSString *logo = user.faceURL;
            
            [message setObject:nickName forKey:@"nickName"];
            [message setObject:logo forKey:@"logo"];
            
            NSMutableDictionary *dic = [NSMutableDictionary new];
            [dic setObject:@"success" forKey:@"type"];
            [dic setObject:@"success" forKey:@"content"];
            [dic setObject:message forKey:@"data"];
            [_instance fireGlobalEvent:@"onMessage" params:[[NSDictionary alloc] initWithObjectsAndKeys:dic,@"data", nil]];
            
            if ([type isEqualToString:@"receive"]){
                if ([receiver containsString:@"gm"]){
                    [SharedAppDelegate actionLocalNotificationWithSender:nil body:[NSString stringWithFormat:@"%@:%@",nickName,content]];
                }else{
                    [SharedAppDelegate actionLocalNotificationWithSender:receiver body:[NSString stringWithFormat:@"%@:%@",nickName,content]];
                }
            }
        }
    } fail:^(int code, NSString *msg) {
        NSLog(@"error=%d,%@",code,msg);
        
        CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
        CJDatabaseData *model = [manager findWithUserId:[CJUserManager getUid] AndType:@"friend" AndKey:receiver AndNeedOpen:YES];
        
        NSDictionary *data = [NSDictionary dictionaryWithJsonString:model.value];
        
        if (data){
            if ([data objectForKey:@"logo"]){
                [message setObject:[data objectForKey:@"logo"] forKey:@"logo"];
            }else{
                [message setObject:@"" forKey:@"logo"];
            }
            
            if ([data objectForKey:@"nickName"]){
                [message setObject:[data objectForKey:@"nickName"] forKey:@"nickName"];
            }else{
                [message setObject:@"" forKey:@"nickName"];
            }
        }else{
            [message setObject:@"" forKey:@"logo"];
            [message setObject:@"" forKey:@"nickName"];
        }
        
        
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:@"success" forKey:@"type"];
        [dic setObject:@"success" forKey:@"content"];
        [dic setObject:message forKey:@"data"];
        
        [_instance fireGlobalEvent:@"onMessage" params:[[NSDictionary alloc] initWithObjectsAndKeys:dic,@"data", nil]];
        
        
        if ([type isEqualToString:@"receive"]){
            if ([receiver containsString:@"gm"]){
                [SharedAppDelegate actionLocalNotificationWithSender:nil body:[NSString stringWithFormat:@"%@:%@",receiver,content]];
            }else{
                [SharedAppDelegate actionLocalNotificationWithSender:receiver body:[NSString stringWithFormat:@"%@:%@",receiver,content]];
            }
        }
        
    }];
    
    
    
    
    CJPostNotification(CJNOTIFICATION_IM_UNREAD_COUNT, nil);
}

- (void)notificationImUnreadCount:(NSNotification *)notification{
    if ([self.label isEqualToString:@"message"]){
        if ([[TIMManager sharedInstance] getLoginUser]){
            NSInteger unReadCount = [IMManager getUnReadCount];
            NSNumber *number = [NSNumber numberWithInteger:unReadCount];
            NSString *badgeValue = [NSString string];
            if ([number integerValue] > 99){
                badgeValue = @"···";
            }else if ([number integerValue] > 0){
                badgeValue = [number stringValue];
            }else{
                badgeValue = nil;
            }
            WXPerformBlockOnMainThread(^{
                [self.tabBarController.tabBar.items objectAtIndex:3].badgeValue = badgeValue;
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:unReadCount];
            });
        }
    }
}

- (void)notificationWXSendGlobalEvent:(NSNotification *)notification{
    NSDictionary *dic = notification.userInfo;
    NSString *eventKey = [dic objectForKey:@"eventKey"];
    id data = [dic objectForKey:@"data"];
    [_instance fireGlobalEvent:eventKey params:data];
}
@end
