//
//  CJDatabaseData.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JSONModel.h>

@interface CJDatabaseData : JSONModel

@property (nonatomic, assign) NSUInteger Id;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *keyword;

@end
