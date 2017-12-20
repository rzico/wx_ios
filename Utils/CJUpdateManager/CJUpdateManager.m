//
//  CJUpdateManager.m
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJUpdateManager.h"
#import <ZipArchive.h>
#import "AFHTTPRequestOperation.h"

@interface CJUpdateManager ()<UIAlertViewDelegate>

@property (nonatomic, assign) BOOL isUpdating;

@end

@implementation CJUpdateManager

+ (CJUpdateManager *)sharedInstance {
    static dispatch_once_t once;
    static CJUpdateManager *instance;
    dispatch_once(&once, ^{
        instance = [self new];
        instance.isUpdating = false;
    });
    return instance;
}

- (void)checkUpdate{
    if (_isUpdating){
        if (_delegate){
            [_delegate updateWithResult:UpdateResultUpdating];
        }
        return;
    }else{
        _isUpdating = true;
        if ([self checkUpdateOfLocalResource]){
            [self checkUpdateOfRemoteInfo];
        }else{
            [self updateComplete:UpdateResultReleaseERROR];
        }
    }
}

- (NSDictionary *)getResourceInfo{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"CJResourceInfo"];
}

- (void)saveResourceInfo:(NSDictionary *)info{
    if (info){
        [[NSUserDefaults standardUserDefaults] setObject:info forKey:@"CJResourceInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)checkUpdateOfLocalResource{
    if (![self getResourceInfo]){
        NSString *zipPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"res.zip"];
        if ([self releaseZip:zipPath]){
            NSDictionary *resInfo = @{@"resVersion":localResVersion};
            [self saveResourceInfo:resInfo];
            return true;
        }
    }else{
        return true;
    }
    return false;
}

- (void)checkUpdateOfRemoteInfo{
    NSURL *url = [NSURL URLWithString:HTTPAPI(@"common/resources")];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15];
    [request setValue:[UIDevice getUserAgent] forHTTPHeaderField:@"User-Agent"];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError){
            //连接服务器失败
            [self updateComplete:UpdateResultConnectionERROR];
        }else{
            NSDictionary *json = [NSDictionary dictionaryWithJsonData:data];
            if (json && [[json objectForKey:@"type"] isEqualToString:@"success"]){
                NSDictionary *info = [json objectForKey:@"data"];
                if (info && [info objectForKey:@"minVersion"] && [info objectForKey:@"appVersion"]){
                    self.resourceInfo = info;
                    if ([self checkAppUpdate:[info objectForKey:@"minVersion"]]){
                        //当前app版本号低于最低版本，强制更新
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"重要更新" message:@"当前版本过低，需要更新" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                            [alert show];
                        });
                    }else if ([self checkAppUpdate:[info objectForKey:@"appVersion"]]){
                        //当前app版本号低于最新版本，提示更新
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新提示" message:@"有新版本可以更新" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                            [alert show];
                        });
                    }else{
                        //当前app为最新版本，检查资源包更新
                        [self checkUpdateOfRemoteResource:info];
                    }
                }else{
                    //返回data不包含minVersion或appVersion字段
                    [self updateComplete:UpdateResultGetResInfoERROR];
                }
            }else{
                //返回json不包含type字段或者type字段不为success
                [self updateComplete:UpdateResultGetResInfoERROR];
            }
        }
    }];
}

- (void)checkUpdateOfRemoteResource:(NSDictionary *)info{
    if ([info objectForKey:@"resUrl"] && [info objectForKey:@"resVersion"]){
        BOOL isNeedToUpdate = [self needUpdateResource:[info objectForKey:@"resVersion"]];
        if (isNeedToUpdate){
            unsigned long timeInterval = [[NSDate date] timeIntervalSince1970] * 1000;
            NSString *urlStr = [NSString stringWithFormat:@"%@?rand=%lu",[info objectForKey:@"resUrl"],timeInterval];
            NSURL *url = [NSURL URLWithString:urlStr];
            
            NSString *path = [CACHES_PATH stringByAppendingPathComponent:@"temp.zip"];
            
            //初始化请求
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60];
            
            //初始化队列
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            op.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
            
            [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                double progress = (double)totalBytesRead/totalBytesExpectedToRead;
                
                [_delegate updateWithDownloadProgress:progress];
            }];
            
            [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                BOOL releaseResult = [self releaseZip:path];
                if (releaseResult){
                    //更新成功
                    [self saveResourceInfo:info];
                    [self updateComplete:UpdateResultSuccess];
                }else{
                    //解压资源失败
                    [self updateComplete:UpdateResultReleaseERROR];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self updateComplete:UpdateResultDownloadERROR];
            }];
            
            //开始下载
            [queue addOperation:op];
        }else{
            //无需更新
            [self updateComplete:UpdateResultSuccess];
        }
    }else{
        //返回data不包含resUrl或resVersion字段
        [self updateComplete:UpdateResultGetResInfoERROR];
    }
}

- (BOOL)needUpdateResource:(NSString *)version{
#ifndef DEBUG
    NSDictionary *resInfo = [self getResourceInfo];
    return (!resInfo || ![[resInfo objectForKey:@"resVersion"] isEqualToString:version]);
#else
    return YES;
#endif
}

- (BOOL)checkAppUpdate:(NSString *)version{
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *localVersion = [info objectForKey:@"CFBundleShortVersionString"];
    NSArray *localArray = [localVersion componentsSeparatedByString:@"."];
    NSArray *remoteArray = [version componentsSeparatedByString:@"."];
    NSInteger minLength = MIN(localArray.count, remoteArray.count);
    
    BOOL needUpdate = NO;
    for (int i = 0; i < minLength; i ++){
        NSString *localElement = localArray[i];
        NSString *remoteElement = remoteArray[i];
        
        NSInteger localValue = localElement.integerValue;
        NSInteger remoteValue = remoteElement.integerValue;
        
        if (localValue < remoteValue){
            needUpdate = YES;
            break;
        }else{
            needUpdate = NO;
        }
    }
    
    return needUpdate;
}

- (BOOL)releaseZip:(NSString *)source{
    ZipArchive *zip = [[ZipArchive alloc] init];
    if ([zip UnzipOpenFile:source]){
        NSString *path = [DOCUMENT_PATH stringByAppendingPathComponent:@"resource"];
        BOOL result = [zip UnzipFileTo:path overWrite:YES];
        [zip UnzipCloseFile];
        return result;
    }
    return false;
}

- (void)updateComplete:(UpdateResult)result{
    _isUpdating = false;
    if (_delegate){
        [_delegate updateWithResult:result];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"重要更新"]){
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[self.resourceInfo objectForKey:@"appUrl"]]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    }else{
        switch (buttonIndex) {
            case 0:
                [self checkUpdateOfRemoteResource:self.resourceInfo];
                break;
            case 1:
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[self.resourceInfo objectForKey:@"appUrl"]]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    exit(0);
                });
                break;
            default:
                break;
        }
    }
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}
@end
