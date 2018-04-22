//
//  CLChangeImage.m
//  CLImageEditor
//
//  Created by macOS on 2017/11/18.
//

#import "CLChangeImage.h"

@implementation CLChangeImage

+ (NSString*)defaultTitle
{
    return @"换图";
}

+ (BOOL)isAvailable
{
    return ([UIDevice iosVersion] >= 5.0);
}

@end
