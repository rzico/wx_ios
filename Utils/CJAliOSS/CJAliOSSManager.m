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
        if ([responseObject isKindOfClass:[NSDictionary class]]){
            if ([[responseObject objectForKey:@"type"] isEqualToString:@"success"]){
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
                
            }
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

- (void)uploadObjectAsyncWithPath:(NSString *)path AndBlock:(CJAliOSSUploadBlock)block AndProcess:(CJAliOSSUploadProcessBlock)process{
    [self getOSSData:^(BOOL success) {
        if (success){
            OSSPutObjectRequest * put = [OSSPutObjectRequest new];
            
            // required fields
            
            NSString *date = [NSDate DateWithFormat:@"yyyy/MM/dd"];
            NSString *uuid = [NSString getUUID];
            
            NSURL *fileUrl;
            if ([path hasPrefix:@"/"]){
                fileUrl = [NSURL fileURLWithPath:[path rewriteURL]];
            }else{
                fileUrl = [NSURL URLWithString:[path rewriteURL]];
            }
            
            
            put.bucketName = aliOSSBucketName;
            put.objectKey = [NSString stringWithFormat:@"upload/images/%@/%@.%@",date,uuid,[fileUrl pathExtension]];
            put.uploadingFileURL = fileUrl;
            
            // optional fields
            put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
                //                NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
                //                NSLog(@"upload=%@",[NSString stringWithFormat:@"%.2lf",((double_t)totalByteSent / (double_t)totalBytesExpectedToSend) * 100]);
                process([NSString stringWithFormat:@"%.2lf",((double_t)totalByteSent / (double_t)totalBytesExpectedToSend) * 100]);
            };
            put.contentType = @"";
            put.contentMd5 = @"";
            put.contentEncoding = @"";
            put.contentDisposition = @"";
            
            OSSTask * putTask = [client putObject:put];
            
            [putTask continueWithBlock:^id(OSSTask *task) {
                if (!task.error) {
                    NSLog(@"upload object success!");
                    if (block){
                        block([WXCONFIG_RESOURCE_PATH stringByAppendingString:put.objectKey]);
                    }
                } else {
                    NSLog(@"upload object failed, error: %@" , task.error);
                    if (block){
                        block(nil);
                    }
                }
                return nil;
            }];
        }else{
            if (block){
                block(nil);
            }
        }
    }];
}
@end
