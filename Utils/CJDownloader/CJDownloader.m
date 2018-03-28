//
//  CJDownloader.m
//  Weex
//
//  Created by macOS on 2018/1/10.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJDownloader.h"

@interface CJDownloader () <NSURLSessionDownloadDelegate>{
    NSString *_url;
    NSString *_path;
}

@end

@implementation CJDownloader

- (void)downloadFileWithURL:(NSString *)urlStr{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:url];
    [downloadTask resume];
}

- (void)downloadFileWithURL:(NSString *)urlStr writeToPath:(NSString *)path{
    _path = path;
    [self downloadFileWithURL:urlStr];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    NSLog(@"didFinishDownloadingToURL:%@",location);
    NSError *error;
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (_path){
        if ([fileMgr fileExistsAtPath:_path]){
            [fileMgr removeItemAtPath:_path error:&error];
            if (error){
                _complete(CJDownloaderResultRemoveExistFileError, nil);
                return;
            }
        }
        error = nil;
        [fileMgr moveItemAtURL:location toURL:[NSURL fileURLWithPath:_path] error:&error];
        if (error){
            _complete(CJDownloaderResultSaveFileError, nil);
        }else{
            _complete(CJDownloaderResultSuccess, _path);
        }
    }else{
        _complete(CJDownloaderResultSuccess, [location absoluteString]);
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (_progress){
        _progress(totalBytesWritten, totalBytesExpectedToWrite);
    }
    NSLog(@"%@",[NSString stringWithFormat:@"下载进度:%f",(double)totalBytesWritten/totalBytesExpectedToWrite]);
}

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error{
    NSLog(@"InvalidWithError:%@",error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error){
        _complete(CJDownloaderResultDownloadError, nil);
    }
}
@end
