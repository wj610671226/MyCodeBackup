//
//  WJQueue.m
//
//  Created by 30san on 2018/12/12.
//  Copyright © 2018 FY. All rights reserved.
//
#import "WJQueue.h"

@interface WJQueue ()

@end

@implementation WJQueue

- (instancetype)init
{
    self = [super init];
    if (self) {
        _items = [[NSMutableArray alloc] init];
        _count = 0;
    }
    return self;
}

- (void)enqueue:(id)object
{
    BOOL result = [self.items containsObject:object];
    if (result) { return; }
    [self.items addObject:object];
    self.count = [self.items count];
}

- (id)dequeue
{
    id obj = nil;
    if ([self.items count]) {
        obj = self.items[0];
        [self.items removeObjectAtIndex:0];
    }
    self.count = [self.items count];
    return obj;
}

- (BOOL)removeObject:(id)object
{
    if ([self.items containsObject:object]) {
        [self.items removeObject:object];
        self.count = self.count - 1;
        return YES;
    }
    return NO;
}

- (NSArray *)allItems
{
    return self.items;
}

- (void)clear
{
    [self.items removeAllObjects];
    self.count = 0;
}

@end
