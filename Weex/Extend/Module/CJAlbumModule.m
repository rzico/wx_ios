//
//  WXAlbumModule.m
//  Weex
//
//  Created by 郭书智 on 2017/9/20.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJAlbumModule.h"
#import "WXUtility.h"
#import "CJALbumData.h"
#import <TZImagePickerController.h>
#import <TZImageManager.h>
#import <Photos/Photos.h>
#import "CLImageEditor.h"
#import "IWXToast.h"
#import "CJFetchImage.h"
#import "UIImage+Util.h"

@interface CJAlbumModule()<CLImageEditorDelegate>
@end

@implementation CJAlbumModule{
    WXModuleCallback back;
}

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(openAlbumMuti:))
WX_EXPORT_METHOD(@selector(openAlbumSingle:callback:))
WX_EXPORT_METHOD(@selector(openCrop:callback:))
WX_EXPORT_METHOD(@selector(openPuzzle:callback:))
WX_EXPORT_METHOD(@selector(openVideo:))

- (void)openAlbumSingle:(BOOL)isCrop callback:(WXModuleCallback)callback{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowCrop = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    //是否允许拍照
    imagePickerVc.allowTakePicture = YES;
    //照片排序
    imagePickerVc.sortAscendingByModificationDate = NO;
    
    imagePickerVc.isStatusBarDefault = YES;
    
    imagePickerVc.allowPickingOriginalPhoto = NO;
    
    imagePickerVc.isSelectOriginalPhoto = YES;

    imagePickerVc.naviBgColor = [UIColor colorWithHex:UINavigationBarColor];
    
    imagePickerVc.naviTitleColor = [UIColor colorWithHex:UINavigationBarColor];
    
    
    CGRect bound = weexInstance.viewController.view.frame;
    CGRect frame;
    frame.size.width = bound.size.width;
    frame.size.height = bound.size.width;
    frame.origin.x = 0;
    frame.origin.y = bound.size.height / 2 - frame.size.height / 2;
    
    imagePickerVc.cropRect = frame;
    
    back = callback;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        CJALbumData *album = [CJALbumData new];
        NSString *uuid = [NSString getUUID];
//        NSString *path = [self getImagePath:[photos firstObject] uuid:uuid];
        NSString *path = [[photos firstObject] getJPGImagePathWithUuid:uuid compressionQuality:1.0];
        album.originalPath = path;
        album.thumbnailSmallPath = path;
        
        NSLog(@"%@",path);
        
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = YES;
        message.content = @"选择成功";
        message.data = album;
        if (back){
            back(message.getMessage);
        }
    }];
    [weexInstance.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)openPuzzle:(NSDictionary *)option callback:(WXModuleCallback)callback{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowCrop = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    imagePickerVc.allowPickingGif = NO;
    //是否允许拍照
    imagePickerVc.allowTakePicture = YES;
    //照片排序
    imagePickerVc.sortAscendingByModificationDate = NO;
    
    imagePickerVc.isStatusBarDefault = YES;
    
    imagePickerVc.allowPickingOriginalPhoto = NO;
    
    imagePickerVc.isSelectOriginalPhoto = YES;
    
    imagePickerVc.naviBgColor = [UIColor colorWithHex:UINavigationBarColor];
    
//    imagePickerVc.navigationBar.barStyle = UIBarStyleBlackOpaque
    
    CGRect bound = weexInstance.viewController.view.frame;
    CGRect frame;
    frame.size.width = bound.size.width;
    frame.size.height = bound.size.width / 2;
    frame.origin.x = 0;
    frame.origin.y = bound.size.height / 2 - frame.size.height / 2;
    
    imagePickerVc.cropRect = frame;
    
    back = callback;
    
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        NSString *uuid = [NSString getUUID];
//        NSString *path = [self getImagePath:[photos firstObject] uuid:uuid];
        NSString *path = [[photos firstObject] getJPGImagePathWithUuid:uuid compressionQuality:1.0];
        NSLog(@"%@",path);
        
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = YES;
        message.content = @"选择成功";
        message.data = path;
        if (back){
            back(message.getMessage);
        }
    }];
    [weexInstance.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}


- (void)openCrop:(NSString *)imagePath callback:(WXModuleCallback)callback{
    back = callback;
    NSString *path = [imagePath rewriteURL];
    
    if ([path isContains:@"thumb"] || [path isContains:@"original"]){
        path = [path stringByReplacingOccurrencesOfString:@"thumb" withString:@"original"];
        [[CJFetchImage sharedInstance] fetchAssetWithSchemeUrl:path AndBlock:^(UIImage *image) {
            if (image){
                CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
                editor.delegate = self;
                [weexInstance.viewController presentViewController:editor animated:YES completion:nil];
            }else{
                IWXToast *toast = [IWXToast new];
                [toast showToast:@"无法打开图片" withInstance:nil];
            }
        }];
    }else if ([imagePath hasPrefix:@"http://"]){
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagePath]]];
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:image];
        editor.delegate = self;
        [weexInstance.viewController presentViewController:editor animated:YES completion:nil];
    }else{
        CLImageEditor *editor = [[CLImageEditor alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        editor.delegate = self;
        [weexInstance.viewController presentViewController:editor animated:YES completion:nil];
    }
}

- (void)imageEditorDidCancel:(CLImageEditor *)editor{
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageEditor:(CLImageEditor *)editor didFinishEditingWithImage:(UIImage *)image{
    CJALbumData *album = [CJALbumData new];
    NSString *uuid = [NSString getUUID];
//    NSString *path = [self getImagePath:image uuid:uuid];
    NSString *path = [image getJPGImagePathWithUuid:uuid compressionQuality:1.0];
    album.originalPath = path;
    album.thumbnailSmallPath = path;
    CJCallbackMessage *message = [CJCallbackMessage new];
    message.type = YES;
    message.content = @"选择成功";
    message.data = album;
    if (back){
        back(message.getMessage);
    }
    [editor dismissViewControllerAnimated:YES completion:nil];
}

- (void)openAlbumMuti:(WXModuleCallback)callback{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:100 delegate:nil];
    
    //图片模式
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingVideo = NO;
//    imagePickerVc.allowPickingMultipleVideo = NO;
    imagePickerVc.allowPickingGif = YES;
    
    //是否允许拍照
    imagePickerVc.allowTakePicture = YES;

    //照片排序
    imagePickerVc.sortAscendingByModificationDate = NO;
    
//    imagePickerVc.isStatusBarDefault = YES;
    
    imagePickerVc.allowPickingOriginalPhoto = YES;
    
//    imagePickerVc.isSelectOriginalPhoto = YES;
    
    imagePickerVc.naviBgColor = [UIColor colorWithHex:UINavigationBarColor];
    
    NSString *uuid = [NSString getUUID];
    
    
    
    [imagePickerVc setDidFinishPickingGifImageHandle:^(UIImage *animatedImage, id sourceAssets) {
        
        [[TZImageManager manager] getPhotoWithAsset:sourceAssets completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            NSString *thumbPath = [photo getJPGImagePathWithUuid:uuid compressionQuality:1.0];
            // 再显示gif动图
            [[TZImageManager manager] getOriginalPhotoDataWithAsset:sourceAssets completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
                if (!isDegraded) {
                    NSString *gifPath = [UIImage getGIFImagePathWithUuid:uuid data:data];
                    CJALbumData *album = [CJALbumData new];
                    album.originalPath = gifPath;
                    album.thumbnailSmallPath = thumbPath;
                    if (callback){
                        CJCallbackMessage *message = [CJCallbackMessage new];
                        message.type = YES;
                        message.content = @"选择成功";
                        message.data = [NSArray arrayWithObject:album];
                        callback(message.getMessage);
                    }
                }
            }];
        } progressHandler:nil networkAccessAllowed:NO];
    }];
     
    
    [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
        NSMutableArray *dataArray = [NSMutableArray new];
        for (int i = 0; i < photos.count; i++){
            NSString *path = [[photos objectAtIndex:i] getJPGImagePathWithUuid:uuid compressionQuality:1.0];
            
            
//            NSString *localIdentifier = [[assets objectAtIndex:i] valueForKey:@"localIdentifier"];
//            NSString *thumbnailSmallPath = [NSString stringWithFormat:@"thumb://%@",localIdentifier];
//            NSString *originalPath = [NSString stringWithFormat:@"original://%@",localIdentifier];
            
            
            
            CJALbumData *album = [CJALbumData new];
//            album.originalPath = originalPath;
//            album.thumbnailSmallPath = thumbnailSmallPath;
            album.originalPath = path;
            album.thumbnailSmallPath = path;
            [dataArray addObject:album];
        }
        if (callback){
            CJCallbackMessage *message = [CJCallbackMessage new];
            message.type = YES;
            message.content = @"选择成功";
            message.data = dataArray;
            callback(message.getMessage);
        }
    }];
    [imagePickerVc setImagePickerControllerDidCancelHandle:^{
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = NO;
        message.content = @"取消选择";
        message.data = @"";
        callback(message.getMessage);
    }];
    [weexInstance.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}

//- (NSString *)getImagePath:(UIImage *)image uuid:(NSString *)uuid{
//    static NSString *docDir;
//    static NSString *basePath;
//    if (!docDir){
//        docDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
//        basePath = [NSString stringWithFormat:@"%@/DCIM/100APPLE",docDir];
//    }
//    NSFileManager *fm = [NSFileManager defaultManager];
//    if (![fm fileExistsAtPath:basePath]){
//        [fm createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
//    }
//    NSString *path = [NSString stringWithFormat:@"%@/%@.png",basePath,uuid];
//    BOOL success = [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
//    if (success){
//        return path;
//    }else{
//        return @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3577784738,4111720376&fm=111&gp=0.jpg";
//    }
//}

- (void)openVideo:(WXModuleCallback)callback{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    
    imagePickerVc.allowPickingImage = NO;
//    imagePickerVc.allowCrop = NO;
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingMultipleVideo = NO;
//    imagePickerVc.allowPickingGif = NO;
    //是否允许拍照
//    imagePickerVc.allowTakePicture = YES;
    //照片排序
    imagePickerVc.sortAscendingByModificationDate = NO;
    imagePickerVc.isStatusBarDefault = YES;
    
//    imagePickerVc.allowPickingOriginalPhoto = NO;
//
//    imagePickerVc.isSelectOriginalPhoto = YES;
    
    imagePickerVc.naviBgColor = [UIColor colorWithHex:UINavigationBarColor];
    
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, id asset) {
        NSString *localIdentifier = [asset valueForKey:@"localIdentifier"];
//        NSString *coverImagePath = [self getImagePath:coverImage uuid:[NSString uuid]];
        NSString *coverImagePath = [coverImage getJPGImagePathWithUuid:[NSString getUUID] compressionQuality:1.0];
        NSString *path = [NSString stringWithFormat:@"video://%@",localIdentifier];
        CJCallbackMessage *message = [CJCallbackMessage new];
        message.type = YES;
        message.content = @"选择成功";
        message.data = @{@"coverImagePath":coverImagePath,@"videoPath":path};
        if (callback){
            callback(message.getMessage);
        }
    }];
    [weexInstance.viewController presentViewController:imagePickerVc animated:YES completion:nil];
}
@end
