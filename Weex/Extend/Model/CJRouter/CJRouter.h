//
//  CJRouter.h
//  Weex
//
//  Created by macOS on 2018/1/11.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import <JSONModel.h>

@interface CJRouter : JSONModel

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL requireAuth;

@end
