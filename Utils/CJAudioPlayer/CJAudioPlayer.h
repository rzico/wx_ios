//
//  CJAudioPlayer.h
//  Weex
//
//  Created by macOS on 2017/12/18.
//  Copyright © 2017年 rzico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVPlayer.h>

@interface CJAudioPlayer : NSObject

@property (nonatomic, strong) AVPlayer *player;

+ (instancetype)shareInstance;
- (void)play:(NSString *)url;
- (void)stop;

@end
