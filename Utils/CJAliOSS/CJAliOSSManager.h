//
//  CJAliOSSManager.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CJAliOSSUploadBlock)(NSString  * url);
typedef void(^CJAliOSSUploadProcessBlock)(NSString  * percent);

@interface CJAliOSSManager : NSObject

+ (CJAliOSSManager *)defautManager;
- (void)uploadObjectAsyncWithPath:(NSString *)path AndBlock:(CJAliOSSUploadBlock)block AndProcess:(CJAliOSSUploadProcessBlock)process;

@end
