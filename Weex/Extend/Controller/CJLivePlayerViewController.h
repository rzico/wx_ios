//
//  CJLivePlayerViewController.h
//  Weex
//
//  Created by macOS on 2018/1/30.
//  Copyright © 2018年 rzico. All rights reserved.
//

typedef void(^LivePlayerDidClosed)(void);

@interface CJLivePlayerViewController : UIViewController

- (void)loadWithUrl:(NSString *)url video:(NSString *)video method:(NSString *)method callback:(LivePlayerDidClosed)callback;


@end
