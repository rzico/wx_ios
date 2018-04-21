//
//  UIImage+Util.h
//  Application
//
//  Created by 郭书智 on 2018/3/26.
//  Copyright © 2018年 macOS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;
- (UIImage *)cropToRect:(CGRect)rect;
- (UIImage *)circleImage;
- (UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
- (UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
- (NSString *)getPNGImageTempPathWithUuid:(NSString *)uuid;
- (NSString *)getJPGImageTempPathWithUuid:(NSString *)uuid compressionQuality:(CGFloat)compressionQuality;
+ (NSString *)getGIFImageTempPathWithUuid:(NSString *)uuid data:(NSData *)data;
+ (UIImage *)createImageWithColor:(UIColor *)color frame:(CGRect)rect;

@end
