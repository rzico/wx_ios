//
//  CJAliOSSData.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CJAliOSSData : JSONModel

@property (nonatomic, copy) NSString *AccessKeyId;
@property (nonatomic, copy) NSString *AccessKeySecret;
@property (nonatomic, copy) NSString *Expiration;
@property (nonatomic, copy) NSString *SecurityToken;

@end
