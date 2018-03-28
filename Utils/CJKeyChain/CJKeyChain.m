//
//  CJKeyChain.m
//  Weex
//
//  Created by macOS on 2017/12/17.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJKeyChain.h"

@implementation CJUUID

+ (NSString *)getUUID{
    NSString *strUUID = (NSString *)[CJKeyChain load:nil];
    if (!strUUID || strUUID.length <= 0){
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        strUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
        [CJKeyChain save:nil data:strUUID];
    }
    return [[strUUID stringByReplacingOccurrencesOfString:@"-" withString:@""] lowercaseString];
}

@end



@implementation CJKeyChain

+ (void)save:(nullable NSString *)service data:(id)data{
    NSString *CJService = !service ? [self defaultService] : service;
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery:CJService];
    SecItemDelete((CFDictionaryRef)keyChainQuery);
    [keyChainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keyChainQuery, NULL);
}

+ (id)load:(nullable NSString *)service{
    NSString *CJService = !service ? [self defaultService] : service;
    id ret = nil;
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery:CJService];
    [keyChainQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
    [keyChainQuery setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keyChainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *e) {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    return ret;
}

+ (void)delete:(nullable NSString *)service{
    NSString *CJService = !service ? [self defaultService] : service;
    NSMutableDictionary *keyChainQuery = [self getKeyChainQuery:CJService];
    SecItemDelete((CFDictionaryRef)keyChainQuery);
}

+ (NSString *)defaultService{
    return [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] stringByAppendingString:@".CJKeyChain"];
}

+ (NSMutableDictionary *)getKeyChainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword,(id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
            (id)kSecAttrAccessibleAfterFirstUnlock,(id)kSecAttrAccessible,
            nil];
}
@end
