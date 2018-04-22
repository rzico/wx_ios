//
//  CJCallbackMessage.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CJCallbackMessage : NSObject

@property (nonatomic, assign) BOOL type;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) id data;

- (NSDictionary *)getMessage;

@end
