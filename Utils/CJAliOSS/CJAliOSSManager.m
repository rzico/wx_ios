//
//  CJAliOSSManager.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJAliOSSManager.h"
#import <AliyunOSSiOS/OSSService.h>
#import "CJDatabaseManager.h"
#import "CJNetworkManager.h"
#import "CJUserManager.h"
#import "CJAliOSSData.h"

OSSClient * client;

typedef void(^GetOSSDataBlock)(BOOL success);

@implementation CJAliOSSManager

+ (CJAliOSSManager *)defautManager{
    static CJAliOSSManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [CJAliOSSManager new];
        [OSSLog disableLog];
    });
    return manager;
}

- (void)getOSSData:(GetOSSDataBlock)block{
    CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
    CJDatabaseData *sqlData = [manager findWithUserId:[CJUserManager getUid] AndType:@"httpCache" AndKey:@"STS" AndNeedOpen:YES];
    if (sqlData){
        CJAliOSSData *ossData = [[CJAliOSSData alloc] initWithString:sqlData.value error:nil];
        NSTimeInterval interval = [NSDate GetTimeIntervalFromUTCString:ossData.Expiration];
        NSLog(@"interval=%lf",3600 - interval);
        if (3600 - interval >= 2 * 60){
            NSLog(@"flushToken=YES");
            [self flushToken:block];
        }else{
            NSLog(@"flushToken=NO");
            [self initOSSClient:ossData];
            if (block){
                block(YES);
            }
        }
    }else{
        NSLog(@"firstTimeToGetToken");
        [self flushToken:block];
    }
}

- (void)flushToken:(GetOSSDataBlock)block{
    [CJNetworkManager GetHttp:HTTPAPI(@"member/oss/sts") Parameters:nil Success:^(NSURLSessionDataTask *task, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] isEqualToString:@"success"]){
                CJAliOSSData *data = [[CJAliOSSData alloc] initWithDictionary:[responseObject objectForKey:@"data"] error:nil];
                CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
                CJDatabaseData *model = [CJDatabaseData new];
                model.userId = [NSString stringWithFormat:@"%tu",[CJUserManager getUid]];
                model.type = @"httpCache";
                model.key = @"STS";
                model.value = [data toJSONString];
                model.sort = @"";
                NSUInteger saveId = [manager save:model];
                NSLog(@"saveId = %tu",saveId);
                [self initOSSClient:data];
                if (block){
                    block(YES);
                }
        }else{
            block(NO);
        }
    } andFalse:^(NSURLSessionDataTask *task, NSError * _Nonnull error) {
        NSLog(@"error=%@",error);
        block(NO);
    }];
}

- (void)initOSSClient:(CJAliOSSData *)data{
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:data.AccessKeyId secretKeyId:data.AccessKeySecret securityToken:data.SecurityToken];
    
    OSSClientConfiguration *config = [OSSClientConfiguration new];
    config.maxRetryCount = 2;
    config.timeoutIntervalForRequest = 30;
    config.timeoutIntervalForResource = 24 * 60 * 60;
    
    client = [[OSSClient alloc] initWithEndpoint:aliOSSEndPoint credentialProvider:credential clientConfiguration:config];
}

- (void)uploadObjectAsyncWithData:(NSData *)data progress:(CJAliOSSProgressBlock)progress complete:(CJAliOSSCompleteBlock)complete{
    [self getOSSData:^(BOOL success) {
        if (success){
            OSSPutObjectRequest * put = [OSSPutObjectRequest new];
            
            // required fields
            
            NSString *date = [NSDate DateWithFormat:@"yyyy/MM/dd"];
            
            NSString *md5 = [OSSUtil dataMD5String:data];
            
            put.bucketName = aliOSSBucketName;
            put.objectKey = [NSString stringWithFormat:@"upload/images/%@/%@.jpg",date,md5];
            put.uploadingData = data;
            
            // optional fields
            put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
                progress([NSString stringWithFormat:@"%.2lf",((double_t)totalByteSent / (double_t)totalBytesExpectedToSend) * 100]);
            };
            put.contentType = @"";
            put.contentMd5 = @"";
            put.contentEncoding = @"";
            put.contentDisposition = @"";
            
            OSSTask * putTask = [client putObject:put];
            
            [putTask continueWithBlock:^id(OSSTask *task) {
                if (!task.error) {
                    NSLog(@"upload object success!");
                    if (complete){
                        complete(CJAliOSSUploadResultSuccess , [WXCONFIG_RESOURCE_PATH stringByAppendingString:put.objectKey]);
                    }
                } else {
                    NSLog(@"upload object failed, error: %@" , task.error);
                    if (complete){
                        complete(CJAliOSSUploadResultUploadError ,nil);
                    }
                }
                return nil;
            }];
        }else{
            if (complete){
                complete(CJAliOSSUploadResultSTSError ,nil);
            }
        }
    }];
}

- (void)uploadObjectAsyncWithPath:(NSString *)path progress:(CJAliOSSProgressBlock)progress complete:(CJAliOSSCompleteBlock)complete{
    [self getOSSData:^(BOOL success) {
        if (success){
            OSSPutObjectRequest * put = [OSSPutObjectRequest new];
            
            // required fields
            
            NSString *date = [NSDate DateWithFormat:@"yyyy/MM/dd"];
            
            
            NSString *filePath = [path rewriteURL];
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                complete(CJAliOSSUploadResultFileNotFound, nil);
                return;
            }
            
            NSURL *fileUrl;
            if ([filePath hasPrefix:@"/"]){
                fileUrl = [NSURL fileURLWithPath:filePath];
            }else{
                fileUrl = [NSURL URLWithString:filePath];
            }
            
            NSString *md5 = [OSSUtil fileMD5String:filePath];
            
            put.bucketName = aliOSSBucketName;
            put.objectKey = [NSString stringWithFormat:@"upload/images/%@/%@.%@",date,md5,[fileUrl pathExtension]];
            put.uploadingFileURL = fileUrl;
            
            // optional fields
            put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
                progress([NSString stringWithFormat:@"%.2lf",((double_t)totalByteSent / (double_t)totalBytesExpectedToSend) * 100]);
            };
            put.contentType = @"";
            put.contentMd5 = @"";
            put.contentEncoding = @"";
            put.contentDisposition = @"";
            
            OSSTask * putTask = [client putObject:put];
            
            [putTask continueWithBlock:^id(OSSTask *task) {
                if (!task.error) {
                    NSLog(@"upload object success!");
                    if (complete){
                        complete(CJAliOSSUploadResultSuccess , [WXCONFIG_RESOURCE_PATH stringByAppendingString:put.objectKey]);
                    }
                } else {
                    NSLog(@"upload object failed, error: %@" , task.error);
                    if (complete){
                        complete(CJAliOSSUploadResultUploadError ,nil);
                    }
                }
                return nil;
            }];
        }else{
            if (complete){
                complete(CJAliOSSUploadResultSTSError ,nil);
            }
        }
    }];
}

- (void)multipartUploadObjectAsyncWithPath:(NSString *)path progress:(CJAliOSSProgressBlock)progress complete:(CJAliOSSCompleteBlock)complete{
    __block NSString *fileUrl;
    
    fileUrl = [path hasPrefix:@"/"] ? [NSString stringWithFormat:@"file://%@",path] : path;
    
    __block NSString * recordKey;
    
    NSString *date = [NSDate DateWithFormat:@"yyyy/MM/dd"];
    NSString *md5 = [OSSUtil fileMD5String:path];
    
    NSString *objectKey = [NSString stringWithFormat:@"upload/images/%@/%@.%@",date,md5,[path pathExtension]];
    
    [[[[[[OSSTask taskWithResult:nil] continueWithBlock:^id(OSSTask *task) {
        // 为该文件构造一个唯一的记录键
        NSURL * fileURL = [NSURL URLWithString:fileUrl];
        NSDate * lastModified;
        NSError * error;
        [fileURL getResourceValue:&lastModified forKey:NSURLContentModificationDateKey error:&error];
        if (error) {
            return [OSSTask taskWithError:error];
        }
        recordKey = [NSString stringWithFormat:@"%@-%@-%@-%@", aliOSSBucketName, objectKey, [OSSUtil getRelativePath:path], lastModified];
        // 通过记录键查看本地是否保存有未完成的UploadId
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        return [OSSTask taskWithResult:[userDefault objectForKey:recordKey]];
    }] continueWithSuccessBlock:^id(OSSTask *task) {
        if (!task.result) {
            // 如果本地尚无记录，调用初始化UploadId接口获取
            OSSInitMultipartUploadRequest * initMultipart = [OSSInitMultipartUploadRequest new];
            initMultipart.bucketName = aliOSSBucketName;
            initMultipart.objectKey = objectKey;
            initMultipart.contentType = @"application/octet-stream";
            return [client multipartUploadInit:initMultipart];
        }
        OSSLogVerbose(@"An resumable task for uploadid: %@", task.result);
        return task;
    }] continueWithSuccessBlock:^id(OSSTask *task) {
        NSString * uploadId = nil;
        
        if (task.error) {
            return task;
        }
        
        if ([task.result isKindOfClass:[OSSInitMultipartUploadResult class]]) {
            uploadId = ((OSSInitMultipartUploadResult *)task.result).uploadId;
        } else {
            uploadId = task.result;
        }
        
        if (!uploadId) {
            return [OSSTask taskWithError:[NSError errorWithDomain:OSSClientErrorDomain
                                                              code:OSSClientErrorCodeNilUploadid
                                                          userInfo:@{OSSErrorMessageTOKEN: @"Can't get an upload id"}]];
        }
        // 将“记录键：UploadId”持久化到本地存储
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:uploadId forKey:recordKey];
        [userDefault synchronize];
        return [OSSTask taskWithResult:uploadId];
    }] continueWithSuccessBlock:^id(OSSTask *task) {
        // 持有UploadId上传文件
        OSSResumableUploadRequest * resumableUpload = [OSSResumableUploadRequest new];
        resumableUpload.bucketName = aliOSSBucketName;
        resumableUpload.objectKey = objectKey;
        resumableUpload.uploadId = task.result;
        resumableUpload.uploadingFileURL = [NSURL URLWithString:fileUrl];
        resumableUpload.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            NSLog(@"%lld %lld %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
            progress([NSString stringWithFormat:@"%.2lf",((double_t)totalBytesSent / (double_t)totalBytesExpectedToSend) * 100]);
        };
        return [client resumableUpload:resumableUpload];
    }] continueWithBlock:^id(OSSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:OSSClientErrorDomain] && task.error.code == OSSClientErrorCodeCannotResumeUpload) {
                // 如果续传失败且无法恢复，需要删除本地记录的UploadId，然后重启任务
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:recordKey];
                
                complete(CJAliOSSUploadResultUploadError, nil);
            }
        } else {
            NSLog(@"upload completed!");
            // 上传成功，删除本地保存的UploadId
            NSLog(@"%@",[WXCONFIG_RESOURCE_PATH stringByAppendingString:objectKey]);
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:recordKey];
            
            complete(CJAliOSSUploadResultSuccess , [WXCONFIG_RESOURCE_PATH stringByAppendingString:objectKey]);
        }
        return nil;
    }];
}

- (void)uploadObjectWithPath:(NSString *)path progress:(CJAliOSSProgressBlock)progress complete:(CJAliOSSCompleteBlock)complete{
    CJAliOSSProgressBlock Progress = ^(NSString *percent){
        if (progress){
            progress(percent);
        }
    };
    
    CJAliOSSCompleteBlock Complete = ^(CJAliOSSUploadResult result,  NSString * url){
        if (complete){
            complete(result, url);
        }
    };
    
    [self getOSSData:^(BOOL success) {
        if (success){
            NSString *filePath = [path rewriteURL];
            NSFileManager *manager = [NSFileManager defaultManager];
            if ([manager fileExistsAtPath:filePath]){
                NSError *error;
                NSDictionary *fileAttributes = [manager attributesOfItemAtPath:filePath error:&error];
                if (!error){
                    uint64_t fileSize = [fileAttributes fileSize];
                    if (fileSize > 1024 * 1024){
                        [self multipartUploadObjectAsyncWithPath:filePath progress:Progress complete:Complete];
                    }else{
                        [self uploadObjectAsyncWithPath:filePath progress:Progress complete:Complete];
                    }
                }else{
                    Complete(CJAliOSSUploadResultFileNotFound, nil);
                }
            }else{
                Complete(CJAliOSSUploadResultFileNotFound, nil);
            }
        }else{
            Complete(CJAliOSSUploadResultSTSError, nil);
        }
    }];
}
@end
