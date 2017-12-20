//
//  AudioModule.m
//  Weex
//
//  Created by macOS on 2017/11/21.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJAudioModule.h"
#import "CJAudioPlayer.h"

@implementation CJAudioModule

@synthesize weexInstance;

WX_EXPORT_METHOD(@selector(play:))
WX_EXPORT_METHOD(@selector(stop))

- (void)play:(NSString *)url{
    [[CJAudioPlayer shareInstance] play:url];
}

- (void)stop{
    [[CJAudioPlayer shareInstance] stop];
}

@end
