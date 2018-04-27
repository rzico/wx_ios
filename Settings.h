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
#define ApplicationID @"com.nihtan.yzgame"
#define SERVICE @"com.nihtan.yzgame"
#define ACCOUNT @"accountUDID"
#define ACCOUNTMD5 @"ACCOUNTMD5"

//高德地图
static NSString *AMapAPIKey = @"98c20f0485d1a19685288a739ec5f505";

//腾讯IM参数
//#define kTLSAppid       @"1400060267"//TLS_APPID
//#define kSdkAppId       @"1400060267"//SDK_APPID
//#define kSdkAccountType @"21224"//用户类型


#define kTLSAppid       @"1400037996"//TLS_APPID
#define kSdkAppId       @"1400037996"//SDK_APPID
#define kSdkAccountType @"25592"//用户类型



//#define kbusiId         6264
#define kbusiId         6263

//服务器参数
#define HTTPAPI(url) [NSString stringWithFormat:@"%@weex/%@.jhtml",WXCONFIG_INTERFACE_PATH,url]
#define HTTPSAPI(url) [NSString stringWithFormat:@"https://%@%@.jhtml",HOST,url]

#define LOCAL_RESOURCE_PATH = [NSString stringWithFormat:@"%@/resource/",DOCUMENT_PATH]


//这个是放大那个动画的背景色值
static NSString *WXCONFIG_COLOR = @"#F0AD3C";

//资源地址
static NSString *WXCONFIG_RESOURCE_PATH = @"http://cdnx.ucmap.com/";

//接口地址
static NSString *WXCONFIG_INTERFACE_PATH = @"https://weex.ucmap.com/";



//微信参数
static NSString *kAuthScope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
static NSString *kAuthOpenID = @"1111";
static NSString *kAuthState = @"xxx";
static NSString *WECHAT_APPID = @"wxxxx-1";

//阿里云参数
//static NSString *aliOSSEndPoint = @"http://oss-cn-hongkong.aliyuncs.com";
static NSString *aliOSSEndPoint = @"http://oss-cn-hangzhou.aliyuncs.com";
static NSString *aliOSSBucketName = @"appcenter";

//主题颜色
static int UINavigationBarColor = 0xEB4E40;

//本地资源版本号
static NSString *localResVersion = @"0.0.0";

//伪协议头
static NSString *openURLScheme = @"nihtan";

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
