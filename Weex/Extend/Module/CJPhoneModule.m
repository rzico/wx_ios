//
//  WXPhoneModule.m
//  Weex
//
//  Created by macOS on 2017/11/30.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJPhoneModule.h"
#import <MessageUI/MessageUI.h>

@implementation CJPhoneModule{
    WXModuleCallback smsCallback;
}

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(tel:callback:))
WX_EXPORT_METHOD(@selector(sms:content:callback:))

- (void)tel:(NSString *)number callback:(WXModuleCallback)callback{
    NSString *urlStr = [NSString stringWithFormat:@"telprompt://%@",number];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    if (callback){
        NSDictionary *dic = @{@"type":@"success",@"content":@"成功",@"data":@""};
        callback(dic);
    }
}

- (void)sms:(NSString *)phone content:(NSString *)content callback:(WXModuleCallback)callback{
    MFMessageComposeViewController *vc = [MFMessageComposeViewController new];
    vc.body = content;
    vc.recipients = @[phone];
    smsCallback = callback;
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    [app.window.rootViewController presentViewController:vc animated:YES completion:nil];
    if (callback){
        NSDictionary *dic = @{@"type":@"success",@"content":@"成功",@"data":@""};
        callback(dic);
    }
}

@end
