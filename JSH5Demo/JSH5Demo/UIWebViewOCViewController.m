//
//  UIWebViewOCViewController.m
//  JSH5Demo
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "UIWebViewOCViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "Tools.h"

@interface UIWebViewOCViewController ()<UIWebViewDelegate>
{
    UIWebView * _webView;
}
@end

@implementation UIWebViewOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.view addSubview:_webView];
    _webView.delegate = self;
    NSString * urlstring = [[NSBundle mainBundle] pathForResource:@"index-webView-oc" ofType:@"html"];
    [_webView loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlstring]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL * url = request.URL;
    NSString * scheme = url.scheme;
    NSString * query = url.query;
    NSString * host = url.host;
    NSLog(@"scheme = %@, query = %@, host = %@", scheme, query, host);
    if ([scheme isEqualToString:@"openvc"]) {
        // 根据Url传递的信息处理逻辑
        NSLog(@"拦截url, 处理原生逻辑");
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    JSContext * context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    //
    __weak typeof(self) weakSelf = self;
    context[@"openImagePickerVC"] = ^() {
        // 获取js传递过来的参数
        NSArray * params = [JSContext currentArguments];
        NSLog(@"js 传递的参数 params = %@", params);
        [weakSelf handleOtherOperating];
    };
    
    Tools * tools = [Tools new];
    tools.context = context;
    // 方法一
    context[@"tools"] = tools;
    // 方法二
    //    [context setObject:tools forKeyedSubscript:@"tools"];
}

- (void)handleOtherOperating {
    // 其他处理
    NSLog(@"原生处理方法 thread = %@", [NSThread currentThread]);
    // 回调js方法
    JSContext * context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    [context evaluateScript:@"handleOCCallJSMothod('oc传递的参数')"];
}

- (void)dealloc {
    NSLog(@"UIWebViewOCViewController dealloc");
}

@end
