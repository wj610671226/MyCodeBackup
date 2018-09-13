//
//  WkWebViewViewController.swift
//  JSH5Demo
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit
import WebKit

class WkWebViewViewController: UIViewController {

    private let methodName = "callNativeMethod"
    private lazy var wkWebView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()
        configuration.userContentController.add(self, name: methodName)
        
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.minimumFontSize = 50.0
        configuration.preferences = preferences
        let wkWebView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        view.addSubview(wkWebView)
        let urlstring = Bundle.main.url(forResource: "index-wkWebView", withExtension: "html")
        wkWebView.load(URLRequest(url: urlstring!))
        wkWebView.navigationDelegate = self;
        wkWebView.uiDelegate = self;
        return wkWebView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(wkWebView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wkWebView.configuration.userContentController.removeScriptMessageHandler(forName: methodName)
    }
    
    deinit {
        print("deinit")
    }
    
    private func handleJSMessage() {
        wkWebView.evaluateJavaScript("handleOCCallJSMothod('123')") { (x, error) in
            print("x = \(x ?? ""), error = \(error?.localizedDescription ?? "")")
        }
    }
}


extension WkWebViewViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let params = message.body
        if methodName == message.name {
            print("原生处理 params = \(params)")
            self.handleJSMessage()
        }
    }
}


extension WkWebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url!
        let scheme = url.scheme ?? ""
        let query = url.query ?? ""
        let host = url.host ?? ""
        print("url = \(url), scheme = \(scheme), query = \(query), host = \(host)")
        if scheme == "openvc" {
            // 根据Url传递的信息处理逻辑
            print("拦截js操作，处理原生逻辑")
            self.handleJSMessage()
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

extension WkWebViewViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "温馨提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert .addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        completionHandler()
    }
}
