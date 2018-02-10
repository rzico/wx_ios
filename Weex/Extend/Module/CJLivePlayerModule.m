//
//  CJLivePlayerModule.m
//  Weex
//
//  Created by macOS on 2018/1/30.
//  Copyright © 2018年 rzico. All rights reserved.
//

#import "CJLivePlayerModule.h"
#import "CJLivePlayerViewController.h"
#import "CJRouterViewController.h"

@implementation CJLivePlayerModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(loadUrl:video:method:callback:))
WX_EXPORT_METHOD(@selector(test))


- (void)loadUrl:(NSString *)url video:(NSString *)video method:(NSString *)method callback:(WXModuleCallback)callback{
    CJLivePlayerViewController *livePlayer = [[CJLivePlayerViewController alloc] init];
    [weexInstance.viewController presentViewController:livePlayer animated:true completion:^{
        [livePlayer loadWithUrl:url video:video method:method callback:^{
            if (callback){
                callback(@{@"type":@"success",@"content":@"已关闭",@"data":@""});
            }
        }];
    }];
}

- (void)test{
    NSLog(@"ttttttt");
}
@end
