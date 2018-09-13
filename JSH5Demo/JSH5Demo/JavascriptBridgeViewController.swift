//
//  JavascriptBridgeViewController.swift
//  JSH5Demo
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit

class JavascriptBridgeViewController: UIViewController {

    private var bridge: WebViewJavascriptBridge!
    
    private lazy var wkWebView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = WKUserContentController()

        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        preferences.minimumFontSize = 50.0
        configuration.preferences = preferences
        let wkWebView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        view.addSubview(wkWebView)
        let urlstring = Bundle.main.url(forResource: "index-JavascriptBridge", withExtension: "html")
        wkWebView.load(URLRequest(url: urlstring!))
        wkWebView.uiDelegate = self
        return wkWebView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testWkWebView()
    }

    private func testWebView() {
        let webView = UIWebView(frame: UIScreen.main.bounds)
        let path = Bundle.main.path(forResource: "index-JavascriptBridge", ofType: "html")
        let url = URL.init(fileURLWithPath: path!)
        webView.loadRequest(URLRequest(url: url))
        view.addSubview(webView)
        bridge = WebViewJavascriptBridge(webView)
        bridge.registerHandler("nativeMothod") { (data, callback) in
            print("js 传递过来的数据 = \(String(describing: data))")
            callback!("回调")
        }
    }
    
    private func testWkWebView() {
        view.addSubview(wkWebView)
        bridge = WebViewJavascriptBridge(forWebView: wkWebView)
        bridge.registerHandler("nativeMothod") { (data, callback) in
            print("js 传递过来的数据 = \(String(describing: data))")
            callback!("回调")
        }
    }
    
    
    @IBAction func nativeCallJsMethod(_ sender: Any) {
        bridge.callHandler("jsMethod", data: ["name" : 123]) { (response) in
            print("response = \(response ?? "")")
        }
    }
}

extension JavascriptBridgeViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "温馨提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert .addAction(UIAlertAction(title: "确定", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        completionHandler()
    }
}
