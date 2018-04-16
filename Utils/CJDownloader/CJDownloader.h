//
//  CJDownloader.h
//  Weex
//
//  Created by macOS on 2018/1/10.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CJDownloaderResult) {
    CJDownloaderResultDownloadError = 0,
    CJDownloaderResultRemoveExistFileError,
    CJDownloaderResultSaveFileError,
    CJDownloaderResultSuccess
};

typedef void(^CJDownloaderProgress)(int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite);
typedef void(^CJDownloaderComplete)(CJDownloaderResult result ,NSString *filePath);

@interface CJDownloader : NSObject

@property (nonatomic, strong) CJDownloaderProgress progress;
@property (nonatomic, strong) CJDownloaderComplete complete;

- (void)downloadFileWithURL:(NSString *)urlStr;
- (void)downloadFileWithURL:(NSString *)urlStr writeToPath:(NSString *)path;
@end
