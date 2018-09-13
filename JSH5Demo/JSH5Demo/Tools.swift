//
//  Model.swift
//  JSH5Demo
//
//  Created by mac on 2018/9/12.
//  Copyright © 2018年 mac. All rights reserved.
//

import UIKit
import JavaScriptCore

@objc protocol SwiftTools: JSExport {
    func jsCallMethod(_ param: String)
}

class Tools: NSObject, SwiftTools {
    
    var context: JSContext?
    
    func jsCallMethod(_ param: String) {
        // 如果还想要调用js的方法就需要拿到webView的JSContext
        print("js 调用 原生方法 param = \(param)")
        _ = context?.evaluateScript("handleOCCallJSMothod('swift传递的参数')")
    }
}



