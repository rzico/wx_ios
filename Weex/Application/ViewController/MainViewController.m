//
//  MainViewController.m
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#define KProgressBorderWidth 2.0f
#define KProgressPadding 1.0f

#import "MainViewController.h"
#import <WeexSDK.h>
#import "CJUpdateManager.h"
#import "CJWeexViewController.h"
#import "IMManager.h"

@interface MainViewController ()<CJUpdateDelegate, UIAlertViewDelegate>

@end

@implementation MainViewController{
    NSArray *handlerArray;
    NSArray *componentArray;
    NSArray *moduleArray;
    
    UIView *borderView;
    UIView *progressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setBackgroundImage];
    [self setUpProcessView];
}



- (void)setBackgroundImage{
    //获取启动图
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = @"Portrait";
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for(NSDictionary* dict in imagesDict) {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if(CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
            launchImage = dict[@"UILaunchImageName"];
            break;
        }
    }
    
    UIColor *launchColor = [UIColor colorWithPatternImage:[UIImage imageNamed:launchImage]];
    self.view.backgroundColor = launchColor;
}

- (void)setUpProcessView{
    CGRect frame = CGRectMake([UIScreen getWidth] * 0.2, [UIDevice isIphoneX] ? [UIScreen getHeight] - 34 - 50 : [UIScreen getHeight] - 30, [UIScreen getWidth] * 0.6, 10);
    //边框
    borderView = [[UIView alloc] initWithFrame:frame];
    borderView.layer.cornerRadius = borderView.height * 0.5;
    borderView.layer.masksToBounds = true;
    borderView.backgroundColor = [UIColor whiteColor];
    
    //颜色
    UIColor *progressColor = [UIColor colorWithHex:UINavigationBarColor];
    borderView.layer.borderColor = [progressColor CGColor];
    borderView.layer.borderWidth = KProgressBorderWidth;
    [self.view addSubview:borderView];
    
    //进度
    progressView = [[UIView alloc] init];
    progressView.backgroundColor = progressColor;
    progressView.layer.cornerRadius = (borderView.height - (KProgressBorderWidth + KProgressPadding) * 2) * 0.5;
    progressView.layer.masksToBounds = true;
    [borderView addSubview:progressView];
}

- (void)setProgress:(CGFloat)progress{
    CGFloat margin = KProgressBorderWidth + KProgressPadding;
    CGFloat maxWidth = borderView.width - margin * 2;
    CGFloat height = borderView.height - margin * 2;
    
    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        progressView.frame = CGRectMake(margin, margin, maxWidth * progress, height);
    } completion:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self navigationBarAppearance];
    [WXApi registerApp:WECHAT_APPID enableMTA:true];
    [self setProgress:0.05];
    [self initWeexClassArray];
    [self setProgress:0.1];
    [self initWeexSDK];
    [self removeMNT:^{
        [self setProgress:0.2];
        [CJUpdateManager sharedInstance].delegate = self;
        [[CJUpdateManager sharedInstance] checkUpdate];
    }];
}

- (void)viewWillDisappear:(BOOL)animated{
    [CJUpdateManager sharedInstance].delegate = nil;
    [self.view removeSubviews];
    borderView = nil;
    progressView = nil;
}

- (void)removeMNT:(void(^)(void))complete{
    __block BOOL isComplete = false;
    dispatch_async(dispatch_queue_create(nil, nil), ^{
        while (!isComplete) {
            WXPerformBlockOnMainThread(^{
                for (UIWindow *window in [UIApplication sharedApplication].windows){
                    if ([window isKindOfClass:NSClassFromString(@"WXWindow")]){
                        [window removeSubviews];
                        [window setHidden:true];
                        [window setWindowLevel:0];
                        isComplete = true;
                        complete();
                        break;
                    }
                }
            });
            [NSThread sleepForTimeInterval:0.1];
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initWeexClassArray{
        handlerArray = [[NSArray alloc] initWithObjects:
                        @{@"class":@"CJImgLoaderDefaultImpl",   @"protocol":@"WXImgLoaderProtocol"},
                        @{@"class":@"CJEventModule",            @"protocol":@"WXEventModuleProtocol"},
                        @{@"class":@"CJConfigCenterDefaultImpl",@"protocol":@"WXConfigCenterProtocol"},
                        @{@"class":@"CJNetworkDefaultImpl",     @"protocol":@"WXResourceRequestHandler"},
                        @{@"class":@"CJURLRewriteImpl",         @"protocol":@"WXURLRewriteProtocol"},
                        nil];
//
        componentArray = [[NSArray alloc] initWithObjects:
                          @{@"class":@"CJSelectComponent",      @"name":@"select"},
                          @{@"class":@"CJWebComponent",         @"name":@"web"},
                          nil];
//
        moduleArray = [[NSArray alloc] initWithObjects:
                       @{@"class":@"CJEventModule",     @"name":@"event"},
                       @{@"class":@"CJAlbumModule",     @"name":@"album"},
                       @{@"class":@"CJAudioModule",     @"name":@"audio"},
                       @{@"class":@"CJPhoneModule",     @"name":@"phone"},
                       @{@"class":@"CJModalModule",     @"name":@"modal"},
                       @{@"class":@"CJWebviewModule",   @"name":@"webview"},
                       @{@"class":@"CJStreamModule",    @"name":@"stream"},
                       nil];
}

- (void)initWeexSDK{
    [WXAppConfiguration setAppGroup:@"XMApp"];
    [WXAppConfiguration setAppName:@"Weex"];
    [WXAppConfiguration setExternalUserAgent:@"ExternalUA"];
    
    [WXSDKEngine initSDKEnvironment];
    
    for (NSDictionary *handler in handlerArray){
        [WXSDKEngine registerHandler:[NSClassFromString([handler objectForKey:@"class"]) new] withProtocol:NSProtocolFromString([handler objectForKey:@"protocol"])];
    }
    
    handlerArray = nil;
    
    for (NSDictionary *compoent in componentArray){
        [WXSDKEngine registerComponent:[compoent objectForKey:@"name"] withClass:NSClassFromString([compoent objectForKey:@"class"])];
    }
    
    componentArray = nil;
    
    for (NSDictionary *module in moduleArray){
        [WXSDKEngine registerModule:[module objectForKey:@"name"] withClass:NSClassFromString([module objectForKey:@"class"])];
    }
    
    moduleArray = nil;
#ifdef DEBUG
    [WXDebugTool setDebug:true];
    [WXLog setLogLevel:WXLogLevelInfo];
#else
    [WXDebugTool setDebug:false];
    [WXLog setLogLevel:WXLogLevelOff];
#endif
}

- (void)navigationBarAppearance{
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithHex:UINavigationBarColor]];
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithHex:UINavigationBarColor]];
    //    [[UINavigationBar appearance] setBackgroundColor:[UIColor clearColor]];
    //    [[UINavigationBar appearance] setBarTintColor:[UIColor clearColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:19]}];
    //    UIImage *backButtonImage = [[UIImage imageNamed:@"back"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    //    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //
    
}


- (void)updateWithDownloadProgress:(CGFloat)progress{
    [self setProgress:0.2 + progress * 0.7];
}

- (void)updateWithResult:(UpdateResult)complete{
    switch (complete) {
        case UpdateResultConnectionERROR:
            [self updateOnError:@"连接服务器失败"];
            break;
        case UpdateResultGetResInfoERROR:
            [self updateOnError:@"获取数据失败"];
            break;
        case UpdateResultDownloadERROR:
            [self updateOnError:@"数据下载失败"];
            break;
        case UpdateResultReleaseERROR:
            [self updateOnError:@"解压数据失败"];
            break;
        case UpdateResultNoUpdate:
            [self updateOnSuccess];
            break;
        case UpdateResultSuccess:
            [self updateOnSuccess];
            break;
        case UpdateResultUpdating:
            break;
        default:
            break;
    }
}


- (void)checkAuthentication{
    [self setProgress:0.95];
    [CJNetworkManager GetHttp:HTTPAPI(@"login/isAuthenticated") Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        //获取用户信息成功
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
            if ([[responseObject objectForKey:@"type"] isEqualToString:@"success"] && [[[responseObject objectForKey:@"data"] objectForKey:@"loginStatus"] boolValue]){
                [CJUserManager setUser:[responseObject objectForKey:@"data"]];
                [self requestRouter];
                return;
            }
        }
        [SharedAppDelegate logOut:nil];
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        //如果存在登录信息，尝试获取路由
        if ([CJUserManager getUid] > 0){
            [self requestRouter];
        }else{
            [self alertErrorMessage:@"获取用户信息失败" title:nil];
        }
    }];
}


- (void)requestRouter{
    [self setProgress:1.0];
    NSString *url = [NSString stringWithFormat:@"common/router.jhtml?rand=%ld",(long)[[NSDate date] timeIntervalSince1970]];
    [CJNetworkManager GetHttp:HTTPAPI(url) Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([[responseObject objectForKey:@"type"] isEqualToString:@"success"]){
                NSDictionary *data = [responseObject objectForKey:@"data"];
                if (data){
                    data = [data objectForKey:@"tabnav"];
                }
                [data writeToFile:[DOCUMENT_PATH stringByAppendingPathComponent:@"router.plist"] atomically:YES];
                [self loginIm:data];
            }
        }
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [self offlineState];
    }];
}

- (void)updateOnError:(NSString *)error{
    static int count = 0;
    if ([[AFNetworkReachabilityManager sharedManager] isReachable]){
        if (count < 2){
            count ++;
            [[CJUpdateManager sharedInstance] checkUpdate];
        }else{
            if ([CJUserManager getUid] > 0){
                [self checkAuthentication];
            }else{
                [self alertErrorMessage:error title:nil];
            }
        }
    }else{
        [self offlineState];
    }
}

- (void)loginIm:(NSDictionary *)data{
    [[IMManager sharedInstance] loginWithUser:[CJUserManager getUser] loginOption:IMManagerLoginOptionForce andBlock:^(BOOL success) {
        CJPostNotification(CJNOTIFICATION_INITIALIZED,data);
    }];
}

- (void)offlineLoginIm{
    [[IMManager sharedInstance] loginWithUser:[CJUserManager getUser] loginOption:IMManagerLoginOptionOffline andBlock:^(BOOL success) {
        CJPostNotification(CJNOTIFICATION_INITIALIZED,nil);
    }];
}

- (void)offlineState{
    [self setProgress:0.95];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[DOCUMENT_PATH stringByAppendingPathComponent:@"router.plist"]] && [CJUserManager getUid] > 0){
        //路由存在，且已登录允许离线模式
        [self offlineLoginIm];
    }else{
        [self alertErrorMessage:@"未连接到互联网，请检查网络设置" title:[NSString stringWithFormat:@"“%@” 网络提示",DisplayName]];
    }
}

- (void)alertErrorMessage:(NSString *)error title:(NSString *)title{
    WXPerformBlockOnMainThread(^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:error delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    });
}

- (void)updateOnSuccess{
    [self checkAuthentication];
}

- (void)dealloc{
    NSLog(@"main dealloc");
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (![[AFNetworkReachabilityManager sharedManager] isReachable]){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                exit(0);
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                exit(0);
            });
        }
    }else{
        exit(0);
    }
}
@end
