//
//  CJLivePlayerModule.m
//  Weex
//
//  Created by macOS on 2018/1/30.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePlayerModule.h"
#import "CJLivePlayerViewController.h"
#import "CJRouterViewController.h"


#import "CJLivePushViewController.h"
#import "CJLivePlayViewController.h"

#import "FriendshipManager.h"
#import "CJLivePlayModel.h"
#import "CJLivePlayUserModel.h"
@implementation CJLivePlayerModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(loadUrl:video:method:callback:))
WX_EXPORT_METHOD(@selector(test))
WX_EXPORT_METHOD(@selector(toPlayLiveRoom:play:record:title:frontcover:callback:))
//WX_EXPORT_METHOD(@selector(toPlayLiveRoom:play:record:callback:))
WX_EXPORT_METHOD(@selector(toLookLiveRoom:title:fm:callback:))
WX_EXPORT_METHOD(@selector(toGag:nickName:groupId:time:callback:))
WX_EXPORT_METHOD(@selector(getGag:gourpId:callback:))
WX_EXPORT_METHOD(@selector(toKick:nickName:callback:))

- (void)loadUrl:(NSString *)url video:(NSString *)video method:(NSString *)method callback:(WXModuleCallback)callback{
    CJLivePlayerViewController *livePlayer = [[CJLivePlayerViewController alloc] init];
    [weexInstance.viewController presentViewController:livePlayer animated:true completion:^{
        [livePlayer loadWithUrl:url video:video method:method callback:^{
            if (callback){
                callback(@{@"type":@"success",@"content":@"已关闭",@"data":@""});
            }
        }];
    }];
}

- (void)test{
    NSLog(@"ttttttt");
}

- (void)toPlayLiveRoom:(int)Id play:(BOOL)play record:(BOOL)record title:(NSString *)title frontcover:(NSString *)frontCover callback:(WXModuleCallback)callback{
    NSString *url = [NSString stringWithFormat:@"%@?id=%zu",HTTPAPI(@"user/view"),[CJUserManager getUid]];
    [CJNetworkManager GetHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
            CJLivePlayUserModel *user = [CJLivePlayUserModel modelWithDictionary:[responseObject objectForKey:@"data"]];
            CJLivePushViewController *pushVC = [[CJLivePushViewController alloc] init];
            pushVC.anchor = user;
            pushVC.headIcon = user.logo;
            pushVC.isRecord = record;
            pushVC.liveTitle = title;
            pushVC.frontCover = frontCover;
//            pushVC.isNativeConfig = !play;
            [self->weexInstance.viewController presentViewController:pushVC animated:true completion:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:@"获取用户信息失败"];
        }
    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
    }];
}

//- (void)toPlayLiveRoom:(int)Id play:(BOOL)play record:(BOOL)record callback:(WXModuleCallback)callback{
//    CJLivePushViewController *pushVC = [[CJLivePushViewController alloc] init];
//    [FriendshipManager getUserProfile:[CJUserManager getUserId] succ:^(TIMUserProfile *profile) {
//        if (profile){
//            pushVC.headIcon = profile.faceURL;
//            [self->weexInstance.viewController presentViewController:pushVC animated:true completion:nil];
//        }else{
//            [SVProgressHUD showErrorWithStatus:@"获取用户信息失败"];
//        }
//    }];
//}

//- (void)toPlayLiveRoom{
//    CJLivePlayViewController *playVC = [[CJLivePlayViewController alloc] init];
//    playVC.rtmpUrl = @"rtmp://10714.liveplay.myqcloud.com/live/10714_test";
//    [weexInstance.viewController presentViewController:playVC animated:true completion:nil];
//}

- (void)toLookLiveRoom:(id)Id title:(NSString *)title fm:(NSString *)fm callback:(WXModuleCallback)callback{
    NSString *groupId = [NSString stringWithFormat:@"%@",Id];
    [[TIMGroupManager sharedInstance] joinGroup:groupId msg:@"join" succ:^{
        NSString *api = HTTPAPI(@"live/into");
        NSString *url = [NSString stringWithFormat:@"%@?id=%@&lat=&lng=",api,groupId];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [CJNetworkManager PostWithRequest:request Success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
                NSLog(@"服务器返回:%@",responseObject);
                NSDictionary *data = [responseObject objectForKey:@"data"];
                CJLivePlayModel *anchor = [CJLivePlayModel modelWithDictionary:data];
                if (anchor){
                    NSString *url = [NSString stringWithFormat:@"%@?id=%zu",HTTPAPI(@"user/view"),[CJUserManager getUid]];
                    [CJNetworkManager GetHttp:url Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                        if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"type"] equalsString:@"success"]){
                            CJLivePlayUserModel *user = [CJLivePlayUserModel modelWithDictionary:[responseObject objectForKey:@"data"]];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CJLivePlayViewController *playVC = [[CJLivePlayViewController alloc] init];
                                playVC.anchor = anchor;
                                playVC.groupId = groupId;
                                playVC.user = user;
                                [self.weexInstance.viewController presentViewController:playVC animated:true completion:nil];
                            });
                        }else{
                            [SVProgressHUD showErrorWithStatus:@"接口数据返回错误"];
                        }
                    } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                        [self showError:@"请求接口错误"];
                    }];
                    
                }else{
                    //未找到Key
                    [self showError:@"未找到Key"];
                }
            }else{
                //接口数据返回错误
                [self showError:@"接口数据返回错误"];
            }
        } andFalse:^(NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
            //请求接口错误
            [self showError:@"请求接口错误"];
        }];
    } fail:^(int code, NSString *msg) {
        [self showError:@"加入直播间失败"];
    }];
}

- (void)showError:(NSString *)error{
    [SVProgressHUD showErrorWithStatus:@"进入直播间失败"];
}

- (void)toGag:(NSString *)Id nickName:(NSString *)nickName groupId:(NSString *)groupId time:(NSString *)time callback:(WXModuleCallback)callback{
    //禁言增加通知 By CJ 2018年04月17日11:24:33
    int stime = [time intValue];
    NSString *gagInfo = [NSString stringWithFormat:@"%@|%@|%@",Id,nickName,time];
    NSDictionary *message = @{@"receiver":groupId,@"info":gagInfo,@"type":@"gag"};
    CJPostNotification(CJNOTIFICATION_GROUP_MESSAGE, message);
    if (callback){
        callback(@{@"type":@"success",@"content":stime > 1 ? @"禁言成功" : @"解除禁言成功",@"data":@""});
    }
//    [[TIMGroupManager sharedInstance] modifyGroupMemberInfoSetSilence:groupId user:Id stime:stime succ:^{
//        
//    } fail:^(int code, NSString *msg) {
//        if (callback){
//            callback(@{@"type":@"error",@"content":stime > 1 ? @"禁言失败" : @"解除禁言失败",@"data":@""});
//        }
//    }];
}

- (void)toKick:(NSString *)Id nickName:(NSString *)nickName callback:(WXModuleCallback)callback{
    NSDictionary *message = @{@"receiver":@"all",@"data":@{@"id":Id,@"nickName":nickName},@"type":@"kick"};
    CJPostNotification(CJNOTIFICATION_GROUP_MESSAGE, message);
    if (callback){
        callback(@{@"type":@"success",@"content":@"成功",@"data":@""});
    }
}

- (void)getGag:(NSString *)userId gourpId:(NSString *)groupId callback:(WXModuleCallback)callback{
    [[TIMGroupManager sharedInstance] getGroupMembersInfo:groupId members:[NSArray arrayWithObject:userId] succ:^(NSArray *members) {
        TIMGroupMemberInfo *info = [members firstObject];
        if (callback){
            callback(@{@"type":@"success",@"content":@"获取成功",@"data":info.silentUntil > 1 ? @"true" : @"false"});
        }
    } fail:^(int code, NSString *msg) {
        if (callback){
            callback(@{@"type":@"error",@"content":@"获取失败",@"data":@""});
        }
    }];
}
@end
