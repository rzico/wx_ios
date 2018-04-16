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
@implementation CJLivePlayerModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(loadUrl:video:method:callback:))
WX_EXPORT_METHOD(@selector(test))
WX_EXPORT_METHOD(@selector(toPlayLiveRoom))
WX_EXPORT_METHOD(@selector(toLookLiveRoom:))
WX_EXPORT_METHOD(@selector(toGag:groupId:callback:))

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

- (void)toPlayLiveRoom{
    CJLivePushViewController *pushVC = [[CJLivePushViewController alloc] init];
    [FriendshipManager getUserProfile:[CJUserManager getUserId] succ:^(TIMUserProfile *profile) {
        if (profile){
            pushVC.headIcon = profile.faceURL;
            [self->weexInstance.viewController presentViewController:pushVC animated:true completion:nil];
        }else{
            [SVProgressHUD showErrorWithStatus:@"获取用户信息失败"];
        }
    }];

}

//- (void)toPlayLiveRoom{
//    CJLivePlayViewController *playVC = [[CJLivePlayViewController alloc] init];
//    playVC.rtmpUrl = @"rtmp://10714.liveplay.myqcloud.com/live/10714_test";
//    [weexInstance.viewController presentViewController:playVC animated:true completion:nil];
//}

- (void)toLookLiveRoom:(id)Id{
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
                    [FriendshipManager getUserProfile:[CJUserManager getUserId] succ:^(TIMUserProfile *profile) {
                        if (profile){
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CJLivePlayViewController *playVC = [[CJLivePlayViewController alloc] init];
                                playVC.anchor = anchor;                                playVC.groupId = groupId;
                                playVC.nickName = profile.nickname;
                                playVC.faceUrl = profile.faceURL;
                                [self.weexInstance.viewController presentViewController:playVC animated:true completion:nil];
                            });
                        }else{
                            [SVProgressHUD showErrorWithStatus:@"获取用户信息失败"];
                        }
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

- (void)toGag:(NSString *)Id groupId:(NSString *)groupId callback:(WXModuleCallback)callback{
    [[TIMGroupManager sharedInstance] modifyGroupMemberInfoSetSilence:groupId user:Id stime:60 * 60 * 24 succ:^{
        if (callback){
            callback(@{@"type":@"success",@"content":@"禁言成功",@"data":@""});
        }
    } fail:^(int code, NSString *msg) {
        callback(@{@"type":@"error",@"content":@"禁言失败",@"data":@""});
    }];
}
@end
