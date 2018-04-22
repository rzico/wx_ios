//
//  LiveGiftView.h
//  BaoUU
//
//  Created by 吴小虑 on 2017/10/21.
//  Copyright © 2017年 Mr.Dai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LiveGiftViewDelegate <NSObject>

@optional

- (void)sendGift:(NSInteger)interlValue title:(NSString *)title giftID:(NSString *)giftID giftNum:(NSInteger)giftNum;
@end

@interface LiveGiftView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *chooseimage;


@property (weak, nonatomic) IBOutlet UILabel *currentInterl;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet UILabel *giftNumLabel;

@property (nonatomic,assign) BOOL isFirstClick;

@property (weak, nonatomic) id<LiveGiftViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIView *view0;

@property (weak, nonatomic) IBOutlet UIView *view1;

@property (weak, nonatomic) IBOutlet UIView *view2;

@property (weak, nonatomic) IBOutlet UIView *view3;

@property (weak, nonatomic) IBOutlet UIView *view4;

@property (weak, nonatomic) IBOutlet UIView *view5;

@property (weak, nonatomic) IBOutlet UIView *view6;

@property (weak, nonatomic) IBOutlet UIView *view7;

- (void)resetViews;
+ (void)getGiftList:(void(^)(NSArray *giftList))complete;

@end
