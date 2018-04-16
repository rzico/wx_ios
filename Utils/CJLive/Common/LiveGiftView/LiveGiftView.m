//
//  LiveGiftView.m
//  BaoUU
//
//  Created by 吴小虑 on 2017/10/21.
//  Copyright © 2017年 Mr.Dai. All rights reserved.
//

#import "LiveGiftView.h"

static NSMutableArray *giftList;

@interface LiveGiftView ()

@property (nonatomic,copy) NSString *title;

@property (nonatomic,assign) NSInteger interl;

@property (nonatomic,assign) NSString *giftID;

@property (nonatomic,assign) NSInteger giftNum;

@end

@implementation LiveGiftView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.title = [NSString new];
    self.sendBtn.backgroundColor = [UIColor whiteColor];
    self.sendBtn.layer.cornerRadius = 2;
    self.sendBtn.layer.masksToBounds = YES;
    self.sendBtn.layer.borderColor = RGB(59, 58, 58).CGColor;
    self.sendBtn.layer.borderWidth = 1;
    self.isFirstClick = YES;
    self.chooseimage.hidden = YES;
    self.giftNum = 1;
}

- (void)changeSendBtn:(UIButton *)btn{
    if (!self.isFirstClick) {
        self.isFirstClick = NO;
        return;
    }
    self.chooseimage.hidden = NO;
    [self.chooseimage sameWith:btn];
    self.sendBtn.backgroundColor = RGBOF(0xdd4242);
    self.sendBtn.layer.borderColor = RGBOF(0xdd4242).CGColor;
    self.sendBtn.layer.borderWidth = 1;
    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}
- (IBAction)sendSSS:(id)sender {
//    self.title = @"送了【666】";
//    self.interl = 1;
//    self.giftID = @"1";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[0] objectForKey:@"name"]];
    self.interl = [[giftList[0] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[0] objectForKey:@"id"] longValue]];
    [self changeSendBtn:sender];
}
- (IBAction)sendRoseBtn:(id)sender {
//    self.title = @"送了【棒棒糖】";
//    self.interl = 3;
//     self.giftID = @"2";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[1] objectForKey:@"name"]];
    self.interl = [[giftList[1] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[1] objectForKey:@"id"] longValue]];
     [self changeSendBtn:sender];
}
- (IBAction)sendLoveBtn:(id)sender {
//    self.title = @"送了【爱心】";
//    self.interl = 5;
//     self.giftID = @"3";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[2] objectForKey:@"name"]];
    self.interl = [[giftList[2] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[2] objectForKey:@"id"] longValue]];
     [self changeSendBtn:sender];
}
- (IBAction)sendSuger:(id)sender {
//    self.title = @"送了【玫瑰】";
//    self.interl = 10;
//     self.giftID = @"4";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[3] objectForKey:@"name"]];
    self.interl = [[giftList[3] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[3] objectForKey:@"id"] longValue]];
     [self changeSendBtn:sender];
}
- (IBAction)sendMMD:(id)sender {
//    self.title = @"送了【么么哒】";
//    self.interl = 20;
//     self.giftID = @"5";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[4] objectForKey:@"name"]];
    self.interl = [[giftList[4] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[4] objectForKey:@"id"] longValue]];
     [self changeSendBtn:sender];
}
- (IBAction)sendMengMendDaBtn:(id)sender {
//    self.title = @"送了【萌萌哒】";
//    self.interl = 30;
//     self.giftID = @"6";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[5] objectForKey:@"name"]];
    self.interl = [[giftList[5] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[5] objectForKey:@"id"] longValue]];
     [self changeSendBtn:sender];
}
- (IBAction)sendTTQ:(id)sender {
//    self.title = @"送了【甜甜圈】";
//    self.interl = 50;
//     self.giftID = @"7";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[6] objectForKey:@"name"]];
    self.interl = [[giftList[6] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[6] objectForKey:@"id"] longValue]];
     [self changeSendBtn:sender];
}
- (IBAction)sendRedPoket:(id)sender {
//    self.title = @"送了【女神称号】";
//    self.interl = 100;
//     self.giftID = @"8";
    self.title = [NSString stringWithFormat:@"送了【%@】",[giftList[7] objectForKey:@"name"]];
    self.interl = [[giftList[7] objectForKey:@"price"] longValue];
    self.giftID = [NSString stringWithFormat:@"%ld",[[giftList[7] objectForKey:@"id"] longValue]];
    [self changeSendBtn:sender];
}
- (IBAction)giftAdd:(id)sender {
    if (self.giftNum == 6) {
        return;
    }
    self.giftNum ++;
    self.giftNumLabel.text = [NSString stringWithFormat:@"%ld",(long)self.giftNum];
}
- (IBAction)giftMinus:(id)sender {
    if (self.giftNum > 1) {
        self.giftNum --;
        self.giftNumLabel.text = [NSString stringWithFormat:@"%ld",(long)self.giftNum];

    }
}
- (IBAction)configBtn:(id)sender {
    if (!self.isFirstClick) {
        return;
    }
    
    if (self.interl > [self.currentInterl.text integerValue]) {
        [SVProgressHUD showErrorWithStatus:@"当前积分不足"];
        return;
    }
    if (self.giftID.length == 0) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendGift:title:giftID:giftNum:)]) {
        [self.delegate sendGift:self.interl title:self.title giftID:self.giftID giftNum:self.giftNum];
    }
}

- (void)resetViews{
    [self resetView:self.view0 Id:0];
    [self resetView:self.view1 Id:1];
    [self resetView:self.view2 Id:2];
    [self resetView:self.view3 Id:3];
    [self resetView:self.view4 Id:4];
    [self resetView:self.view5 Id:5];
    [self resetView:self.view6 Id:6];
    [self resetView:self.view7 Id:7];
}

- (void)resetView:(UIView *)mView Id:(NSInteger)Id{
    for (UIView *view in mView.subviews){
        if ([view isKindOfClass:[UIImageView class]]){
            [(UIImageView *)view sd_setImageWithURL:[NSURL URLWithString:[giftList[Id] objectForKey:@"thumbnail"]]];
        }else if ([view isKindOfClass:[UILabel class]]){
            UILabel *label = (UILabel *)view;
            if ([label.text containsString:@"积分"]){
                label.text = [NSString stringWithFormat:@"%ld",[[giftList[Id] objectForKey:@"price"] longValue]];
            }else{
                label.text = [giftList[Id] objectForKey:@"name"];
            }
        }
    }
}

+ (void)getGiftList:(void (^)(NSArray *))complete{
    if (!giftList){
        giftList = [[NSMutableArray alloc] init];
        [CJNetworkManager GetHttp:HTTPAPI(@"live/gift/list") Parameters:nil Success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]] && [[responseObject objectForKey:@"content"] equalsString:@"success"]){
                NSArray *arr = [[responseObject objectForKey:@"data"] objectForKey:@"data"];
                if (arr && [arr isKindOfClass:[NSArray class]]){
                    NSArray *result = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                        return [[obj1 objectForKey:@"id"] compare:[obj2 objectForKey:@"id"]];
                    }];
                    giftList = [[NSMutableArray alloc] initWithArray:result];
                    complete(giftList);
                }else{
                    complete(nil);
                }
            }else{
                [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
                complete(nil);
            }
            NSLog(@"giftlist=%@",responseObject);
        } andFalse:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            [SVProgressHUD showErrorWithStatus:@"网络繁忙，请稍后再试"];
            complete(nil);
        }];
    }else{
        complete(giftList);
    }
}

@end
