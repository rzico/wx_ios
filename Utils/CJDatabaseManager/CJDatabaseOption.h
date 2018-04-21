//
//  CJDatabaseOption.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CJDatabaseOption : JSONModel

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSString *orderBy;
@property (nonatomic, assign) NSUInteger current;
@property (nonatomic, assign) NSUInteger pageSize;

@end
