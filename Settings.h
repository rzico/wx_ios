//
//  Settings.h
//  Weex
//
//  Created by 郭书智 on 2017/9/28.
//  Copyright © 2017年 rsico. All rights reserved.
//

#ifndef Settings_h
#define Settings_h

#define IsIPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

//本地KeyChain参数
#define ApplicationID @"com.rzico.weex"
#define SERVICE @"com.rzico.weex"
#define ACCOUNT @"accountUDID"
#define ACCOUNTMD5 @"ACCOUNTMD5"

//高德地图
static NSString *AMapAPIKey = @"72e0eed9d55695b21e1ec6639f1387f4";

//腾讯IM参数
#define kTLSAppid       @"1400043914"//TLS_APPID
#define kSdkAppId       @"1400043914"//SDK_APPID
#define kSdkAccountType @"18325"//用户类型

//#define kbusiId         6264
#define kbusiId         6263

//服务器参数
#define HTTPAPI(url) [NSString stringWithFormat:@"%@weex/%@.jhtml",WXCONFIG_INTERFACE_PATH,url]
#define HTTPSAPI(url) [NSString stringWithFormat:@"https://%@%@.jhtml",HOST,url]

#define LOCAL_RESOURCE_PATH = [NSString stringWithFormat:@"%@/resource/",DOCUMENT_PATH]


//这个是放大那个动画的背景色值
static NSString *WXCONFIG_COLOR = @"#F0AD3C";

//资源地址
static NSString *WXCONFIG_RESOURCE_PATH = @"http://cdnx.rzico.com/";

//接口地址
static NSString *WXCONFIG_INTERFACE_PATH = @"http://weex.rzico.com/";
//static NSString *WXCONFIG_INTERFACE_PATH = @"http://192.168.2.110:8088/";
//static NSString *WXCONFIG_INTERFACE_PATH = @"http://weex.rzico.com/";



//微信参数
static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *kAuthOpenID = @"0c806938e2413ce73eef92cc3";
static NSString *kAuthState = @"xxx";
static NSString *WECHAT_APPID = @"wx490857e2baff7cfd";

//阿里云参数
static NSString *aliOSSEndPoint = @"http://oss-cn-hangzhou.aliyuncs.com";
static NSString *aliOSSBucketName = @"rzico-weex";

//主题颜色
static int UINavigationBarColor = 0xEB4E40;

//本地资源版本号
static NSString *localResVersion = @"1.0.3";

//伪协议头
static NSString *openURLScheme = @"yundian";

//应用名
#define DisplayName [[NSBundle mainBundle].infoDictionary objectForKey:@"Bundle display name"]
#endif /* Settings_h */

