//
//  CJUpdateManager.h
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UpdateResult) {
    UpdateResultConnectionERROR = 0,
    UpdateResultGetResInfoERROR,
    UpdateResultDownloadERROR,
    UpdateResultReleaseERROR,
    UpdateResultNoUpdate,
    UpdateResultUpdating,
    UpdateResultSuccess
};

@protocol CJUpdateDelegate <NSObject>

- (void)updateWithResult:(UpdateResult)complete;
- (void)updateWithDownloadProgress:(CGFloat)progress;

@end

@interface CJUpdateManager : NSObject

@property (nonatomic, strong) id<CJUpdateDelegate> delegate;
@property (nonatomic, strong) NSDictionary *resourceInfo;

+ (CJUpdateManager *)sharedInstance;
- (void)checkUpdate;
@end
