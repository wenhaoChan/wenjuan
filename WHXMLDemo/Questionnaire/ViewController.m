//
//  ViewController.m
//  WHXMLDemo
//
//  Created by zero on 2019/3/8.
//  Copyright © 2019 zero. All rights reserved.
//

#import "ViewController.h"

#import <WebKit/WebKit.h>

#import <YYCategories/YYCategories.h>

@interface ViewController ()

@property (nonatomic, strong) UIScrollView *scrollerView;

@property (nonatomic, strong) UIView* firstView;

@property (nonatomic, strong) WKWebView* webView;

@end

@implementation ViewController


#pragma mark - life cycles methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    _scrollerView.contentSize = CGSizeMake(self.view.width * 2, self.view.height);
}

#pragma mark - private methods

- (void)setupSubviews
{
    _scrollerView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    _scrollerView.showsHorizontalScrollIndicator = NO;
    _scrollerView.showsVerticalScrollIndicator = NO;
    _scrollerView.bounces = NO;
    [self.view addSubview:_scrollerView];
    
    _firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    _firstView.backgroundColor = [UIColor redColor];
    [_scrollerView addSubview:_firstView];
    
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(self.view.width, 0, self.view.width, self.view.height)];
    _webView.backgroundColor = [UIColor blueColor];
    [_scrollerView addSubview:_webView];
    
    
}


#pragma mark - network methods



#pragma mark - public methods



#pragma mark - Event Response methods



#pragma mark - Custom Delegate



#pragma mark - getter



#pragma mark - setter



@end
