//
//  IMManager.h
//  Weex
//
//  Created by macOS on 2017/12/20.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IMManager : NSObject

typedef NS_ENUM(NSUInteger, IMManagerLoginOption) {
    IMManagerLoginOptionDefault = 0,
    IMManagerLoginOptionForce,
    IMManagerLoginOptionTimeout,
};

+ (IMManager *)sharedInstance;
- (void)loginWithUser:(NSDictionary *)user loginOption:(IMManagerLoginOption)option andBlock:(void (^)(BOOL success))finish;

+ (NSInteger)getUnReadCount;
@end
