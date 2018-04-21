//
//  WXNetworkDefaultImpl.m
//  Weex
//
//  Created by 郭书智 on 2017/9/25.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJNetworkDefaultImpl.h"
#import <WeexSDK/WXResourceRequestHandler.h>
#import "CJNetworkManager.h"
#import "NSURL+Util.h"
#import "AppDelegate.h"
#import "UIViewController+Util.h"
#import "CJDatabaseManager.h"
#import "CJUserManager.h"
#import "CJNetworkQueueData.h"
//#import "IMManager.h"

static NSMutableArray<CJNetworkQueueData *> *queueList;

@implementation CJNetworkDefaultImpl

- (void)sendRequest:(WXResourceRequest *)request withDelegate:(id<WXResourceRequestDelegate>)delegate{
    if ([request.HTTPMethod isEqualToString:@"POST"]){
//        NSLog(@"url=%@,data=%@",request.URL,[[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
        [CJNetworkManager PostWithRequest:request Success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
                if ([self checkLoginSession:responseObject withRequest:request andDelegate:delegate]){
                    NSLog(@"receive=%@",responseObject);
                    [delegate request:request didReceiveData:[[NSDictionary convertToJsonData:responseObject] dataUsingEncoding:NSUTF8StringEncoding]];
                    [delegate requestDidFinishLoading:request];
                }
            }else{
                [delegate request:request didReceiveData:responseObject];
                [delegate requestDidFinishLoading:request];
            }
        } andFalse:^(NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
            [delegate request:request didFailWithError:error];
        }];
    }else if([request.HTTPMethod isEqualToString:@"GET"]){
        if (!([request.URL isContains:@".ttf"] || [request.URL isContains:@".js"] || [request.URL isContains:@".wx"])){
            CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
            
            //key只保留相对路径
            NSString *key = [request.URL absoluteString];
            key = [key stringByReplacingOccurrencesOfString:WXCONFIG_INTERFACE_PATH withString:@""];
            
            CJDatabaseData *data;
            data = [manager findWithUserId:[CJUserManager getUid] AndType:@"httpCache" AndKey:key AndNeedOpen:YES];
            
            //无网络情况并且取不到数据尝试使用0的userId来获取缓存
            if (!data && ![[AFNetworkReachabilityManager sharedManager] isReachable]){
                data = [manager findWithUserId:0 AndType:@"httpCache" AndKey:key AndNeedOpen:YES];
            }
            
            
            NSMutableDictionary *parameters = nil;
            if (data && data.keyword){
                parameters = [NSMutableDictionary new];
                [parameters setObject:data.keyword forKey:@"md5"];
            }
            [CJNetworkManager GetHttp:[request.URL absoluteString] Parameters:parameters Success:^(NSURLSessionDataTask *task, id  _Nonnull responseObject) {
                if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
                    NSLog(@"receive=%@",responseObject);
                    if ([self checkLoginSession:responseObject withRequest:request andDelegate:delegate]){
                        NSString *receiveData = [NSDictionary convertToJsonData:responseObject];
                        if ([[responseObject objectForKey:@"type"] isEqualToString:@"success"]){
                            if ([responseObject objectForKey:@"md5"]){
                                CJDatabaseData *newData = [CJDatabaseData new];
                                newData.userId = [NSString stringWithFormat:@"%tu",[CJUserManager getUid]];
                                newData.type = @"httpCache";
                                //key 使用相对路径
                                newData.key = key;
                                newData.value = receiveData;
                                newData.keyword = [responseObject objectForKey:@"md5"];
                                newData.sort = @"";
                                [manager save:newData];
                            }
                            [delegate request:request didReceiveData:[receiveData dataUsingEncoding:NSUTF8StringEncoding]];
                            [delegate requestDidFinishLoading:request];
                        }else if ([[responseObject objectForKey:@"type"] isEqualToString:@"warn"]){
                            if (data){
                                NSMutableDictionary *header = [NSMutableDictionary new];
                                [header setObject:@"json" forKey:@"responseType"];
                                [header setObject:@"缓存数据" forKey:@"statusText"];
                                WXResourceResponse *response = [[WXResourceResponse alloc] initWithURL:request.URL statusCode:200 HTTPVersion:nil headerFields:header];
                                [delegate request:request didReceiveResponse:response];
                                [delegate request:request didReceiveData:[data.value dataUsingEncoding:NSUTF8StringEncoding]];
                                [delegate requestDidFinishLoading:request];
                            }
                        }else if ([[responseObject objectForKey:@"type"] isEqualToString:@"error"]){
                            if (data){
                                NSMutableDictionary *header = [NSMutableDictionary new];
                                [header setObject:@"json" forKey:@"responseType"];
                                [header setObject:[responseObject objectForKey:@"content"] forKey:@"statusText"];
                                WXResourceResponse *response = [[WXResourceResponse alloc] initWithURL:request.URL statusCode:304 HTTPVersion:nil headerFields:header];
                                [delegate request:request didReceiveResponse:response];
                                [delegate request:request didReceiveData:[data.value dataUsingEncoding:NSUTF8StringEncoding]];
                                [delegate requestDidFinishLoading:request];
                            }else{
                                [delegate request:request didReceiveData:[receiveData dataUsingEncoding:NSUTF8StringEncoding]];
                                [delegate requestDidFinishLoading:request];
                            }
                        }
                    }
                }else{
                    [delegate request:request didReceiveData:responseObject];
                    [delegate requestDidFinishLoading:request];
                }
            } andFalse:^(NSURLSessionDataTask *task, NSError * _Nonnull error) {
                if (data){
                    NSMutableDictionary *header = [NSMutableDictionary new];
                    [header setObject:@"json" forKey:@"responseType"];
                    [header setObject:@"网络不稳定" forKey:@"statusText"];
                    WXResourceResponse *response = [[WXResourceResponse alloc] initWithURL:request.URL statusCode:304 HTTPVersion:nil headerFields:header];
                    [delegate request:request didReceiveResponse:response];
                    [delegate request:request didReceiveData:[data.value dataUsingEncoding:NSUTF8StringEncoding]];
                    [delegate requestDidFinishLoading:request];
                }else{
                    [delegate request:request didFailWithError:error];
                }
            }];
        }else{
            [super sendRequest:request withDelegate:delegate];
        }
    }else{
        [super sendRequest:request withDelegate:delegate];
    }
}

- (BOOL)checkLoginSession:(NSDictionary *)data withRequest:(WXResourceRequest *)request andDelegate:(id<WXResourceRequestDelegate>)delegate{
    if ([[data objectForKey:@"type"] isEqualToString:@"error"] && [[data objectForKey:@"content"] isEqualToString:@"session.invaild"]){
//        [[TIMManager sharedInstance] logout:^{
//
//        } fail:^(int code, NSString *msg) {
//
//        }];
        [CJUserManager removeUser];
        CJNetworkQueueData *model = [CJNetworkQueueData new];
        model.request = request;
        model.delegate = delegate;
        if (!queueList){
            queueList = [NSMutableArray<CJNetworkQueueData *> new];
        }
        [queueList insertObject:model atIndex:0];
        [SharedAppDelegate presentLoginViewController];
        return NO;
    }else if ([[data objectForKey:@"type"] isEqualToString:@"success"] && [[data objectForKey:@"content"] isEqualToString:@"login.success"]){
        [CJNetworkManager GetHttp:HTTPAPI(@"login/isAuthenticated") Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
                if ([[responseObject objectForKey:@"type"] isEqualToString:@"success"]){
                    [CJUserManager setUser:[responseObject objectForKey:@"data"]];
//                    [[IMManager sharedInstance] loginWithUser:[responseObject objectForKey:@"data"] loginOption:IMManagerLoginOptionForce andBlock:^(BOOL success) {
//                        if (!success){
//                            [SharedAppDelegate logOut:nil];
//                        }
//                    }];
                }
            }
        } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            
        }];
        for (CJNetworkQueueData *queue in queueList){
            dispatch_async(dispatch_get_main_queue(), ^{
                CJNetworkDefaultImpl *network = [CJNetworkDefaultImpl new];
                [network sendRequest:queue.request withDelegate:queue.delegate];
                [queueList removeObject:queue];
            });
        }
        return YES;
    }else if ([[data objectForKey:@"type"] isEqualToString:@"success"] && [[data objectForKey:@"content"] isEqualToString:@"注销成功"]){
        [SharedAppDelegate presentLoginViewController];
        return YES;
    }else{
        return YES;
    }
}
@end
