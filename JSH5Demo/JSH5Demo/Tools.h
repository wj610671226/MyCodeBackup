//
//  Tools.h
//  JSH5Demo
//
//  Created by mac on 2018/9/12.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSCallOCProtocol<JSExport>

- (void)jsCallMethod;

@end


@interface Tools : NSObject<JSCallOCProtocol>
@property (nonatomic, strong) JSContext * context;
@end

