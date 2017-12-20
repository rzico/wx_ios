//
//  CJPublicKeyManager.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJPublicKeyManager.h"
#import "CJNetworkManager.h"


@implementation CJPublicKeyManager

+ (void)encrypt:(NSString *)data withCallBack:(encryptCallBack)callBack{
    NSString *url = HTTPAPI(@"common/public_key");
    [CJNetworkManager GetHttp:url Parameters:nil Success:^(NSURLSessionDataTask *task, id  _Nonnull responseObject) {
        NSString *cipherString = nil;
        if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]){
            if ([[responseObject objectForKey:@"type"] isEqualToString:@"success"]){
                NSError *error;
                CJPublicKeyData *public = [[CJPublicKeyData alloc] initWithDictionary:[responseObject objectForKey:@"data"] error:&error];
                if (!error){
                    public.modulus = [public.modulus stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
                    public.modulus = [public.modulus stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
                    public.modulus = [public.modulus stringByReplacingOccurrencesOfString:@"_" withString:@"/"];
                    NSData *moduluData = [[NSData alloc] initWithBase64EncodedString:public.modulus options:0];
                    NSString *moduluString = [CJPublicKeyManager convertDataToHexStr:moduluData];
                    public.exponent = [public.exponent stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
                    NSData *expData = [[NSData alloc] initWithBase64EncodedString:public.exponent options:0];
                    NSString *expString = [CJPublicKeyManager convertDataToHexStr:expData];
                    RSA *publicKey = [DDRSAWrapper publicKeyFormMod:moduluString exp:expString];
                    if (publicKey){
                        NSMutableData *cipherData = [NSMutableData new];
                        NSData *plainData = [data dataUsingEncoding:NSUTF8StringEncoding];
                        int offset = 0;
                        long inputLen = plainData.length;
                        for (int i = 0; inputLen - offset > 0; offset = i * 116){
                            if (inputLen - offset > 116){
                                [cipherData appendData:[DDRSAWrapper encryptWithPublicKey:publicKey plainData:[plainData subdataWithRange:NSMakeRange(offset, 116)]]];
                            }else{
                                [cipherData appendData:[DDRSAWrapper encryptWithPublicKey:publicKey plainData:[plainData subdataWithRange:NSMakeRange(offset, plainData.length - offset)]]];
                            }
                            ++ i;
                        }
                        cipherString = [cipherData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
                        cipherString = [cipherString stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
                        cipherString = [cipherString stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
                        //                        cipherString = [cipherString stringByReplacingOccurrencesOfString:@"=" withString:@""];
                    }else{
                        if (callBack){
                            callBack(nil);
                        }
                    }
                }
            }else{
                if (callBack){
                    callBack(nil);
                }
            }
        }
        if (callBack){
            callBack(cipherString);
        }
    } andFalse:^(NSURLSessionDataTask *task, NSError * _Nonnull error) {
        if (callBack){
            callBack(nil);
        }
    }];
}

+ (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string;
}

@end
