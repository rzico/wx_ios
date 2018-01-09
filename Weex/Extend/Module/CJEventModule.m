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

#import "CJEventModule.h"
#import <WeexSDK/WXBaseViewController.h>
#import "CJWeexViewController.h"
#import "IWXToast.h"
#import "CJPublicKeyManager.h"
#import "CJCallbackMessage.h"
#import "ZSSRichTextEditor.h"
#import "CJUserManager.h"
#import "MD5+Util.h"
#import "CJContactManager.h"
#import "WXScanQRModule.h"
#import "CJAliOSSManager.h"
#import "CJFetchImage.h"
#import "NSString+Util.h"
#import "UIImage+Util.h"
#import "CJAmap.h"
#import <WebKit/WebKit.h>
#import "CJShareManager.h"
#import "CJDatabaseManager.h"
#import "TIMActionManager.h"

@implementation CJEventModule

@synthesize weexInstance;

static const int WX_ERR_OK = 0;//用户同意
static const int WX_ERR_AUTH_DENIED = -4;//用户拒绝授权
static const int WX_ERR_USER_CANCEL = -2;//用户取消

WX_EXPORT_METHOD(@selector(openURL:))
WX_EXPORT_METHOD(@selector(openURL:callback:))
WX_EXPORT_METHOD(@selector(closeURL))
WX_EXPORT_METHOD(@selector(closeURL:))
WX_EXPORT_METHOD_SYNC(@selector(changeWindowsBar:))
WX_EXPORT_METHOD(@selector(wxAuth:))
WX_EXPORT_METHOD(@selector(toast:))
WX_EXPORT_METHOD(@selector(encrypt:callBack:))
WX_EXPORT_METHOD(@selector(save:callBack:))
WX_EXPORT_METHOD(@selector(find:callback:))
WX_EXPORT_METHOD(@selector(findList:callback:))
WX_EXPORT_METHOD(@selector(delete:callback:))
WX_EXPORT_METHOD(@selector(openEditor:callback:))
WX_EXPORT_METHOD(@selector(scan:))
WX_EXPORT_METHOD_SYNC(@selector(getUserId))
WX_EXPORT_METHOD_SYNC(@selector(getUId))
WX_EXPORT_METHOD_SYNC(@selector(md5:))
WX_EXPORT_METHOD(@selector(getContactList:callback:))
WX_EXPORT_METHOD(@selector(navToChat:))
WX_EXPORT_METHOD(@selector(upload:withResult:AndProcess:))
WX_EXPORT_METHOD(@selector(getLocation:))
WX_EXPORT_METHOD(@selector(wxAppPay:callback:))
WX_EXPORT_METHOD_SYNC(@selector(deleteConversation:))
WX_EXPORT_METHOD(@selector(getCacheSize:))
WX_EXPORT_METHOD(@selector(clearCache:callback:))
WX_EXPORT_METHOD(@selector(share:callback:))
WX_EXPORT_METHOD(@selector(sendGlobalEvent:data:))
WX_EXPORT_METHOD(@selector(logout:))
WX_EXPORT_METHOD(@selector(setReadMessage:callback:))
WX_EXPORT_METHOD(@selector(getUnReadMessage))
WX_EXPORT_METHOD_SYNC(@selector(deviceInfo))

static NSMutableArray<NSDictionary *> *queueList;

- (void)openURL:(NSString *)url callback:(nullable WXModuleCallback)callback animated:(BOOL)animated ompletion:(void(^)(BOOL finished))completion{
    NSString *urlStr = [url rewriteURL];
    NSURL *URL;
    if ([urlStr hasPrefix:@"/"]){
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",urlStr]];
    }else{
        URL = [NSURL URLWithString:urlStr];
    }
    CJWeexViewController *controller = [[CJWeexViewController alloc] initWithUrl:URL];
    if (callback){
        controller.callback = callback;
    }
    [controller render:^(BOOL finished){
        if (finished){
            if (weexInstance.viewController.navigationController){
                controller.hidesBottomBarWhenPushed = YES;
                [[weexInstance.viewController navigationController] pushViewController:controller animated:animated];
                completion(true);
            }else{
                [weexInstance.viewController presentViewController:controller animated:animated completion:^{
                    completion(true);
                }];
            }
        }else{
            completion(false);
        }
    }];
}

- (void)openURL:(NSString *)url
{
    static BOOL isOpenning = false;
    if (!isOpenning){
        isOpenning = true;
        [self openURL:url callback:nil animated:true ompletion:^(BOOL finished) {
            isOpenning = false;
        }];
    }
}

- (void)openURL:(NSString *)url callback:(WXModuleCallback)callback{
        static BOOL isOpenning = false;
        if (!isOpenning){
            isOpenning = true;
            [self openURL:url callback:callback animated:true ompletion:^(BOOL finished) {
                isOpenning = false;
            }];
        }
}


- (void)closeURL{
    UINavigationController *nav = [weexInstance.viewController navigationController];
    if (nav.viewControllers.count > 1){
        [nav popViewControllerAnimated:YES];
    }else{
        [weexInstance.viewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)closeURL:(NSDictionary *)dic{
    NSLog(@"close=%@",NSStringFromClass([weexInstance.viewController class]));
    if ([weexInstance.viewController isKindOfClass:NSClassFromString(@"LoginViewController")]){
        NSLog(@"close|count=%zd",[weexInstance.viewController navigationController].viewControllers.count);
    }
    if (dic && [weexInstance.viewController isKindOfClass:[CJWeexViewController class]]){
        CJWeexViewController *vc = (CJWeexViewController *)weexInstance.viewController;
        [vc setData:dic];
    }
    [self closeURL];
}

- (void)upload:(NSString *)filePath withResult:(WXModuleCallback)success AndProcess:(WXModuleKeepAliveCallback)process{
    void(^completeBlock)(NSString *url) = ^(NSString *url){
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = url.length;
        message.data = url;
        NSLog(@"upload=%@",url);
        if (success){
            success(message.getMessage);
        }
    };
    
    void(^failureBlock)(void) = ^(){
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = NO;
        message.content = @"获取文件失败";
        message.data = @"";
        success(message.getMessage);
    };
    
    void(^processBlock)(NSString *percent) = ^(NSString *percent){
        CJCallbackMessage *processMessage = [CJCallbackMessage new];
        processMessage.type = YES;
        processMessage.data = percent;
        if (process){
            if ([percent doubleValue] < 100){
                process(processMessage.getMessage, YES);
            }else{
                process(processMessage.getMessage, NO);
            }
        }
    };
    
    __block NSString *localPath = filePath;
    if ([localPath hasPrefix:@"original:"] || [localPath hasPrefix:@"thumb:"] || [localPath hasPrefix:@"video:"]){
        if ([localPath hasPrefix:@"video:"]){
            [[CJFetchImage sharedInstance] fetchVideoWithSchemeUrl:localPath AndBlock:^(NSString *path) {
                if (path){
                    [[CJAliOSSManager defautManager] uploadObjectWithPath:path progress:^(NSString *percent) {
                        processBlock(percent);
                    } complete:^(CJAliOSSUploadResult result, NSString *url) {
                        completeBlock(url);
                    }];
                }else{
                    failureBlock();
                }
            }];
        }else{
            [[CJFetchImage sharedInstance] fetchAssetWithSchemeUrl:localPath AndBlock:^(UIImage *image) {
                if (image){
                    localPath = [image getJPGImagePathWithUuid:[NSString getUUID] compressionQuality:1.0];
                    [[CJAliOSSManager defautManager] uploadObjectWithPath:localPath progress:^(NSString *percent) {
                        processBlock(percent);
                    } complete:^(CJAliOSSUploadResult result, NSString *url) {
                        completeBlock(url);
                    }];
                }else{
                    failureBlock();
                }
            }];
        }
    }else{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSLog(@"exist:%d",[fileManager fileExistsAtPath:localPath]);
        [[CJAliOSSManager defautManager] uploadObjectWithPath:localPath progress:^(NSString *percent) {
            processBlock(percent);
        } complete:^(CJAliOSSUploadResult result, NSString *url) {
            completeBlock(url);
        }];
    }
}

- (void)wxAuth:(WXModuleCallback)callback{
    NSMutableDictionary *message = [NSMutableDictionary new];
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.wxAuthComplete = ^(SendAuthResp *resp) {
            switch (resp.errCode) {
                case WX_ERR_OK:
                    [message setValue:@"success" forKey:@"type"];
                    [message setValue:@"登录成功" forKey:@"content"];
                    [message setValue:resp.code forKey:@"data"];
                    break;
                case WX_ERR_AUTH_DENIED:
                    [message setValue:@"error" forKey:@"type"];
                    [message setValue:@"用户拒绝授权" forKey:@"content"];
                    [message setValue:@"-4" forKey:@"data"];
                    break;
                case WX_ERR_USER_CANCEL:
                    [message setValue:@"error" forKey:@"type"];
                    [message setValue:@"用户取消授权" forKey:@"content"];
                    [message setValue:@"-2" forKey:@"data"];
                    break;
                default:
                    [message setValue:@"error" forKey:@"type"];
                    [message setValue:@"未知错误" forKey:@"content"];
                    [message setValue:@"unknown" forKey:@"data"];
                    break;
            }
            if (callback){
                callback(message);
            }
        };
        SendAuthReq* req = [SendAuthReq new];
        req.scope = @"snsapi_userinfo" ;
        req.state = @"123" ;
        [WXApi sendReq:req];
    }else{
        [message setValue:@"error" forKey:@"type"];
        [message setValue:@"未安装微信或无法打开授权" forKey:@"content"];
        [message setValue:@"unknown" forKey:@"data"];
        if (callback){
            callback(message);
        }
    }
}

- (void)changeWindowsBar:(BOOL)isBlack{
    return;
}



- (void)toast:(id)message{
    NSLog(@"\ntoast=%@\n",message);
    IWXToast *toast = [IWXToast new];
    [toast showToast:message withInstance:weexInstance];
}

- (void)encrypt:(NSString *)data callBack:(WXModuleCallback)callBack{
    NSLog(@"data=%@",data);
    [CJPublicKeyManager encrypt:data withCallBack:^(NSString *result) {
        if (callBack){
            NSLog(@"encrypt=%@",result);
            NSMutableDictionary *message = [NSMutableDictionary new];
            if (result){
                [message setValue:@"success" forKey:@"type"];
                [message setValue:@"加密成功" forKey:@"content"];
                [message setValue:result forKey:@"data"];
            }else{
                [message setValue:@"error" forKey:@"type"];
                [message setValue:@"加密失败" forKey:@"content"];
                [message setValue:@"" forKey:@"data"];
            }
            callBack(message);
        }
    }];
}

- (void)save:(NSDictionary *)data callBack:(WXModuleCallback)callBack{
    CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
    NSError *error;
    
    NSMutableDictionary *newdic = [[NSMutableDictionary alloc] initWithDictionary:data];
    NSUInteger uId = [CJUserManager getUid];
    if (uId == 0){
        [SharedAppDelegate presentLoginViewController];
        return;
    }
    [newdic setObject:[NSNumber numberWithUnsignedInteger:uId] forKey:@"userId"];
    if (![[data objectForKey:@"value"] isKindOfClass:[NSString class]]){
        [newdic setObject:[NSDictionary convertToJsonData:[data objectForKey:@"value"]] forKey:@"value"];
    }
    if (![data objectForKey:@"Id"]){
        [newdic setObject:[NSNumber numberWithInteger:0] forKey:@"Id"];
    }
    if (![data objectForKey:@"key"]){
        [newdic setObject:@"" forKey:@"key"];
    }
    CJDatabaseData *model = [[CJDatabaseData alloc] initWithDictionary:newdic error:&error];
    NSMutableDictionary *message = [NSMutableDictionary new];
    if (!error){
        CJDatabaseSaveType type = [manager save:model];
        if (type == CJDatabaseSaveTypeSave){
            [message setValue:@"success" forKey:@"type"];
            [message setValue:@"保存成功" forKey:@"content"];
            [message setValue:@"" forKey:@"data"];
        }else if (type == CJDatabaseSaveTypeUpdate){
            [message setValue:@"success" forKey:@"type"];
            [message setValue:@"更新成功" forKey:@"content"];
            [message setValue:@"" forKey:@"data"];
        }else{
            [message setValue:@"error" forKey:@"type"];
            [message setValue:@"保存失败" forKey:@"content"];
            [message setValue:@"-1" forKey:@"data"];
        }
    }else{
        [message setValue:@"error" forKey:@"type"];
        [message setValue:@"model解析失败" forKey:@"content"];
        [message setValue:@"-1" forKey:@"data"];
    }
    if (callBack){
        callBack(message);
    }
}

- (void)find:(NSDictionary *)option callback:(WXModuleCallback)callBack{
    CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
    NSMutableDictionary *message = [NSMutableDictionary new];
    if (option){
        NSString *type = [option objectForKey:@"type"];
        NSString *key = [option objectForKey:@"key"];
        NSUInteger uId = [CJUserManager getUid];
        if (uId == 0 && ![type isEqualToString:@"httpCache"]){
            [SharedAppDelegate presentLoginViewController];
            return;
        }
        CJDatabaseData *model = [manager findWithUserId:uId AndType:type AndKey:key AndNeedOpen:YES];
        if (model){
            [message setValue:@"success" forKey:@"type"];
            [message setValue:@"查找成功" forKey:@"content"];
            [message setValue:[NSDictionary objectToDictionary:model] forKey:@"data"];
        }else{
            [message setValue:@"success" forKey:@"type"];
            [message setValue:@"未找到" forKey:@"content"];
            [message setValue:@"" forKey:@"data"];
        }
    }else{
        [message setValue:@"error" forKey:@"type"];
        [message setValue:@"参数错误" forKey:@"content"];
        [message setValue:@"" forKey:@"data"];
    }
    if (callBack){
        callBack(message);
    }
}

- (void)findList:(NSDictionary *)dic callback:(WXModuleCallback)callBack{
    CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
    CJCallbackMessage *message = [CJCallbackMessage new];
    
    NSMutableDictionary *newdic = [[NSMutableDictionary alloc] initWithDictionary:dic];
    NSInteger current = [[dic objectForKey:@"current"] integerValue];
    NSInteger pageSize = [[dic objectForKey:@"pageSize"] integerValue];
    [newdic setObject:[NSNumber numberWithInteger:current] forKey:@"current"];
    [newdic setObject:[NSNumber numberWithInteger:pageSize] forKey:@"pageSize"];
    
    NSError *error;
    CJDatabaseOption *option = [[CJDatabaseOption alloc] initWithDictionary:newdic error:&error];
    if (!error){
        NSUInteger uId = [CJUserManager getUid];
        if (uId == 0){
            [SharedAppDelegate presentLoginViewController];
            return;
        }
        NSArray *array = [manager findListWithUserId:uId AndOption:option];
        if (!array || array.count <= 0){
            message.type = YES;
            message.content = [NSString stringWithFormat:@"%@未找到",option.type];
            message.data = @"";
        }else{
            message.type = YES;
            message.content = @"查找成功";
            message.data = array;
        }
    }else{
        message.type = NO;
        message.content = @"解析失败";
        message.data = @"-1";
    }
    if (callBack){
        callBack(message.getMessage);
    }
}

- (void)delete:(NSDictionary *)option callback:(WXModuleCallback)callBack{
    CJDatabaseManager *manager = [CJDatabaseManager defaultManager];
    CJCallbackMessage *message = [CJCallbackMessage new];
    if (option){
        NSString *type = [option objectForKey:@"type"];
        NSString *key = [option objectForKey:@"key"];
        NSUInteger uId = [CJUserManager getUid];
        if (uId == 0){
            [SharedAppDelegate presentLoginViewController];
            return;
        }
        BOOL success = [manager deleteWithUserId:uId AndType:type AndKey:key];
        if (success){
            message.type = YES;
            message.content = @"删除成功";
            message.data = @"1";
        }else{
            message.type = NO;
            message.content = @"删除失败";
            message.data = @"-1";
        }
    }else{
        message.type = NO;
        message.content = @"参数错误";
        message.data = @"-1";
    }
    if (callBack){
        callBack(message.getMessage);
    }
}

- (void)openEditor:(NSString *)content callback:(WXModuleCallback)callback{
    NSString *html = @"";
    if (content && content.length > 0){
        html = content;
    }
    ZSSRichTextEditor *editor = [ZSSRichTextEditor new];
    editor.view.backgroundColor = [UIColor colorWithHex:0xe3e7ea];
//    weexInstance.viewController.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    editor.title = @"文本编辑";
    editor.alwaysShowToolbar = YES;
    [editor setHTML:html];
    editor.formatHTML = YES;
    editor.callBack = ^(NSString *content) {
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = YES;
        message.content = @"编辑完成";
        message.data = (!content || content.length <= 0) ? @"" : content;
        if (callback){
            callback(message.getMessage);
        }
    };
//    [[weexInstance.viewController navigationController] pushViewController:editor animated:YES];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editor];
    [weexInstance.viewController presentViewController:nav animated:YES completion:nil];
}

- (void)scan:(WXModuleCallback)callback{
    WXScanQRModule *scan = [WXScanQRModule new];
    [scan scanQR:weexInstance callBack:^(id result) {
        if (callback){
            CJCallbackMessage *message= [CJCallbackMessage new];
            message.type = [[result objectForKey:@"status"] isEqualToString:@"success"];
            message.content = [result objectForKey:@"msg"];
            message.data = [result objectForKey:@"result"];
            callback(message.getMessage);
        }
    }];
}

- (NSString *)getUserId{
    return [CJUserManager getUserId];
}

- (NSUInteger)getUId{
    return [CJUserManager getUid];
}

- (NSString *)md5:(NSString *)data{
    if (data && data.length > 0){
        return [MD5_Util md5:data];
    }else{
        return @"";
    }
}

- (void)getContactList:(NSDictionary *)option callback:(WXModuleCallback)callback{
    CJContactManager *cm = [CJContactManager sharedInstance];
    [cm getContactList:option AndBlock:^(BOOL succeed, NSArray<CJContact *> *contactList) {
        CJCallbackMessage *message = [CJCallbackMessage new];
        if (succeed){
            message.type = YES;
            message.content = @"获取成功";
            message.data = contactList;
        }else{
            message.type = NO;
            message.content = @"获取失败";
            message.data = @"";
        }
        if (callback){
            callback(message.getMessage);
        }
    }];
}

- (void)navToChat:(NSString *)userId{
    IMAUser *user = [[IMAUser alloc] initWith:userId];
    [SharedAppDelegate pushToChatViewControllerWith:user];
}

- (void)getLocation:(WXModuleCallback)callback{
    [[CJAmap shareInstance] reGeocodeAction:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        CJCallbackMessage *message = [CJCallbackMessage new];
        if (error != nil && error.code == AMapLocationErrorLocateFailed){
            message.type = NO;
            message.content = @"定位错误";
            NSMutableDictionary *errInfo = [NSMutableDictionary new];
            [errInfo setObject:error.localizedDescription forKey:@"errorInfo"];
            [errInfo setObject:[NSNumber numberWithLong:(long)error.code] forKey:@"errorCode"];
            message.data = errInfo;
        }else if(error != nil && (error.code == AMapLocationErrorReGeocodeFailed
                                  || error.code == AMapLocationErrorTimeOut
                                  || error.code == AMapLocationErrorCannotFindHost
                                  || error.code == AMapLocationErrorBadURL
                                  || error.code == AMapLocationErrorNotConnectedToInternet
                                  || error.code == AMapLocationErrorCannotConnectToHost)){
            message.type = NO;
            message.content = @"逆地理位置错误";
            NSMutableDictionary *errInfo = [NSMutableDictionary new];
            [errInfo setObject:error.localizedDescription forKey:@"errorInfo"];
            [errInfo setObject:[NSNumber numberWithLong:(long)error.code] forKey:@"errorCode"];
            message.data = errInfo;
        }else if (error != nil && error.code == AMapLocationErrorRiskOfFakeLocation){
            message.type = NO;
            message.content = @"虚拟定位";
            NSMutableDictionary *errInfo = [NSMutableDictionary new];
            [errInfo setObject:error.localizedDescription forKey:@"errorInfo"];
            [errInfo setObject:[NSNumber numberWithLong:(long)error.code] forKey:@"errorCode"];
            message.data = errInfo;
        }else{
            if (regeocode){
                NSMutableDictionary *locationData = [NSMutableDictionary new];
                [locationData setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"lng"];
                [locationData setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"lat"];
                [locationData setObject:regeocode.city forKey:@"city"];
                [locationData setObject:regeocode.citycode forKey:@"cityCode"];
                [locationData setObject:regeocode.country forKey:@"country"];
                [locationData setObject:regeocode.district forKey:@"district"];
                [locationData setObject:regeocode.street forKey:@"street"];
                [locationData setObject:regeocode.province forKey:@"province"];
//                [locationData setObject:regeocode.number forKey:@"address"];
//                [locationData setObject:regeocode.formattedAddress forKey:@"description"];
                [locationData setObject:regeocode.formattedAddress forKey:@"address"];
                message.type = YES;
                message.content = @"定位成功";
                message.data = locationData;
            }else{
                message.type = NO;
                message.content = @"逆地理位置错误";
                message.data = @"";
            }
        }
        if (callback){
            callback(message.getMessage);
        }
    }];
}

- (BOOL)deleteConversation:(NSString *)peer{
    TIMConversation *conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:peer];
    [conversation setReadMessage:nil succ:nil fail:nil];
    [conversation deleteLocalMessage:nil fail:nil];
    BOOL success = [[TIMManager sharedInstance] deleteConversationAndMessages:TIM_C2C receiver:peer];
    NSLog(@"deleteConversation=%d",success);
    CJPostNotification(CJNOTIFICATION_IM_UNREAD_COUNT, nil);
    return success;
}


- (void)wxAppPay:(NSDictionary *)dic callback:(WXModuleCallback)callback{
    NSMutableDictionary *message = [NSMutableDictionary new];
    if ([dic isKindOfClass:[NSDictionary class]]){
        PayReq *request = [[PayReq alloc] init];
        request.partnerId = [dic objectForKey:@"partnerid"];
        request.prepayId = [dic objectForKey:@"prepayid"];
        request.package = [dic objectForKey:@"package"];
        request.nonceStr = [dic objectForKey:@"noncestr"];
        request.timeStamp = [[dic objectForKey:@"timestamp"] unsignedIntValue];
        request.sign = [dic objectForKey:@"sign"];
        
        if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.wxPayComplete = ^(PayResp *resp) {
                switch (resp.errCode) {
                    case 0:
                        [message setValue:@"success" forKey:@"type"];
                        [message setValue:@"支付成功" forKey:@"content"];
                        [message setValue:@"" forKey:@"data"];
                        break;
                    case -1:
                        [message setValue:@"error" forKey:@"type"];
                        [message setValue:@"错误" forKey:@"content"];
                        [message setValue:@"-1" forKey:@"data"];
                        break;
                    case -2:
                        [message setValue:@"error" forKey:@"type"];
                        [message setValue:@"用户取消" forKey:@"content"];
                        [message setValue:@"-2" forKey:@"data"];
                        break;
                    default:
                        [message setValue:@"error" forKey:@"type"];
                        [message setValue:@"未知错误" forKey:@"content"];
                        [message setValue:@"unknown" forKey:@"data"];
                        break;
                }
                if (callback){
                    NSLog(@"resp=%@",message);
                    callback(message);
                }
            };
            [WXApi sendReq:request];
        }else{
            [message setValue:@"error" forKey:@"type"];
            [message setValue:@"未安装微信或无法打开授权" forKey:@"content"];
            [message setValue:@"unknown" forKey:@"data"];
            if (callback){
                callback(message);
            }
        }
    }else{
        [message setValue:@"error" forKey:@"type"];
        [message setValue:@"请求参数错误" forKey:@"content"];
        [message setValue:@"unknown" forKey:@"data"];
        if (callback){
            callback(message);
        }
    }
}

- (void)getCacheSize:(WXModuleCallback)callback{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        unsigned long long cacheSize = [NSFileManager countFileSizeWithPath:CACHES_PATH];
        unsigned long long tmpSize = [NSFileManager countFileSizeWithPath:TMP_PATH];
        unsigned long long timMsgSize = [NSFileManager countFileSizeWithPath:[DOCUMENT_PATH stringByAppendingPathComponent:@"com_tencent_imsdk_data"]];
        unsigned long long wxstorageSize = [NSFileManager countFileSizeWithPath:[DOCUMENT_PATH stringByAppendingPathComponent:@"wxstorage"]];
        
        CJDatabaseOption *option = [CJDatabaseOption new];
        option.type = @"DataCache";
        option.current = 0;
        option.pageSize = 0;
        option.keyword = @"";
        option.orderBy = @"";
        NSArray *array = [[CJDatabaseManager defaultManager] findListWithUserId:[CJUserManager getUid] AndOption:option];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
        
        unsigned long long dataSize = data.length;
        
        NSMutableDictionary *sizeData = [NSMutableDictionary new];
        [sizeData setObject:[NSString stringWithFormat:@"%.2lfM",(cacheSize + tmpSize)/1024.0/1024.0] forKey:@"cache"];
        [sizeData setObject:[NSString stringWithFormat:@"%.2lfM",timMsgSize/1024.0/1024.0] forKey:@"tim"];
        [sizeData setObject:[NSString stringWithFormat:@"%.2lfM",(wxstorageSize + dataSize)/1024.0/1024.0] forKey:@"wxstorage"];
        [sizeData setObject:[NSString stringWithFormat:@"%.2lfM",(cacheSize + tmpSize + timMsgSize + wxstorageSize + dataSize)/1024.0/1024.0] forKey:@"total"];
        
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = YES;
        message.content = @"获取成功";
        message.data = sizeData;
        if (callback){
            callback(message.getMessage);
        }
    });
}

- (void)clearCache:(NSDictionary *)option callback:(WXModuleCallback)callback{
    static BOOL inProcess = NO;
    if (!inProcess){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            inProcess = YES;
            NSArray *array = [option objectForKey:@"type"];
            for (NSString *str in array){
                if ([str isEqualToString:@"cache"]){
                    [NSFileManager cleanFileWithPath:CACHES_PATH];
                    [NSFileManager cleanFileWithPath:TMP_PATH];
                }else if ([str isEqualToString:@"tim"]){
                    [NSFileManager cleanFileWithPath:[DOCUMENT_PATH stringByAppendingPathComponent:@"com_tencent_imsdk_data"]];
                }else if ([str isEqualToString:@"wxstorage"]){
                    [NSFileManager cleanFileWithPath:[DOCUMENT_PATH stringByAppendingPathComponent:@"wxstorage"]];
                }
            }
            [NSFileManager cleanCacheAndCookie];
            inProcess = NO;
            if (callback){
                CJCallbackMessage *message = [CJCallbackMessage new];
                message.type = YES;
                message.content = @"删除完毕";
                message.data = @"";
                if (callback){
                    callback(message.getMessage);
                }
            }
        });
    }
}

- (void)share:(NSDictionary *)option callback:(WXModuleCallback)callback{
    NSMutableDictionary *message = [NSMutableDictionary new];
    if ([option isKindOfClass:[NSDictionary class]]){
        NSString *type = [option objectForKey:@"type"];
        if ([type isEqualToString:@"copyHref"]){
            [CJShareManager shareWithPasteBoard:option complete:^(id result) {
                if (callback){
                    callback(result);
                }
            }];
        }else if ([type isEqualToString:@"appMessage"] || [type isEqualToString:@"timeline"] || [type isEqualToString:@"favorite"]){
            [CJShareManager shareWithWeixin:option complete:^(id result) {
                if (callback){
                    callback(result);
                }
            }];
        }else if ([type isEqualToString:@"browser"]){
            [CJShareManager shareWithBrowser:option complete:^(id result) {
                if (callback){
                    callback(result);
                }
            }];
        }else{
            [message setValue:@"error" forKey:@"type"];
            [message setValue:@"请求类型错误" forKey:@"content"];
            [message setValue:@"unknown" forKey:@"data"];
            if (callback){
                callback(message);
            }
        }
    }else{
        [message setValue:@"error" forKey:@"type"];
        [message setValue:@"请求参数错误" forKey:@"content"];
        [message setValue:@"unknown" forKey:@"data"];
        if (callback){
            callback(message);
        }
    }
}

- (void)sendGlobalEvent:(NSString *)eventKey data:(id)data{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    [dic setObject:eventKey forKey:@"eventKey"];
    [dic setObject:data forKey:@"data"];
    CJPostNotification(CJNOTIFICATION_WX_SEND_Global_EVENT, dic);
}

- (void)logout:(WXModuleCallback)callback{
    [SharedAppDelegate logOut:^(BOOL success) {
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = success;
        message.data = @"";
        if (callback){
            callback(message.getMessage);
        }
    }];
}

- (void)copy:(NSString *)string{
    UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
    pasteBoard.string = string;
}

- (void)setReadMessage:(NSString *)peer callback:(WXModuleCallback)callback{
    void(^finishBlock)(CJCallbackMessage *message) = ^(CJCallbackMessage *message){
        if (callback){
            callback(message.getMessage);
            CJPostNotification(CJNOTIFICATION_IM_UNREAD_COUNT, nil);
        }
    };

    TIMConversation *conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:peer];
    if ([conversation respondsToSelector:@selector(setReadMessage:succ:fail:)]){
        [conversation setReadMessage:nil succ:^{
            CJCallbackMessage *message = [CJCallbackMessage new];
            message.type = YES;
            message.content = @"设置成功";
            message.data = @"";
            finishBlock(message);
        } fail:^(int code, NSString *msg) {
            CJCallbackMessage *message = [CJCallbackMessage new];
            message.type = NO;
            message.content = [NSString stringWithFormat:@"%d",code];
            message.data = msg;
            finishBlock(message);
        }];
    }else{
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = NO;
        message.content = @"设置失败";
        message.data = @"";
        finishBlock(message);
    }
    
}

- (void)getUnReadMessage{
    if ([[TIMManager sharedInstance] getLoginUser].length){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [TIMActionManager PostAllConversationWithLastMessage];
        });
    }
}

- (NSDictionary *)deviceInfo{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    CGFloat bottom = [UIDevice isIphoneX] ? 34.0 : 0.0;
    return @{@"system":@"iOS",
             @"haveTop":[NSNumber numberWithBool:YES],
             @"width":[NSNumber numberWithFloat:width],
             @"height":[NSNumber numberWithFloat:height],
             @"statusBarHeight":[NSNumber numberWithFloat:statusBarHeight],
             @"bottomHeight":[NSNumber numberWithFloat:bottom]};
}
@end

