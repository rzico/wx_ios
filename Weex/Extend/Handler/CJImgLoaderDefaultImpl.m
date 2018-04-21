/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import "CJImgLoaderDefaultImpl.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CJFetchImage.h"

#define MIN_IMAGE_WIDTH 36
#define MIN_IMAGE_HEIGHT 36

#if OS_OBJECT_USE_OBJC
#undef  WXDispatchQueueRelease
#undef  WXDispatchQueueSetterSementics
#define WXDispatchQueueRelease(q)
#define WXDispatchQueueSetterSementics strong
#else
#undef  WXDispatchQueueRelease
#undef  WXDispatchQueueSetterSementics
#define WXDispatchQueueRelease(q) (dispatch_release(q))
#define WXDispatchQueueSetterSementics assign
#endif

@interface CJImgLoaderDefaultImpl()

@property (WXDispatchQueueSetterSementics, nonatomic) dispatch_queue_t ioQueue;

@end

@implementation CJImgLoaderDefaultImpl

#pragma mark -
#pragma mark WXImgLoaderProtocol

- (id<WXImageOperationProtocol>)downloadImageWithURL:(NSString *)url imageFrame:(CGRect)imageFrame userInfo:(NSDictionary *)userInfo completed:(void(^)(UIImage *image,  NSError *error, BOOL finished))completedBlock
{
    url = [url rewriteURL];
    
    
    if ([url hasPrefix:@"original:"] || [url hasPrefix:@"thumb:"]){
        return [[CJFetchImage sharedInstance] fetchAssetWithSchemeUrl:url AndBlock:^(UIImage *image) {
            if (image){
                completedBlock(image, nil, YES);
            }else{
                completedBlock(image, nil, NO);
            }
        }];
    }else{
        return (id<WXImageOperationProtocol>)[[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:url] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            completedBlock(image, error, finished);
        }];
    }
}



@end
