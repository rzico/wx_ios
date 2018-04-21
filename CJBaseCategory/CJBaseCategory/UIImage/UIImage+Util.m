//
//  UIImage+Util.m
//  Application
//
//  Created by 郭书智 on 2018/3/26.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import "UIImage+Util.h"

@implementation UIImage (Util)

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor
{
    NSParameterAssert(maskColor != nil);
    
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIImage *newImage = nil;
    
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, self.scale);
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextTranslateCTM(context, 0.0f, -(imageRect.size.height));
        
        CGContextClipToMask(context, imageRect, self.CGImage);
        CGContextSetFillColorWithColor(context, maskColor.CGColor);
        CGContextFillRect(context, imageRect);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    
    return newImage;
}


- (UIImage *)cropToRect:(CGRect)rect
{
    CGImageRef imageRef   = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return croppedImage;
}


- (UIImage *)circleImage {
    
    // 开始图形上下文
    UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0);
    
    // 获得图形上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 设置一个范围
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    // 根据一个rect创建一个椭圆
    CGContextAddEllipseInRect(ctx, rect);
    
    // 裁剪
    CGContextClip(ctx);
    
    // 将原照片画到图形上下文
    [self drawInRect:rect];
    
    // 从上下文上获取剪裁后的照片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 关闭上下文
    UIGraphicsEndImageContext();
    
    return newImage;
}



/**
 按尺寸
 
 @param image <#image description#>
 @param size <#size description#>
 @return <#return value description#>
 */
-(UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


-(UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth{
    
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    
    CGFloat maxW = MAX(width, height);
    
    CGFloat targetWidth = defineWidth * (width / maxW);
    CGFloat targetHeight = defineWidth * (height / maxW);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if(CGSizeEqualToSize(imageSize, size) == NO){
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }
        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if(widthFactor > heightFactor){
            
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            
        }else if(widthFactor < heightFactor){
            
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil){
        
        //NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *)getPNGImageTempPathWithUuid:(NSString *)uuid{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *basePath = [NSString stringWithFormat:@"%@/temp",cachePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:basePath]){
        [fm createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@.png",basePath,uuid];
    BOOL success = [UIImagePNGRepresentation(self) writeToFile:path atomically:YES];
    return success ? [path stringByReplacingOccurrencesOfString:cachePath withString:@"localCachePath://"] : nil;
}

- (NSString *)getJPGImageTempPathWithUuid:(NSString *)uuid compressionQuality:(CGFloat)compressionQuality{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *basePath = [NSString stringWithFormat:@"%@/temp",cachePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:basePath]){
        [fm createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@.jpg",basePath,uuid];
    BOOL success = [UIImageJPEGRepresentation(self, compressionQuality) writeToFile:path atomically:YES];
    return success ? [path stringByReplacingOccurrencesOfString:cachePath withString:@"localCachePath://"] : nil;
}

+ (NSString *)getGIFImageTempPathWithUuid:(NSString *)uuid data:(NSData *)data{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    NSString *basePath = [NSString stringWithFormat:@"%@/temp",cachePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:basePath]){
        [fm createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [NSString stringWithFormat:@"%@/%@.gif",basePath,uuid];
    BOOL success = [data writeToFile:path atomically:YES];
    return success ? [path stringByReplacingOccurrencesOfString:cachePath withString:@"localCachePath://"] : nil;
}

+ (UIImage *)createImageWithColor:(UIColor *)color frame:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
