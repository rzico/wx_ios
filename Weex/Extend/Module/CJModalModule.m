//
//  WXModalModule.m
//  Weex
//
//  Created by 郭书智 on 2017/10/10.
//  Copyright © 2017年 rsico. All rights reserved.
//

#import "CJModalModule.h"

static NSString *WXModalCallbackKey;

typedef enum : NSUInteger {
    WXModalTypeToast = 1,
    WXModalTypeAlert,
    WXModalTypeConfirm,
    WXModalTypePrompt
} WXModalType;

@implementation CJModalModule{
    NSMutableSet *_alertViews;
}

#pragma mark - Prompt

- (void)prompt:(NSDictionary *)param callback:(WXModuleCallback)callback
{
    NSString *message = [self stringValue:param[@"message"]];
    NSString *defaultValue = [self stringValue:param[@"default"]];
    NSString *placeholder = [self stringValue:param[@"placeholder"]];
    NSString *okTitle = [self stringValue:param[@"okTitle"]];
    NSString *cancelTitle = [self stringValue:param[@"cancelTitle"]];
    
    if ([WXUtility isBlankString:okTitle]) {
        okTitle = @"OK";
    }
    if ([WXUtility isBlankString:cancelTitle]) {
        cancelTitle = @"Cancel";
    }
    if ([WXUtility isBlankString:defaultValue]) {
        defaultValue = @"";
    }
    if ([WXUtility isBlankString:placeholder]) {
        placeholder = @"";
    }
    
    [self alert:message okTitle:okTitle cancelTitle:cancelTitle defaultText:defaultValue placeholder:placeholder callback:callback];
}


#pragma mark - Private

- (void)alert:(NSString *)message okTitle:(NSString *)okTitle cancelTitle:(NSString *)cancelTitle defaultText:(NSString *)defaultText placeholder:(NSString *)placeholder callback:(WXModuleCallback)callback
{
    if (!message) {
        if (callback) {
            callback(@"Error: message should be passed correctly.");
        }
        return;
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:message delegate:self cancelButtonTitle:cancelTitle otherButtonTitles:okTitle, nil];

    
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.placeholder = placeholder;
    textField.text = defaultText;
    alertView.tag = WXModalTypePrompt;
    
    
    objc_setAssociatedObject(alertView, &WXModalCallbackKey, [callback copy], OBJC_ASSOCIATION_COPY_NONATOMIC);
    [_alertViews addObject:alertView];
    
    WXPerformBlockOnMainThread(^{
        [alertView show];
    });
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == WXModalTypePrompt){
        NSString *clickTitle = [alertView buttonTitleAtIndex:buttonIndex];
        NSString *text= [[alertView textFieldAtIndex:0] text] ?: @"";
        id result = @"";
        result = @{ @"result": clickTitle, @"data": text };
        WXModuleCallback callback = objc_getAssociatedObject(alertView, &WXModalCallbackKey);
        if (!callback) return;
        callback(result);
        
        [_alertViews removeObject:alertView];
    }else{
        [super alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
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
