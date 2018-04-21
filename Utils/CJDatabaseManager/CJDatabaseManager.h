//
//  CJDatabaseManager.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJDatabaseData.h"
#import "CJDatabaseOption.h"

typedef NS_ENUM(NSInteger, CJDatabaseSaveType) {
    CJDatabaseSaveTypeInvalid = 0,
    CJDatabaseSaveTypeSave,
    CJDatabaseSaveTypeUpdate,
};


@interface CJDatabaseManager : NSObject

+ (CJDatabaseManager *)defaultManager;
- (CJDatabaseSaveType)save:(CJDatabaseData *)data;
- (CJDatabaseData *)findWithUserId:(NSUInteger)userId AndType:(NSString *)type AndKey:(NSString *)key AndNeedOpen:(BOOL)needOpen;
- (NSArray *)findListWithUserId:(NSUInteger)userId AndOption:(CJDatabaseOption *)option;
- (BOOL)deleteWithUserId:(NSUInteger)userId AndType:(NSString *)type AndKey:(NSString *)key;
- (BOOL)deleteDataList:(NSUInteger)userId AndType:(NSString *)type;

@end
