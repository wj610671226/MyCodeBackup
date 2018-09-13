//
//  Tools.m
//  JSH5Demo
//
//  Created by mac on 2018/9/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "Tools.h"

@implementation Tools

- (void)jsCallMethod {
    NSLog(@"js 调用 原生方法");
    // 如果还想要调用js的方法就需要拿到webView的JSContext
    [self.context evaluateScript:@"handleOCCallJSMothod('oc tools 传递的参数')"];
}
@end
