//
//  CJURLProtocol.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJURLProtocol : NSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request;

+ (void)load;

@end
