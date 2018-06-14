//
//  CJLivePlayerViewController.m
//  Weex
//
//  Created by macOS on 2018/1/30.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJGameViewController.h"
#import <WebKit/WebKit.h>

#import <TXLivePlayer.h>
#import <TXLivePlayConfig.h>
#import "HttpHead+Utils.h"
@interface CJGameViewController () <WKNavigationDelegate, TXLivePlayListener>

@property (nonatomic, strong) WKWebView *webview;

@property (nonatomic, strong) TXLivePlayer *txLivePlayer;

@property (nonatomic, strong) GameClosedBlock closedCallback;

@end

@implementation CJGameViewController{
    CGRect                  _videoWidgetFrame;
    NSString                *_rtmpUrl;
    UIView                  *_mVideoContainer;
    TXLivePlayConfig        *_config;
    BOOL                    _isPlaying;
    BOOL                    _isPause;
    UIImageView             *backgroundImage;
    
    CGFloat                 _viewWidth;
    CGFloat                 _viewHeight;
}

- (void)initUI{
    if (self.type == CJGameTypeLandscape){
        _viewWidth = [UIScreen mainScreen].bounds.size.height;
        _viewHeight = [UIScreen mainScreen].bounds.size.width;
    }else{
        _viewWidth = [UIScreen mainScreen].bounds.size.width;
        _viewHeight = [UIScreen mainScreen].bounds.size.width * 0.5625;
    }
    [self initPlayerUI];
    [self initWebUI];
}

- (void)initPlayerUI{
    CGRect frame;
    frame = CGRectMake(0, 0, _viewWidth, _viewHeight);
    _videoWidgetFrame = frame;
    _rtmpUrl = [NSString string];
    
    _mVideoContainer = [[UIView alloc] initWithFrame:_videoWidgetFrame];
    [self.view insertSubview:_mVideoContainer atIndex:0];
    //    _mVideoContainer.center = self.view.center;
    
    _txLivePlayer = [[TXLivePlayer alloc] init];
    _txLivePlayer.delegate = self;
    [_txLivePlayer setupVideoWidget:CGRectMake(0, 0, 0, 0) containView:_mVideoContainer insertIndex:0];
    
    _config = [[TXLivePlayConfig alloc] init];
    _config.playerPixelFormatType = kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
    [_txLivePlayer setConfig:_config];
    
    _mVideoContainer.backgroundColor = [UIColor blackColor];
    backgroundImage = [[UIImageView alloc] initWithFrame:_videoWidgetFrame];
    backgroundImage.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"launch.jpg"]];
    [self.view addSubview:backgroundImage];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((backgroundImage.width - 200) * 0.5, (backgroundImage.height - 50) * 0.5, 200, 50)];
    label.text = @"游戏载入中...";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor orangeColor];
    [backgroundImage addSubview:label];
}

- (void)initWebUI{
    //    _webview = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, _viewWidth, _viewHeight)];
    _webview.navigationDelegate = self;
    _webview.opaque = false;
    _webview.backgroundColor = [UIColor clearColor];
    
    _webview.scrollView.alwaysBounceVertical = false;
    _webview.scrollView.alwaysBounceHorizontal = false;
    [self.view addSubview:_webview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (instancetype)initWithType:(CJGameType)type{
    self = [super init];
    self.type = type;
    [self initUI];
    return self;
}

- (void)loadWithUrl:(NSString *)url video:(NSString *)video method:(NSString *)method callback:(void (^)(void))callback{
    _closedCallback = callback;
    [self loadUrl:url method:method];
    [self play:video];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (backgroundImage){
            [backgroundImage removeFromSuperview];
        }
    });
}

- (void)loadUrl:(NSString *)url method:(NSString *)method{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *URL = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
        [request setHTTPMethod:method];
        NSDictionary *headDic = [HttpHead_Utils getHttpHead];
        if (headDic){
            for (NSString *key in headDic.allKeys){
                NSString *value = headDic[key];
                [request setValue:value forHTTPHeaderField:key];
            }
        }
        [self.webview loadRequest:request];
    });
}

- (void)play:(NSString *)url{
    dispatch_async(dispatch_get_main_queue(), ^{
        _rtmpUrl = url;
        int result = [_txLivePlayer startPlay:_rtmpUrl type:PLAY_TYPE_LIVE_RTMP];
        if (result != 0){
            return;
        }
        //        [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
        //        [_txLivePlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
        [_txLivePlayer setRenderRotation:HOME_ORIENTATION_DOWN];
        [_txLivePlayer setRenderMode:RENDER_MODE_FILL_SCREEN];
        _isPlaying = true;
        _isPause = false;
    });
}

- (void)stop{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.txLivePlayer pause];
        BOOL stop = [self.txLivePlayer stopPlay];
        NSLog(@"stop=%d",stop);
        [self.txLivePlayer removeVideoWidget];
        self.txLivePlayer.delegate = nil;
        self->_isPlaying = false;
        self->_isPause = false;
        self.txLivePlayer = nil;
        
        [self.webview removeFromSuperview];
        self.webview = nil;
    });
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

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)destroy{
    [self stop];
    if (_closedCallback){
        _closedCallback();
        _closedCallback = nil;
    }
    if (self.type == CJGameTypeLandscape){
        [self dismissViewControllerAnimated:true completion:nil];
    }else{
        [self.parentViewController removeChild:self];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidEnterBackGround:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)onAppDidEnterBackGround:(UIApplication*)app {
    NSLog(@"onAppDidEnterBackGround");
    [self pause];
}

- (void)onAppWillEnterForeground:(UIApplication*)app {
    NSLog(@"onAppWillEnterForeground");
    [self resume];
}

- (void)onAppDidBecomeActive:(UIApplication*)app {
    NSLog(@"onAppDidBecomeActive");
    [self resume];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    NSMutableURLRequest *request = (NSMutableURLRequest *)navigationAction.request;
    if ([[request.URL scheme] isEqualToString:@"http"] || [[request.URL scheme] isEqualToString:@"https"]){
        if ([request.URL.path hasPrefix:@"/home"]){
            if (self.type == CJGameTypeLandscape){
                [self destroy];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
        }else{
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }else{
        NSLog(@"cancel=%@",navigationAction.request.URL);
        decisionHandler(WKNavigationActionPolicyCancel);
        if ([navigationAction.request.URL isContains:@"volume"]){
            if (backgroundImage){
                [backgroundImage removeFromSuperview];
            }
        }
    }
}

#pragma mark TXLivePlayListener
- (void)onPlayEvent:(int)EvtID withParam:(NSDictionary *)param{
    NSLog(@"EvtId=%d",EvtID);
    if (EvtID == PLAY_ERR_NET_DISCONNECT){
        [SVProgressHUD showErrorWithStatus:@"获取视频流失败"];
        [self stop];
    }else if (EvtID == PLAY_EVT_RCV_FIRST_I_FRAME){
        [backgroundImage removeFromSuperview];
    }
}

- (void)onNetStatus:(NSDictionary *)param{
    
}
@end




