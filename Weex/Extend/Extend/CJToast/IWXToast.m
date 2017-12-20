//
//  IWXToast.m
//  Weex
//
//  Created by 郭书智 on 2017/9/29.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "IWXToast.h"

@implementation IWXToast

static const double WXToastDefaultDuration = 3;
static const CGFloat WXToastDefaultFontSize = 16.0;
static const CGFloat WXToastDefaultWidth = 230.0;
static const CGFloat WXToastDefaultHeight = 30.0;
static const CGFloat WXToastDefaultPadding = 30.0;




- (void)showToast:(id)message withInstance:(WXSDKInstance *)instance
{
    self.instance = instance;
    WXPerformBlockOnMainThread(^{
        [self toast:message duration:WXToastDefaultDuration];
    });
}

- (void)toast:(id)message duration:(double)duration
{
    
    UIView *superView =  [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    if (!superView) {
        superView = self.instance.rootView;
    }

    UIView *toastView = [self toastViewForMessage:message superView:superView];
    IWXToastInfo *info = [IWXToastInfo new];
    info.toastView = toastView;
    info.superView = superView;
    info.duration = duration;
    [[IWXToastManager sharedManager].toastQueue addObject:info];
    
    [self showToast:toastView superView:superView duration:duration];
    
//    if (![IWXToastManager sharedManager].toastingView) {
//
//    }
}

- (UIView *)toastViewForMessage:(id)message superView:(UIView *)superView
{
    CGFloat padding = WXToastDefaultPadding;
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding/2, padding/2, WXToastDefaultWidth, WXToastDefaultHeight)];
    messageLabel.numberOfLines =  0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    if ([message isKindOfClass:[NSString class]]){
        messageLabel.text = message;
    }else if([message isKindOfClass:[NSDictionary class]]){
        messageLabel.text = [NSDictionary convertToJsonData:message];
    }else if ([message isKindOfClass:[NSArray class]]){
        NSMutableArray *data = [NSMutableArray new];
        for (id m in message){
            [data addObject:[NSDictionary objectToDictionary:m]];
        }
        NSMutableDictionary *dic = [NSMutableDictionary new];
        [dic setObject:data forKey:@"content"];
        messageLabel.text = [NSDictionary convertToJsonData:dic];
    }else{
        messageLabel.text = [message stringValue];
    }
    messageLabel.font = [UIFont boldSystemFontOfSize:WXToastDefaultFontSize];
    messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.backgroundColor = [UIColor clearColor];
    [messageLabel sizeToFit];
    
    UIView *toastView = [[UIView alloc] initWithFrame:
                         CGRectMake(
                                    (superView.frame.size.width-messageLabel.frame.size.width-padding)/2,
                                    (superView.frame.size.height-messageLabel.frame.size.height-padding)/2,
                                    messageLabel.frame.size.width+padding,
                                    messageLabel.frame.size.height+padding
                                    )];
    
    CGPoint point = CGPointZero;
    UIWindow *window = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    
    // adjust to screen orientation
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait: {
            point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
            break;
        }
        case UIDeviceOrientationPortraitUpsideDown: {
            toastView.transform = CGAffineTransformMakeRotation(M_PI);
            float width = window.frame.size.width;
            float height = window.frame.size.height;
            point = CGPointMake(width/2, height/2);
            break;
        }
        case UIDeviceOrientationLandscapeLeft: {
            toastView.transform = CGAffineTransformMakeRotation(M_PI/2); //rotation in radians
            point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
            break;
        }
        case UIDeviceOrientationLandscapeRight: {
            toastView.transform = CGAffineTransformMakeRotation(-M_PI/2);
            point = CGPointMake(window.frame.size.width/2, window.frame.size.height/2);
            break;
        }
        default:
            break;
    }
    
    toastView.center = point;
    toastView.frame = CGRectIntegral(toastView.frame);
    toastView.tag = 911;
    
    
    [toastView addSubview:messageLabel];
    toastView.layer.cornerRadius = 7;
    toastView.backgroundColor=[UIColor colorWithWhite:0 alpha:0.7];
    
    return toastView;
}

- (void)showToast:(UIView *)toastView superView:(UIView *)superView duration:(double)duration
{
    if (!toastView || !superView) {
        return;
    }
    
//    [superView.layer removeAllAnimations];
//    for (UIView *view in superView.subviews){
//        if (view.tag == 911){
//            [view removeFromSuperview];
//        }
//    }
    
    [IWXToastManager sharedManager].toastingView = toastView;
    [superView addSubview:toastView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2 delay:duration options:UIViewAnimationOptionCurveEaseInOut animations:^{
        toastView.transform = CGAffineTransformConcat(toastView.transform, CGAffineTransformMakeScale(0.8, 0.8)) ;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toastView.alpha = 0;
        } completion:^(BOOL finished){
            [toastView removeFromSuperview];
            [IWXToastManager sharedManager].toastingView = nil;
            
            NSMutableArray *queue = [IWXToastManager sharedManager].toastQueue;
            if (queue.count > 0) {
                [queue removeObjectAtIndex:0];
                if (queue.count > 0) {
                    IWXToastInfo *info = [queue firstObject];
                    [weakSelf showToast:info.toastView superView:info.superView duration:info.duration];
                }
            }
        }];
    }];
}

- (NSString*)stringValue:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        return value;
    }
    if ([value isKindOfClass:[NSNumber class]]) {
        return [value stringValue];
    }
    return nil;
}
@end
