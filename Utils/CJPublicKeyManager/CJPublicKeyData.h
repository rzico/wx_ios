//
//  CJPublicKeyData.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CJPublicKeyData : JSONModel

@property (nonatomic, copy) NSString *modulus;
@property (nonatomic, copy) NSString *exponent;

@end
