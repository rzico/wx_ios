//
//  ChatSystemFacePageView.m
//  TIMChat
//
//  Created by AlexiChen on 16/5/9.
//  Copyright © 2016年 AlexiChen. All rights reserved.
//

#import "ChatSystemFacePageView.h"


@implementation ChatSystemFacePageView

- (void)onClickFace:(UIButton *)btn
{
    //    NSInteger idx = btn.tag - 1;
    ChatSystemFaceItem *item = [[ChatSystemFaceHelper sharedHelper].systemFaces objectAtIndex:btn.tag ];
    if (item)
    {
        [_inputDelegate onInputSystemFace:item];
    }
}

- (void)onClickDelte:(UIButton *)btn
{
    [_inputDelegate onDelete];
}

- (void)addOwnViews
{
    for (NSInteger i = 0; i < 20; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(onClickFace:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        btn.showsTouchWhenHighlighted = YES;
        //        btn.backgroundColor = kRandomFlatColor;
    }
    
    UIButton *del = [UIButton buttonWithType:UIButtonTypeSystem];
    [del setImage:[UIImage imageNamed:@"face_delete"] forState:UIControlStateNormal];
    [del setImage:[UIImage imageNamed:@"face_delete_pressed"] forState:UIControlStateHighlighted];
    [del addTarget:self action:@selector(onClickDelte:) forControlEvents:UIControlEventTouchUpInside];
    del.showsTouchWhenHighlighted = YES;
    [self addSubview:del];
}

- (void)configStart:(NSInteger)index
{
    if (_hasConfiged)
    {
        return;
    }
    NSArray *faces = [ChatSystemFaceHelper sharedHelper].systemFaces;
    
    if (index < 0 || index >= faces.count)
    {
        DebugLog(@"参数错误");
        return;
    }
    NSInteger i = 0;
    while (i < 20)
    {
        UIButton *btn = self.subviews[i];
        if (index + i < faces.count)
        {
            btn.hidden = NO;
            ChatSystemFaceItem *item = faces[index + i];
            btn.tag = item.emojiIndex;
            
            [btn setImage:[item inputGif] forState:UIControlStateNormal];
        }
        else
        {
            btn.hidden = YES;
        }
        
        i++;
    }
    
    _hasConfiged = YES;
}

- (void)relayoutFrameOfSubViews
{
    //表情输入键盘  by cj
    NSLog(@"width=%.0f",self.width);
    
    
    CGSize faceSize = CGSizeMake(30, 30);
    CGSize margin = CGSizeMake(self.width / 20.0, self.height / 18.0);
    
    CGRect rect = self.bounds;
    NSInteger hp = (rect.size.width - faceSize.width * 7 - margin.width * (7 - 1))/2;
    NSInteger vp = (rect.size.height - faceSize.height * 3 - margin.height * (3 - 1))/2;
    
    CGRect faceRect = CGRectInset(rect, hp, vp);
    [self gridViews:self.subviews inColumn:7 size:faceSize margin:margin inRect:faceRect];
}


@end


//定义系统表情界面常量 by cj
const CGFloat SystemFaceView_ContentHeight = 200;

@implementation ChatSystemFaceView


- (instancetype)init
{
    if (self = [super init])
    {
        _contentHeight = SystemFaceView_ContentHeight;
    }
    return self;
}

- (void)addOwnViews
{
    [super addOwnViews];
    
    _pageControl.hidden = NO;
    _pageControl.pageIndicatorTintColor = [UIColor flatGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor flatOrangeColor];
    
    NSInteger count = [ChatSystemFaceHelper sharedHelper].systemFaces.count;
    NSInteger pages = count % 20 ? count / 20 + 1 :  count / 20;
    
    NSMutableArray *pageViews = [NSMutableArray array];
    for (NSInteger i = 0; i < pages; i++)
    {
        ChatSystemFacePageView *page = [[ChatSystemFacePageView alloc] init];
        [pageViews addObject:page];
        
    }
    
    [self setFrameAndLayout:CGRectMake(0, 0, kMainScreenWidth, SystemFaceView_ContentHeight) withPages:pageViews];
    
    
    NSInteger hp = (self.width - 30 * 7 - self.width / 20.0 * (7 - 1))/2;
    //sendbutton by cj
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"发送" forState:UIControlStateNormal];
    button.frame = CGRectMake(MainScreenWidth() - 60 - hp, 0, 60, 30);
    button.layer.cornerRadius = 3;
    [button setBackgroundColor:[UIColor colorWithHex:UINavigationBarColor]];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(sendButtonOnTouchedUp) forControlEvents:UIControlEventTouchUpInside];
    [_pageControl addSubview:button];
}

//Notification "SystemFaceSendButtonOnTouched" by cj
- (void)sendButtonOnTouchedUp{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SystemFaceSendButtonOnTouched" object:nil];
}

- (void)setInputDelegate:(id<ChatSystemFaceInputDelegate>)inputDelegate
{
    for (ChatSystemFacePageView *view in _pages)
    {
        view.inputDelegate = inputDelegate;
    }
}

- (void)loadPage:(NSInteger)page feedBack:(BOOL)need
{
    [super loadPage:page feedBack:need];
    
    if (page >= 0 && page < _pages.count)
    {
        ChatSystemFacePageView *pageView = (ChatSystemFacePageView *)_pages[page];
        [pageView configStart:page * 20];
    }
    
}
- (void)relayoutFrameOfSubViews
{
    //pagecontrol frame by cj
    [_pageControl sizeWith:CGSizeMake(self.bounds.size.width, 30)];
    [_pageControl layoutParentHorizontalCenter];
    
    [_pageControl alignParentBottomWithMargin:5];
    _scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 30);
}


@end

