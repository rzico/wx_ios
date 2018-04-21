//
//  ZWXUtilsString.h
//  ZWXUtilsLib
//
//  Created by zhwx on 14-5-8.
//  Copyright (c) 2014年 zhwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import  "UIImage+Util.h"

@interface TXUtilsString : NSObject
/**
 *  获取设备ip
 *
 *
 *  @return 返回设备的ip
 */
+ (NSString *)getIPAddress;
/*
    返回100k以内大小的图片
 */
+(NSData *)imageData:(UIImage *)myimage;

/**
 * 是否为空
 */
+ (BOOL)IsNull:(id)data;

/*
    角色对比
 */
+ (BOOL)compaseRole:(NSArray *)Customize  andAcquire:(NSArray *)Acquire;
/*
 计算字符串高度
 */
+ (CGFloat)AutoHeight:(NSString *)string  font:(CGFloat )font  andCGsize:(CGSize)Size;
/*
 计算字符串宽度
 */
+ (CGFloat)AutoWidth:(NSString *)string  font:(CGFloat )font  andCGsize:(CGSize)Size;
/*
    身份证号验证
 */
+ (BOOL) validateIdentityCard: (NSString *)identityCard;


+(BOOL)identityCardPredicate:(NSString *)identityCard;
/*
 转换时间戳
 */
+ (NSString *)countTime:(NSInteger)date format:(NSDateFormatter *)formatter;

+ (NSString *)countTimeSecond:(float)date;

+ (NSString *)TransformTimestampWith:(NSString *)dateString dateDormate:(NSString *)formate;

/*
 判断是否为银行卡号
 */
+ (BOOL) checkCardNo:(NSString*) cardNo;
/**
 *判断字符串是否为空
 */
+(BOOL)isEmpty:(NSString*)string;
/**
 * 是否为IP
 */
+(BOOL)isIPAdress :(NSString *)ip;

/**
 * 是否为网址
 */
+(BOOL)isValidateUrl:(NSString *)url;
/**
 * 是否为空(string)
 */
+ (BOOL) isBlankString:(NSString *)string;
/**
 * 是否为邮箱
 */
+(BOOL)isValidateEmail:(NSString *)email;

/**
 * 是否为手机号码
 */
//+ (BOOL)valiMobile:(NSString *)mobilePhone;


/**
 * 是否为车牌
 */
+(BOOL) isValidateCarNo:(NSString*)carNo;

/**
 * 是否为数字
 */
+(BOOL)isValidateNum:(NSString *)numString;

/**
 * MD5
 */
+ (NSString *) md5:(NSString *)str;


/**
 * sha1
 */
+(NSString*) sha1:(NSString*)str;


/**
 * Encode Chinese to ISO8859-1 in URL
 */
+ (NSString *) utf8StringWithChinese:(NSString *)chinese;

/**
 * Encode Chinese to GB2312 in URL
 */
+ (NSString *) gb2312StringWithChinese:(NSString *)chinese;

/**
 * URL encode
 */
+(NSString*) urlEncodeWithString:(NSString *)string;

+ (UIImage *)imageNameWith:(NSString *)imageName;
@end

