//
//  WKWebViewViewController.m
//  JSH5Demo
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "WKWebViewOCViewController.h"
#import <WebKit/WebKit.h>

@interface WKWebViewOCViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>
{
    WKWebView * _wkWebView;
}
@end

@implementation WKWebViewOCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    [configuration.userContentController addScriptMessageHandler:self name:@"callNativeMethod"];
    
    WKPreferences * preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    preferences.minimumFontSize = 50.0;
    configuration.preferences = preferences;
    
    _wkWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds configuration:configuration];
    [self.view addSubview:_wkWebView];
    NSURL * urlstring = [[NSBundle mainBundle] URLForResource:@"index-wkWebView" withExtension:@"html"];
    [_wkWebView loadRequest:[[NSURLRequest alloc] initWithURL:urlstring]];
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message = %@", message.name);
    NSLog(@"params = %@", message.body);
    if ([message.name isEqualToString:@"callNativeMethod"]) {
        // 其他处理
        NSLog(@"callNativeMethod");
    }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    NSURL * url = navigationAction.request.URL;
    NSString * scheme = url.scheme;
    NSString * query = url.query;
    NSString * host = url.host;
    NSLog(@"scheme = %@, query = %@, host = %@", scheme, query, host);
    if ([scheme isEqualToString:@"openvc"]) {
        [self handleJSMessage];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)handleJSMessage {
    [_wkWebView evaluateJavaScript:@"handleOCCallJSMothod('123')" completionHandler:^(id _Nullable x, NSError * _Nullable error) {
        NSLog(@"x = %@, error = %@", x, error.localizedDescription);
    }];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"message = %@",  message);
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    completionHandler();
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_wkWebView.configuration.userContentController removeScriptMessageHandlerForName:@"callNativeMethod"];
}

- (void)dealloc {
    NSLog(@"dealloc");
}
@end
