//
//  CJWeexViewController.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WXModuleProtocol.h>
#import <SRWebSocket.h>

@interface CJWeexViewController : UIViewController

@property (nonatomic, assign) WXModuleCallback callback;
@property (nonatomic, strong) NSDictionary *data;

@property (nonatomic, strong) NSString *script;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) SRWebSocket *hotReloadSocket;
@property (nonatomic, strong) NSString *source;


@property (nonatomic, strong) NSString *label;

- (void)render:(void(^)(BOOL finished))complete;
- (instancetype)initWithUrl:(NSURL *)url;
- (void)setViewHeight:(CGFloat)height;
@end
