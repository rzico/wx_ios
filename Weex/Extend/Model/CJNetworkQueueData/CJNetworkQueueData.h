//
//  CJNetworkQueueData.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WeexSDK/WXResourceRequestHandlerDefaultImpl.h>

@interface CJNetworkQueueData : NSObject

@property (nonatomic, strong) WXResourceRequest *request;
@property (nonatomic, strong) id<WXResourceRequestDelegate> delegate;

@end
