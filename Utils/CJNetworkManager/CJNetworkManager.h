//
//  CJNetworkManager.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//


#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface CJNetworkManager : NSObject

+ (AFHTTPSessionManager *) defaultManager;

/*
 *带有多参数的系统post
 */
+ (void)PostNativeMain:(NSString *)url Body:(NSString *)string  andBlobk:(void(^)(NSDictionary *resDic))block;

/*
 *上传图片带参数的post
 */
+ (void)PostimageNewUpload:(NSData *)imageWithData withUrl:(NSString *)urlString  andBlock:(void(^)(NSDictionary *ReturnDic))block;

/*
 *AFget
 */
+ (void)GetHttp:(NSString *)url Parameters:(nullable NSDictionary *)parameters  Success:(void(^)(NSURLSessionDataTask *task, id responseObject))SuccessBlock  andFalse:(void(^)(NSURLSessionDataTask *task, NSError *error))FalseBlock;

/*
 *AFpost
 */
+ (void)PostHttp:(NSString *)url  Parameters:(nullable NSDictionary *)parameters Success:(void(^)(NSURLSessionDataTask *task, id responseObject))SuccessBlock  andFalse:(void(^)(NSURLSessionDataTask *task, NSError *error))FalseBlock;

+ (void)PostWithRequest:(NSURLRequest *)request Success:(void(^)(NSURLResponse *response, id responseObject))SuccessBlock  andFalse:(void(^)(NSURLResponse *response, NSError *error))FalseBlock;
/**
 上传图片文件
 
 @param url <#url description#>
 @param imageData <#imageData description#>
 @param paramters <#paramters description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+(void) PostImageWithData:(NSString *)url imageData:(NSData *)imageData  otherParamters:(NSDictionary *)paramters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

/**
 上传语音文件
 
 @param url <#url description#>
 @param voiceData <#imageData description#>
 @param paramters <#paramters description#>
 @param success <#success description#>
 @param failure <#failure description#>
 */
+(void) PostVoiceWithData:(NSString *)url voiceData:(NSData *)voiceData  otherParamters:(NSDictionary *)paramters success:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;


+(void) DownLoad:(NSString *)url;

NS_ASSUME_NONNULL_END

@end
