//
//  CJShareManager.m
//  Weex
//
//  Created by macOS on 2017/11/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJShareManager.h"
#import "UIImage+Util.h"


@implementation CJShareManager

+ (instancetype)initWithOption:(NSDictionary *)option complete:(ShareComplete)complete{
    CJShareManager *manager = [[CJShareManager alloc] init];
    manager.option = option;
    manager.complete = complete;
    return manager;
}


+ (void)shareWithWeixin:(NSDictionary *)option complete:(ShareComplete)complete{
    NSString *title = [option objectForKey:@"title"];
    NSString *text = [option objectForKey:@"text"];
    NSString *imageUrl = [option objectForKey:@"imageUrl"];
    NSString *url = [option objectForKey:@"url"];
    NSString *type = [option objectForKey:@"type"];
    
    
    NSMutableDictionary *message = [NSMutableDictionary new];
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]){
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = url;
        
        WXMediaMessage *mediaMessage = [WXMediaMessage message];
        mediaMessage.title = title;
        mediaMessage.description = text;
        mediaMessage.mediaObject = ext;
        mediaMessage.messageExt = nil;
        mediaMessage.messageAction = nil;
        
        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]];
        
        image = [image imageCompressForWidthScale:image targetWidth:200];
        
        [mediaMessage setThumbImage:image];
        mediaMessage.mediaTagName = nil;
        
        enum WXScene scene = WXSceneSession;
        if ([type isEqualToString:@"appMessage"]){
            scene = WXSceneSession;
        }else if([type isEqualToString:@"timeline"]){
            scene = WXSceneTimeline;
        }else if ([type isEqualToString:@"favorite"]){
            scene = WXSceneFavorite;
        }
        
        SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
        req.scene = scene;
        req.message = mediaMessage;
        
        
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.wxShareComplete = ^(SendMessageToWXResp *resp) {
            switch (resp.errCode) {
                case 0:
                    [message setObject:@"success" forKey:@"type"];
                    [message setObject:@"分享成功" forKey:@"content"];
                    [message setObject:@"" forKey:@"data"];
                    break;
                case -1:
                    [message setObject:@"error" forKey:@"type"];
                    [message setObject:@"错误" forKey:@"content"];
                    [message setObject:@"-1" forKey:@"data"];
                    break;
                case -2:
                    [message setObject:@"error" forKey:@"type"];
                    [message setObject:@"用户取消" forKey:@"content"];
                    [message setObject:@"-2" forKey:@"data"];
                    break;
                case -3:
                    [message setObject:@"error" forKey:@"type"];
                    [message setObject:@"发送失败" forKey:@"content"];
                    [message setObject:@"-3" forKey:@"data"];
                    break;
                case -4:
                    [message setObject:@"error" forKey:@"type"];
                    [message setObject:@"授权失败" forKey:@"content"];
                    [message setObject:@"-4" forKey:@"data"];
                    break;
                case -5:
                    [message setObject:@"error" forKey:@"type"];
                    [message setObject:@"微信不支持" forKey:@"content"];
                    [message setObject:@"-5" forKey:@"data"];
                    break;
                default:
                    [message setObject:@"error" forKey:@"type"];
                    [message setObject:@"未知错误" forKey:@"content"];
                    [message setObject:@"unknown" forKey:@"data"];
                    break;
            }
            if (complete){
                NSLog(@"resp=%@",message);
                complete(message);
            }
        };
        [WXApi sendReq:req];
    }else{
        [message setObject:@"error" forKey:@"type"];
        [message setObject:@"未安装微信或无法打开授权" forKey:@"content"];
        [message setObject:@"unknown" forKey:@"data"];
        if (complete){
            complete(message);
        }
    }
}

+ (void)shareWithPasteBoard:(NSDictionary *)option complete:(ShareComplete)complete{
    NSString *title = [option objectForKey:@"title"];
    NSString *text = [option objectForKey:@"text"];
    NSString *url = [option objectForKey:@"url"];
    NSMutableDictionary *message = [NSMutableDictionary new];
    if (url.length){
        NSString *pasteBoardString = [NSString stringWithFormat:@"%@\r\n%@\r\n%@",title,text,url];
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        pasteBoard.string = pasteBoardString;
        [message setObject:@"success" forKey:@"type"];
        [message setObject:@"复制成功" forKey:@"content"];
        [message setObject:@"" forKey:@"data"];
    }else{
        [message setObject:@"error" forKey:@"type"];
        [message setObject:@"复制失败" forKey:@"content"];
        [message setObject:@"URL不能为空" forKey:@"data"];
    }
    if (complete){
        complete(message);
    }
}

+ (void)shareWithBrowser:(NSDictionary *)option complete:(ShareComplete)complete{
    NSString *textURL = [option objectForKey:@"url"];
    NSMutableDictionary *message = [NSMutableDictionary new];
    if (textURL.length){
        NSURL *url = [NSURL URLWithString:textURL];
        [[UIApplication sharedApplication] openURL:url];
        [message setObject:@"success" forKey:@"type"];
        [message setObject:@"分享成功" forKey:@"content"];
        [message setObject:@"" forKey:@"data"];
    }else{
        [message setObject:@"error" forKey:@"type"];
        [message setObject:@"打开失败" forKey:@"content"];
        [message setObject:@"URL不能为空" forKey:@"data"];
    }
    if (complete){
        complete(message);
    }
}
@end
