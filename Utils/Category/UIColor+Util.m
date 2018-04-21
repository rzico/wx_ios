//
//  UIColor+Util.m
//  iosapp
//
//  Created by chenhaoxiang on 14-10-18.
//  Copyright (c) 2014年 oschina. All rights reserved.
//

#import "UIColor+Util.h"
#import "AppDelegate.h"


@implementation UIColor (Util)

#pragma mark - Hex

+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0
                           alpha:alpha];
}

+ (UIColor *)colorWithHex:(int)hexValue
{
    return [UIColor colorWithHex:hexValue alpha:1.0];
}


#pragma mark - theme colors

+ (UIColor *)themeColor
{

#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:0.85];
    }
#endif
    return [UIColor colorWithHex:0x282828];
}


+ (UIColor *)normalButtonColor
{
    return [UIColor colorWithHex:(0xe8cc22/2)];
}


//普通控件的默认颜色
+(UIColor *)widgetColor
{
    return [UIColor colorWithHex:0xf2f2f2];
}

//分割线的颜色
+(UIColor *)CuttingLineColor
{
    return [UIColor colorWithHex:0xf2f2f2];
}

+(UIColor *)normalStatusColor
{
    return [UIColor colorWithHex:0xf2f2f2];
}

+ (UIColor *)nameColor
{
    
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:37.0/255 green:147.0/255 blue:58.0/255 alpha:1.0];
    }
#endif
    return [UIColor colorWithHex:0x087221];
}

+ (UIColor *)titleColor
{
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
#endif
    return [UIColor blackColor];
}

+ (UIColor *)separatorColor
{
    #ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:0.234 green:0.234 blue:0.234 alpha:1.0];
    }
    #endif
    return [UIColor colorWithRed:217.0/255 green:217.0/255 blue:223.0/255 alpha:1.0];
}

+ (UIColor *)cellsColor
{
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:0.17 green:0.17 blue:0.17 alpha:1.0];
    }
#endif
    return [UIColor whiteColor];
}

+ (UIColor *)titleBarColor
{
#ifdef  InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return  [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
#endif
    return [UIColor colorWithHex:0xE1E1E1];
}

+ (UIColor *)contentTextColor
{
    
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return  [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    }
#endif
    
    return [UIColor colorWithHex:0x272727];
}


+ (UIColor *)selectTitleBarColor
{
   #ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return  [UIColor colorWithRed:0.067 green:0.282 blue:0.094 alpha:1.0];
    }
#endif
    return [UIColor colorWithHex:0xE1E1E1];
}

+ (UIColor *)navigationbarColor
{
     #ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:0.067 green:0.282 blue:0.094 alpha:1.0];
    }
#endif
    return [UIColor colorWithHex:0x15A230];//0x009000
}

+ (UIColor *)selectCellSColor
{
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:23.0/255 green:23.0/255 blue:23.0/255 alpha:1.0];
    }
#endif
    return [UIColor colorWithRed:203.0/255 green:203.0/255 blue:203.0/255 alpha:1.0];
}

+ (UIColor *)labelTextColor
{
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:74.0/255 green:74.0/255 blue:74.0/255 alpha:1.0];
    }
#endif
    return [UIColor whiteColor];
}

+ (UIColor *)teamButtonColor
{
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    }
#endif
    return [UIColor colorWithRed:251.0/255 green:251.0/255 blue:253.0/255 alpha:1.0];
}

+ (UIColor *)infosBackViewColor
{
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:24.0/255 green:24.0/255 blue:24.0/255 alpha:0.6];
    }
#endif
    return [UIColor clearColor];
}

+ (UIColor *)lineColor
{
#ifdef InNightMode
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:18.0/255 green:144.0/255 blue:105.0/255 alpha:0.6];
    }
#endif
    return [UIColor colorWithHex:0x2bc157];
}

+ (UIColor *)borderColor
{
#ifdef InNight
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithRed:18.0/255 green:144.0/255 blue:105.0/255 alpha:0.6];
    }
#endif
    return [UIColor lightGrayColor];
}

+ (UIColor *)refreshControlColor
{
#ifdef InNight
    if (((AppDelegate *)[UIApplication sharedApplication].delegate).inNightMode) {
        return [UIColor colorWithHex:0x13502A];
    }
#endif
    return [UIColor colorWithHex:0x21B04B];
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}


+(UIColor *) timeButtonColor
{
    return [UIColor colorWithHex:0x00a0e9];
}


+(UIColor *) guideColor
{
    return [UIColor colorWithHex:0x00aeef];
}

@end
