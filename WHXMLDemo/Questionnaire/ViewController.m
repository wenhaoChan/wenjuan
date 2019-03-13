//
//  ViewController.m
//  WHXMLDemo
//
//  Created by zero on 2019/3/8.
//  Copyright © 2019 zero. All rights reserved.
//

#import "ViewController.h"

#import <YYCategories/YYCategories.h>

#import <JavaScriptCore/JavaScriptCore.h>

@interface ViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView* firstView;

@property (nonatomic, strong) UIWebView* webView;

@property (nonatomic, copy) NSArray* file;

@property (nonatomic, strong) JSContext* jsContext;

@end

@implementation ViewController


#pragma mark - life cycles methods


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self loadXmlFile];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    _scrollView.contentSize = CGSizeMake(self.view.width * 2, self.view.height);
}

#pragma mark - private methods

- (void)setupSubviews
{
    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    
    _firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _firstView.backgroundColor = [UIColor colorWithHexString:@"F5F7FA"];
    [_scrollView addSubview:_firstView];
    
    UIButton* btn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width * .5 - 50, self.view.height * .5 - 20, 100, 40)];
    [btn setTitle:@"加载xml" forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor redColor] forState:(UIControlStateNormal)];
    [btn addTarget:self action:@selector(chageViewToWebView) forControlEvents:(UIControlEventTouchUpInside)];
    [_firstView addSubview:btn];
    
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.view.height)];
    _webView.backgroundColor = [UIColor blueColor];
    
    _webView.delegate = self;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL* url = [NSURL fileURLWithPath:path];//创建URL
    NSURLRequest* request = [NSURLRequest requestWithURL:url];//创建NSURLRequest
    [_webView loadRequest:request];//加载
    
    [_scrollView addSubview:_webView];
}


- (void)loadXmlFile
{
    // 读取文件
    NSString* xmlFilePath = [[NSBundle mainBundle] pathForResource:@"q" ofType:@"xml"];
    
    NSData* data = [NSData dataWithContentsOfFile:xmlFilePath];
    
    // 先转义 避免传递到 js 时接收异常
    NSString *result = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByEscapingHTML];
    
    // 分割
    _file = [result componentsSeparatedByString:@"\n"];
}


- (void)callJsMethod:(NSString *)str
{
    NSString* tmp = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString* jsMethod = [NSString stringWithFormat:@"apendHtml('%@')", tmp];
//    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView stringByEvaluatingJavaScriptFromString:jsMethod];
//    });
}

#pragma mark - network methods



#pragma mark - public methods



#pragma mark - Event Response methods

- (void)chageViewToWebView
{
    [_scrollView setContentOffset:CGPointMake(self.view.width, 0) animated:YES];
    
//    [_scrollView scrollRectToVisible:CGRectMake(self.view.width, 0, self.view.width, 0) animated:YES];
}


#pragma mark - Delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_file enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self callJsMethod:obj];
    }];

}


#pragma mark - getter



#pragma mark - setter



@end
