//
//  WJTools.h
//  moffice
//
//  Created by 30san on 2018/12/17.
//  Copyright © 2018 Facebook. All rights reserved.
//



#ifdef DEBUG

#define WJLog(...) NSLog(__VA_ARGS__)

#else

#define WJLog(...)

#endif

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height
