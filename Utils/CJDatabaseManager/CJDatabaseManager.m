//
//  CJDatabaseManager.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJDatabaseManager.h"
#import <FMDB.h>
#import <sqlite3.h>

static FMDatabase *_db;

@implementation CJDatabaseManager

+ (CJDatabaseManager *)defaultManager{
    static CJDatabaseManager *manager;
    if (!manager){
        manager = [CJDatabaseManager new];
        if (![manager initializeDatabase]){
            manager = nil;
        }
    }
    return manager;
}

- (BOOL)initializeDatabase{
    // 确认可操作数据是否存在
    [self createEditableDatabase];
    // 数据库路径
    NSString *path = [CJDatabaseManager pathWithDatabase];
    // 是否打开成功
    _db = [FMDatabase databaseWithPath:path];
    
    BOOL success = [_db open];
    [_db close];
    if (success){
        NSLog(@"Open database success");
        return YES;
    }else{
        NSAssert1(0, @"Failed to open database: '%@'.", [_db lastErrorMessage]);
        return NO;
    }
}

+ (NSString *)pathWithDatabase{
    return [DOCUMENT_PATH stringByAppendingPathComponent:@"data.db"];
}

- (void)createEditableDatabase{
    BOOL success;
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writableDB = [CJDatabaseManager pathWithDatabase];
    success = [fileManager fileExistsAtPath:writableDB];
    if (!success){
        NSString *defaultPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"data.db"];
        success = [fileManager copyItemAtPath:defaultPath toPath:writableDB error:&error];
        
        if (!success){
            NSAssert1(0, @"Failed to create writable database file:'%@'.", [error localizedDescription]);
        }
    }
}

- (CJDatabaseSaveType)save:(CJDatabaseData *)model{
    BOOL success = NO;
    [_db open];
    CJDatabaseData *data = [self findWithUserId:(unsigned long)[model.userId longLongValue] AndType:model.type AndKey:model.key AndNeedOpen:NO];
    if (data){
        success = [self updateWithId:data.Id AndModel:model];
        if (success){
            [_db close];
            return CJDatabaseSaveTypeUpdate;
        }
    }else{
        [self add:model];
        [_db close];
        return CJDatabaseSaveTypeSave;
    }
    [_db close];
    return CJDatabaseSaveTypeInvalid;
}

- (BOOL)updateWithId:(NSUInteger)Id AndModel:(CJDatabaseData *)model{
    BOOL success = [_db executeUpdate:@"UPDATE redis SET USERID=?,TYPE=?,KEY=?,VALUE=?,SORT=?,KEYWORD=? WHERE ID=?",model.userId,model.type,model.key,model.value,model.sort,model.keyword,[NSNumber numberWithUnsignedInteger:Id]];
    return success;
}

- (CJDatabaseData *)findWithUserId:(NSUInteger)userId AndType:(NSString *)type AndKey:(NSString *)key AndNeedOpen:(BOOL)needOpen{
    if (needOpen){
        [_db open];
    }
    FMResultSet *result = [_db executeQuery:@"SELECT * FROM redis WHERE(USERID=? AND TYPE=? AND KEY=?) LIMIT 1",[NSNumber numberWithUnsignedInteger:userId],type,key];
    if ([result next]){
        CJDatabaseData *model = [CJDatabaseData new];
        model.Id = [[result stringForColumn:@"Id"] integerValue];
        model.userId = [result stringForColumn:@"userId"];
        model.type = [result stringForColumn:@"type"];
        model.key = [result stringForColumn:@"key"];
        model.value = [result stringForColumn:@"value"];
        model.sort = [result stringForColumn:@"sort"];
        model.keyword = [result stringForColumn:@"keyword"];
        if (needOpen){
            [_db close];
        }
        return model;
    }else{
        if (needOpen){
            [_db close];
        }
        return nil;
    }
}

- (NSArray *)findListWithUserId:(NSUInteger)userId AndOption:(CJDatabaseOption *)option {
    [_db open];
    
    option.orderBy = [[option.orderBy lowercaseString]  isEqual: @"asc"] ? @"ASC" : @"DESC";
    
    NSMutableArray<CJDatabaseData *> *dataArray = [NSMutableArray<CJDatabaseData *> new];
    
    FMResultSet *result;
    
    NSString *query = [NSString string];
    
    query = [NSString stringWithFormat:@"SELECT * FROM redis WHERE(USERID=? AND TYPE=? AND KEYWORD like \'%%%@%%\') ORDER BY SORT %@",option.keyword,option.orderBy];
    
    if (option.type.length <= 0){
        query = [query stringByReplacingOccurrencesOfString:@"AND TYPE=? " withString:@"AND TYPE IN (\'article\',\'message\',\'friend\') "];
    }
    
    if (option.pageSize > 0){
        query = [query stringByAppendingString:@" LIMIT ? OFFSET ?"];
        if (option.type.length <= 0){
            result = [_db executeQuery:query,[NSNumber numberWithUnsignedInteger:userId],[NSNumber numberWithUnsignedInteger:option.pageSize],[NSNumber numberWithUnsignedInteger:option.current]];
        }else{
            result = [_db executeQuery:query,[NSNumber numberWithUnsignedInteger:userId],option.type,[NSNumber numberWithUnsignedInteger:option.pageSize],[NSNumber numberWithUnsignedInteger:option.current]];
        }
    }else{
        if (option.type.length <= 0){
            result = [_db executeQuery:query,[NSNumber numberWithUnsignedInteger:userId]];
        }else{
            result = [_db executeQuery:query,[NSNumber numberWithUnsignedInteger:userId],option.type];
        }
        
    }
    
    while ([result next]) {
        CJDatabaseData *model = [CJDatabaseData new];
        model.Id = [[result stringForColumn:@"Id"] integerValue];
        model.userId = [result stringForColumn:@"userId"];
        model.type = [result stringForColumn:@"type"];
        model.key = [result stringForColumn:@"key"];
        model.value = [result stringForColumn:@"value"];
        model.sort = [result stringForColumn:@"sort"];
        model.keyword = [result stringForColumn:@"keyword"];
        [dataArray addObject:model];
    }
    [_db close];
    return dataArray;
}

- (NSUInteger)add:(CJDatabaseData *)model{
    BOOL success = [_db executeUpdate:@"INSERT INTO redis(USERID,TYPE,KEY,VALUE,SORT,KEYWORD) VALUES(?,?,?,?,?,?)",model.userId,model.type,model.key,model.value,model.sort,model.keyword];
    sqlite_int64 Id = -1;
    if (success){
        Id = [_db lastInsertRowId];
    }
    return (NSUInteger)Id;
}

- (BOOL)deleteWithUserId:(NSUInteger)userId AndType:(NSString *)type AndKey:(NSString *)key{
    [_db open];
    BOOL success = [_db executeUpdate:@"DELETE FROM redis WHERE USERID=? AND TYPE=? AND KEY=?",[NSNumber numberWithUnsignedInteger:userId],type,key];
    [_db close];
    return success;
}

- (BOOL)deleteDataList:(NSUInteger)userId AndType:(NSString *)type{
    [_db open];
    BOOL success = [_db executeUpdate:@"DELETE FROM redis WHERE USERID=? AND    TYPE=?",[NSNumber numberWithUnsignedInteger:userId],type];
    [_db close];
    return success;
}
@end
