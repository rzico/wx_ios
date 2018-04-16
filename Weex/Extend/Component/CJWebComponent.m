/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "CJWebComponent.h"
#import <WXComponent_internal.h>
#import <WXUtility.h>
#import <WXHandlerFactory.h>
#import <WXURLRewriteProtocol.h>
#import <WXSDKEngine.h>

#import <JavaScriptCore/JavaScriptCore.h>

//Import Photos Framework By CJ
#import <Photos/Photos.h>

@interface CJWebView : UIWebView

@end

@implementation CJWebView

- (void)dealloc
{
    if (self) {
        //        self.delegate = nil;
    }
}

@end

@interface CJWebComponent ()

@property (nonatomic, strong) JSContext *jsContext;

@property (nonatomic, strong) CJWebView *webview;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) BOOL startLoadEvent;

@property (nonatomic, assign) BOOL finishLoadEvent;

@property (nonatomic, assign) BOOL failLoadEvent;

@property (nonatomic, assign) BOOL notifyEvent;


//Add Callback Property By CJ
@property (nonatomic, assign) CJWebComponentCallback callback;

@end

@implementation CJWebComponent

WX_EXPORT_METHOD(@selector(goBack))
WX_EXPORT_METHOD(@selector(reload))
WX_EXPORT_METHOD(@selector(goForward))

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance
{
    if (self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance]) {
        self.url = attributes[@"src"];
    }
    return self;
}

- (UIView *)loadView
{
    return [[CJWebView alloc] init];
}

- (void)viewDidLoad
{
    _webview = (CJWebView *)self.view;
    _webview.delegate = self;
    _webview.allowsInlineMediaPlayback = YES;
    _webview.scalesPageToFit = YES;
    [_webview setBackgroundColor:[UIColor clearColor]];
    _webview.opaque = NO;
    _jsContext = [_webview valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    __weak typeof(self) weakSelf = self;
    _jsContext[@"$notifyWeex"] = ^(JSValue *data) {
        if (weakSelf.notifyEvent) {
            [weakSelf fireEvent:@"notify" params:[data toDictionary]];
        }
    };
    
    if (_url) {
        [self loadURL:_url];
    }
}

- (void)updateAttributes:(NSDictionary *)attributes
{
    if (attributes[@"src"]) {
        self.url = attributes[@"src"];
    }
}

- (void)addEvent:(NSString *)eventName
{
    if ([eventName isEqualToString:@"pagestart"]) {
        _startLoadEvent = YES;
    }
    else if ([eventName isEqualToString:@"pagefinish"]) {
        _finishLoadEvent = YES;
    }
    else if ([eventName isEqualToString:@"error"]) {
        _failLoadEvent = YES;
    }
}

- (void)setUrl:(NSString *)url
{
    NSString* newURL = [url copy];
    WX_REWRITE_URL(url, WXResourceTypeLink, self.weexInstance)
    if (!newURL) {
        return;
    }
    
    if (![newURL isEqualToString:_url]) {
        _url = newURL;
        if (_url) {
            [self loadURL:_url];
        }
    }
}

- (void)loadURL:(NSString *)url
{
    if (self.webview) {
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webview loadRequest:request];
    }
}

- (void)reload
{
    [self.webview reload];
}

- (void)goBack
{
    if ([self.webview canGoBack]) {
        [self.webview goBack];
    }
}

- (void)goForward
{
    if ([self.webview canGoForward]) {
        [self.webview goForward];
    }
}

- (void)notifyWebview:(NSDictionary *) data
{
    NSString *json = [WXUtility JSONString:data];
    NSString *code = [NSString stringWithFormat:@"(function(){var evt=null;var data=%@;if(typeof CustomEvent==='function'){evt=new CustomEvent('notify',{detail:data})}else{evt=document.createEvent('CustomEvent');evt.initCustomEvent('notify',true,true,data)}document.dispatchEvent(evt)}())", json];
    [_jsContext evaluateScript:code];
}

#pragma mark Webview Delegate

- (NSMutableDictionary<NSString *, id> *)baseInfo
{
    NSMutableDictionary<NSString *, id> *info = [NSMutableDictionary new];
    [info setObject:self.webview.request.URL.absoluteString ?: @"" forKey:@"url"];
    [info setObject:[self.webview stringByEvaluatingJavaScriptFromString:@"document.title"] ?: @"" forKey:@"title"];
    [info setObject:@(self.webview.canGoBack) forKey:@"canGoBack"];
    [info setObject:@(self.webview.canGoForward) forKey:@"canGoForward"];
    return info;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_finishLoadEvent) {
        NSDictionary *data = [self baseInfo];
        [self fireEvent:@"pagefinish" params:data domChanges:@{@"attrs": @{@"src":self.webview.request.URL.absoluteString}}];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (_failLoadEvent) {
        NSMutableDictionary *data = [self baseInfo];
        [data setObject:[error localizedDescription] forKey:@"errorMsg"];
        [data setObject:[NSString stringWithFormat:@"%ld", (long)error.code] forKey:@"errorCode"];
        
        NSString * urlString = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        if (urlString) {
            // webview.request may not be the real error URL, must get from error.userInfo
            [data setObject:urlString forKey:@"url"];
            if (![urlString hasPrefix:@"http"]) {
                return;
            }
        }
        [self fireEvent:@"error" params:data];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString isEqualToString:WXCONFIG_INTERFACE_PATH]){
        return NO;
    }
    if (_startLoadEvent) {
        NSMutableDictionary<NSString *, id> *data = [NSMutableDictionary new];
        [data setObject:request.URL.absoluteString ?:@"" forKey:@"url"];
        [self fireEvent:@"pagestart" params:data];
    }
    return YES;
}



/**
 生成长图
 Add getLongImage methods by CJ
 */
- (void)getLongImage:(CJWebComponentCallback)callback{
    if (!self.webview.isLoading){
        UIImage *image = [self screenShotWithScrollView:self.webview.scrollView];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        if (image){
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (success){
                    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
                    NSString *fileName = [NSString stringWithFormat:@"%.0lf",[[NSDate date] timeIntervalSince1970] * 1000];
                    fileName = [fileName stringByAppendingString:@".png"];
                    NSString *path = [self getImagePath:image];
                    
                    if (path){
                        [dic setObject:@"success" forKey:@"type"];
                        [dic setObject:@"获取成功" forKey:@"content"];
                        [dic setObject:path forKey:@"data"];
                    }else{
                        [dic setObject:@"error" forKey:@"type"];
                        [dic setObject:@"获取路径失败" forKey:@"content"];
                        [dic setObject:@"" forKey:@"data"];
                    }
                }else{
                    [dic setObject:@"error" forKey:@"type"];
                    [dic setObject:@"保存到相册失败" forKey:@"content"];
                    [dic setObject:@"" forKey:@"data"];
                }
                if (callback){
                    callback(dic);
                    _callback = nil;
                }
            }];
            
            
        }else{
            [dic setObject:@"error" forKey:@"type"];
            [dic setObject:@"生成失败" forKey:@"content"];
            [dic setObject:@"" forKey:@"data"];
        }
        if (callback){
            callback(dic);
            _callback = nil;
        }
    }else{
        _callback = callback;
    }
}

- (NSString *)getImagePath:(UIImage *)image{
    static NSString *docDir;
    static NSString *basePath;
    if (!docDir){
        docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        basePath = [NSString stringWithFormat:@"%@/LONGIMAGE",docDir];
    }
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:basePath]){
        [fm createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *timeInterval = [NSString stringWithFormat:@"%.0lf",[[NSDate date] timeIntervalSince1970]*1000];
    NSString *path = [NSString stringWithFormat:@"%@/%@.png",basePath,timeInterval];
    BOOL success = [UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
    if (success){
        NSString *localPath = [NSString stringWithFormat:@"localCachePath:///LONGIMAGE/%@.png",timeInterval];
        return localPath;
    }else{
        return nil;
    }
}

- (UIImage *)screenShotWithScrollView:(UIScrollView *)scrollView{
    UIImage *image;
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, NO, [UIScreen mainScreen].scale);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    if (image != nil){
        return image;
    }else{
        return nil;
    }
}
@end

