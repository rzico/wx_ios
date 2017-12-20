//
//  CJALbumData.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJALbumData : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *originalPath;

@property (nonatomic, assign) NSTimeInterval createDate;

@property (nonatomic, assign) NSTimeInterval modifiedDate;

@property (nonatomic, copy) NSString *mimeType;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@property (nonatomic, assign) CGFloat latitude;

@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, assign) NSInteger orientation;

@property (nonatomic, assign) NSUInteger length;

@property (nonatomic, copy) NSString *thumbnailSmallPath;

@end
