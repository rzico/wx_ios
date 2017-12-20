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

#endif /* Constants_h */
