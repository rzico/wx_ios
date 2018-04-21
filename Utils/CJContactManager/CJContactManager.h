//
//  CJContactManager.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

@interface CJContact : NSObject

@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *numberMd5;
@property (nonatomic, copy) NSString *status;

@end


@interface CJContactManager : NSObject

+ (id)sharedInstance;
- (void)getContactList:(NSDictionary *)option AndBlock:(void (^)(BOOL succeed, NSArray<CJContact *> *contactList))callback;

@end
