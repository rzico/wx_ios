//
//  CJFetchImage.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJFetchImage.h"
#import <Photos/Photos.h>
#import <TZImageManager.h>

@implementation CJFetchImage

+ (id)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id<WXImageOperationProtocol>)fetchAssetWithSchemeUrl:(NSString *)url AndBlock:(CJFetchImageBlock)block{
    NSString *localIdentifier;
    if ([url hasPrefix:@"original://"]){
        localIdentifier = [url stringByReplacingOccurrencesOfString:@"original://" withString:@""];
        PHFetchResult *ph = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:localIdentifier] options:nil];
        if (ph && ph.count > 0){
            [[TZImageManager manager] getOriginalPhotoWithAsset:[ph firstObject] completion:^(UIImage *photo, NSDictionary *info) {
                block(photo);
            }];
        }else{
            block(nil);
        }
    }else if ([url hasPrefix:@"thumb://"]){
        NSLog(@"thumb");
        localIdentifier = [url stringByReplacingOccurrencesOfString:@"thumb://" withString:@""];
        id ph = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:localIdentifier] options:nil];
        CGFloat scale = [UIScreen mainScreen].scale;
        [[PHImageManager defaultManager] requestImageForAsset:[ph firstObject] targetSize:CGSizeMake(60 * scale, 60 * scale) contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            block(result);
        }];
    }
    return self;
}

- (void)fetchVideoWithSchemeUrl:(NSString *)url AndBlock:(void (^)(NSString *path))complete{
    NSString *localIdentifier = [url stringByReplacingOccurrencesOfString:@"video://" withString:@""];
    PHFetchResult *ph = [PHAsset fetchAssetsWithLocalIdentifiers:[NSArray arrayWithObject:localIdentifier] options:nil];
    if (ph && ph.count > 0){
        [[TZImageManager manager] getVideoOutputPathWithAsset:[ph firstObject] presetName:@"AVAssetExportPreset1280x720" success:^(NSString *outputPath) {
            complete(outputPath);
        } failure:^(NSString *errorMessage, NSError *error) {
            complete(nil);
        }];
    }else{
        complete(nil);
    }
}

- (void)cancel{
    
}
@end
