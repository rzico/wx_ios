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
#define ApplicationID @"me.1xx.mopian"
#define SERVICE @"me.1xx.mopian"
#define ACCOUNT @"accountUDID"
#define ACCOUNTMD5 @"ACCOUNTMD5"

//高德地图
static NSString *AMapAPIKey = @"bcf25ba754b2da49b28db6e52a5ecee9";

//腾讯IM参数
#define kTLSAppid       @"1400051564"//TLS_APPID
#define kSdkAppId       @"1400051564"//SDK_APPID
#define kSdkAccountType @"19934"//用户类型

//开发环境
//#define kbusiId         6684

//生产环境
#define kbusiId         6683

//服务器参数
#define HTTPAPI(url) [NSString stringWithFormat:@"%@weex/%@.jhtml",WXCONFIG_INTERFACE_PATH,url]
#define HTTPSAPI(url) [NSString stringWithFormat:@"https://%@%@.jhtml",HOST,url]

#define LOCAL_RESOURCE_PATH = [NSString stringWithFormat:@"%@/resource/",DOCUMENT_PATH]


//这个是放大那个动画的背景色值
static NSString *WXCONFIG_COLOR = @"#F0AD3C";

//资源地址
static NSString *WXCONFIG_RESOURCE_PATH = @"http://cdnx.1xx.me/";

//接口地址
//static NSString *WXCONFIG_INTERFACE_PATH = @"http://weex.1xx.me/";
//static NSString *WXCONFIG_INTERFACE_PATH = @"http://192.168.2.110:8088/";
static NSString *WXCONFIG_INTERFACE_PATH = @"http://mopian.1xx.me/";


//微信参数
static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *kAuthOpenID = @"e1a6bffb5ad1eb7ffa2f442032df2d78";
static NSString *kAuthState = @"xxx";
static NSString *WECHAT_APPID = @"wxe9044e4a3a478046";

//阿里云参数
static NSString *aliOSSEndPoint = @"http://oss-cn-hangzhou.aliyuncs.com";
static NSString *aliOSSBucketName = @"mopian";

//主题颜色
static int UINavigationBarColor = 0x99CCFF;

//本地资源版本号
static NSString *localResVersion = @"1.0.5";

//伪协议头
static NSString *openURLScheme = @"mopian";

//应用名
#define DisplayName [[NSBundle mainBundle].infoDictionary objectForKey:@"CFBundleDisplayName"]

//根视图配置
typedef NS_ENUM(NSUInteger, RootViewType) {
    RootViewTypeSingleView,//单视图模式
    RootViewTypeTabbar,//Tabbar模式
};
static RootViewType CJRootViewType = RootViewTypeTabbar;
static NSString *SingleViewRootPath = @"file://view/index.js";

//是否启用IM
static BOOL CJTIMEnabled = true;

//登录页面
static NSString *UninstalledWechatLoginPath = @"file://view/login/index.js";
static NSString *InstalledWechatLoginPath = @"file://view/index.js";
#endif /* Settings_h */
