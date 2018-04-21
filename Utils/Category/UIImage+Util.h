//
//  UIImage+Util.h
//  iosapp
//
//  Created by ChanAetern on 2/13/15.
//  Copyright (c) 2015 oschina. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;
- (UIImage *)cropToRect:(CGRect)rect;
- (UIImage *)circleImage;
- (UIImage *)OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
- (UIImage *) imageCompressForWidthScale:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;
- (NSString *)getPNGImagePathWithUuid:(NSString *)uuid;
- (NSString *)getJPGImagePathWithUuid:(NSString *)uuid compressionQuality:(CGFloat)compressionQuality;
+ (NSString *)getGIFImagePathWithUuid:(NSString *)uuid data:(NSData *)data;
+ (UIImage *)createImageWithColor:(UIColor *)color frame:(CGRect)rect;
@end
