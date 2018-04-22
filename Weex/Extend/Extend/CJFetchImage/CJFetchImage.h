//
//  CJFetchImage.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJImgLoaderDefaultImpl.h"

typedef void(^CJFetchImageBlock)(UIImage *image);

@interface CJFetchImage : NSObject <WXImageOperationProtocol>

+ (id)sharedInstance;
- (id<WXImageOperationProtocol>)fetchAssetWithSchemeUrl:(NSString *)url AndBlock:(CJFetchImageBlock)block;
- (void)fetchVideoWithSchemeUrl:(NSString *)url AndBlock:(void (^)(NSString *path))complete;

@end
