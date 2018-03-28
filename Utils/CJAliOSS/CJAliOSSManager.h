//
//  CJAliOSSManager.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CJAliOSSUploadResult) {
    CJAliOSSUploadResultFileNotFound = 0,
    CJAliOSSUploadResultSuccess,
    CJAliOSSUploadResultSTSError,
    CJAliOSSUploadResultUploadError
};

typedef void(^CJAliOSSProgressBlock)(NSString *percent);
typedef void(^CJAliOSSCompleteBlock)(CJAliOSSUploadResult result,  NSString * url);

@interface CJAliOSSManager : NSObject

+ (CJAliOSSManager *)defautManager;
- (void)uploadObjectWithPath:(NSString *)path progress:(CJAliOSSProgressBlock)progress complete:(CJAliOSSCompleteBlock)complete;
@end
