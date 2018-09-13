//
//  UIWebViewViewController.swift
//  JSH5Demo
//
//  Created by mac on 2018/9/13.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit
import JavaScriptCore

class UIWebViewViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let webView = UIWebView(frame: UIScreen.main.bounds)
        webView.delegate = self
        let path = Bundle.main.path(forResource: "index-webView-swift", ofType: "html")
        let url = URL.init(fileURLWithPath: path!)
        webView.loadRequest(URLRequest(url: url))
        view.addSubview(webView)
    }

    
    deinit {
        print("deinit")
    }
    
}



extension UIWebViewViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // 获取上下文
        let jsContext = webView.value(forKeyPath: "documentView.webView.mainFrame.javaScriptContext") as? JSContext
        let tools = Tools()
        tools.context = jsContext
        jsContext?.setObject(tools, forKeyedSubscript: "swiftTools" as NSCopying & NSObjectProtocol)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let url = request.url!
        let scheme = url.scheme
        let absoluteString = url.absoluteString
        let query = url.query
        let host = url.host
        print("url = \(url), absoluteString = \(absoluteString), scheme = \(scheme), query = \(query), host = \(host)")
        if scheme! == "openvc" {
            // 根据Url传递的信息处理逻辑
            print("拦截js操作，处理原生逻辑")
            return false
        }
        return true
    }
}
