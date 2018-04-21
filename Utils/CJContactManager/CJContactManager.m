//
//  CJContactManager.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJContactManager.h"
#import <LJContactManager.h>
#import <LJPerson.h>

@implementation CJContact

- (void)setNumber:(NSString *)number{
    _number = number;
    _numberMd5 = [MD5_Util md5:number];
    _status = @"";
}

@end

@interface CJContactManager () <UIAlertViewDelegate>

@end

@implementation CJContactManager

+ (id)sharedInstance {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (void)getContactList:(NSDictionary *)option AndBlock:(void (^)(BOOL succeed, NSArray<CJContact *> *contactList))callback{
    [[LJContactManager sharedInstance] accessContactsComplection:^(BOOL succeed, NSArray<LJPerson *> *contacts) {
        if (succeed){
            NSMutableArray<CJContact *> *contactListAll = [NSMutableArray new];
            for (long i = 0; i < contacts.count; i ++){
                for (LJPhone *phone in [contacts objectAtIndex:i].phones){
                    NSString *number = phone.phone;
                    number = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    number = [number stringByReplacingOccurrencesOfString:@"+86" withString:@""];
                    number = [number stringByReplacingOccurrencesOfString:@" " withString:@""];
                    if (number.length == 11){
                        CJContact *contact = [CJContact new];
                        contact.name = [contacts objectAtIndex:i].fullName;
                        contact.number = phone.phone;
                        [contactListAll addObject:contact];
                    }
                }
            }
            NSInteger current = [[option objectForKey:@"current"] integerValue];
            NSInteger pageSize = [[option objectForKey:@"pageSize"] integerValue];
            if (current == 0 && pageSize == 0){
                callback(YES, contactListAll);
            }else{
                NSMutableArray<CJContact *> *contactList = [NSMutableArray new];
                NSInteger end = current + pageSize <= contactListAll.count ? current + pageSize : contactListAll.count;
                for (long i = current; i < end; i ++){
                    [contactList addObject:[contactListAll objectAtIndex:i]];
                }
                callback(YES, contactList);
            }
        }else{
            static int count = 0;
            if (count < 5){
                count ++;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self getContactList:option AndBlock:callback];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您的通讯录暂未允许访问，请去设置->隐私里面授权!" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    [alert show];
                    callback(NO, nil);
                });
            }
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if (@available(iOS 10.0, *)) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                NSLog(@"access=%d",success);
            }];
        } else {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
