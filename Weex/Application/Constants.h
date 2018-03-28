//
//  Constants.h
//  Weex
//
//  Created by macOS on 2017/12/19.
//  Copyright © 2017年 rzico. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#define DOCUMENT_PATH [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]
#define CACHES_PATH [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]
#define TMP_PATH NSTemporaryDirectory()


#define SharedAppDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

#define ROOTNAV ((UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController)


#define ALERT(msg)    if (![[UIApplication sharedApplication].delegate window].rootViewController.presentedViewController) {UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:msg preferredStyle:UIAlertControllerStyleAlert];UIAlertAction * Sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {}];[alert addAction:Sure];[[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:alert animated:YES completion:nil];}
#endif /* Constants_h */
