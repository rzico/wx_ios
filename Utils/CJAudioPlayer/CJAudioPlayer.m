//
//  CJAudioPlayer.m
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import "CJAudioPlayer.h"
#import <AVFoundation/AVPlayerItem.h>

@implementation CJAudioPlayer

+ (instancetype)shareInstance{
    static CJAudioPlayer *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CJAudioPlayer alloc] init];
        instance.player = [[AVPlayer alloc] init];
    });
    return instance;
}

- (void)play:(NSString *)url{
    if (_player.currentItem){
        [self stop];
    }
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[NSURL URLWithString:url]];
    [_player replaceCurrentItemWithPlayerItem:item];
    [_player play];
}

- (void)stop{
    [_player pause];
    [_player replaceCurrentItemWithPlayerItem:nil];
}

@end
