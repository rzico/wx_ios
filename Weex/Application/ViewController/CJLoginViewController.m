//
//  CJLoginViewController.m
//  Weex
//
//  Created by macOS on 2017/12/19.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJLoginViewController.h"

@interface CJLoginViewController ()

@end

@implementation CJLoginViewController


- (instancetype)init{
    self = [super init];
    if (self){
        BOOL isSupportLoginWithWechat = [WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi];
        NSString *loginJSPath;
        if (isSupportLoginWithWechat){
            loginJSPath = [DOCUMENT_PATH stringByAppendingPathComponent:InstalledWechatLoginPath];
        }else{
            loginJSPath = [DOCUMENT_PATH stringByAppendingPathComponent:UninstalledWechatLoginPath];
        }
        self.url = [NSURL fileURLWithPath:loginJSPath];
        [self render:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
