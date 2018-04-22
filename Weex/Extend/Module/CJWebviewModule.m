//
//  WXWebviewModule.m
//  Weex
//
//  Created by macOS on 2017/11/26.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJWebviewModule.h"
#import "CJWebComponent.h"
#import <WXComponentManager.h>

@implementation CJWebviewModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(getLongImage:callback:))

- (void)performBlockWithWebView:(NSString *)elemRef block:(void (^)(CJWebComponent *))block {
    if (!elemRef) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    WXPerformBlockOnComponentThread(^{
        CJWebComponent *webview = (CJWebComponent *)[weakSelf.weexInstance componentForRef:elemRef];
        if (!webview) {
            return;
        }
        
        [weakSelf performSelectorOnMainThread:@selector(doBlock:) withObject:^() {
            block(webview);
        } waitUntilDone:NO];
    });
}

- (void)doBlock:(void (^)(void))block {
    block();
}

- (void)getLongImage:(NSString *)elemRef callback:(WXModuleCallback)callback{
    [self performBlockWithWebView:elemRef block:^void (CJWebComponent *webview) {
        [webview getLongImage:callback];
    }];
}
@end

