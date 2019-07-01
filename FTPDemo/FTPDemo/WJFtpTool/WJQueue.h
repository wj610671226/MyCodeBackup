//
//  WJQueue.h
//
//  Created by 30san on 2018/12/12.
//  Copyright © 2018 FY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WJQueue : NSObject

- (void)enqueue:(id)object;
- (void)insert:(id)object;
- (id)dequeue;
- (BOOL)removeObject:(id)object;
- (NSArray *)allItems;
- (NSUInteger)count;
- (void)clear;

@property (nonatomic, assign) NSUInteger count;
@property (nonatomic, strong) NSMutableArray *items;

@end
