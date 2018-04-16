//
//  CJLiveProtocolViewController.m
//  LiveTest
//
//  Created by 郭书智 on 2018/3/29.
//  Copyright © 2018年 macOS. All rights reserved.
//

#define HOST @"http://test.baouu.com/"

#import "CJLiveProtocolViewController.h"

@interface CJLiveProtocolViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *aboutView;

@end

@implementation CJLiveProtocolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"泥炭平台直播管理条例"];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setNavigationBarLeftButton];
    [self createWebView];
    // Do any additional setup after loading the view.
}

- (void)setNavigationBarLeftButton{
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    [leftBtn setImage:[UIImage imageNamed:@"back_left_black"] forState:UIControlStateNormal];
    
    [leftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *naviItem = [[UIBarButtonItem alloc] initWithCustomView:leftBtn];
    
    self.navigationItem.leftBarButtonItem=naviItem;
}

- (void)createWebView{
    _aboutView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    _aboutView.delegate = self;
    _aboutView.scalesPageToFit = true;
    _aboutView.scrollView.showsVerticalScrollIndicator = false;
    _aboutView.scrollView.bounces = false;
    [_aboutView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_aboutView];
    
    NSString *httpStr = [NSString stringWithFormat:@"%@wap/integral/Agreement2.jhtml",HOST];
    
    NSURL *httpUrl = [NSURL URLWithString:httpStr];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:httpUrl];
    
    [_aboutView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back{
    [self dismissViewControllerAnimated:true completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:false];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

@end
