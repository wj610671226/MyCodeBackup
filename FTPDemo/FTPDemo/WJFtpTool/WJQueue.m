//
//  WJQueue.m
//
//  Created by 30san on 2018/12/12.
//  Copyright © 2018 FY. All rights reserved.
//
#import "WJQueue.h"

@interface WJQueue ()
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation WJQueue

- (dispatch_semaphore_t)semaphore {
  if (_semaphore == nil) {
    _semaphore = dispatch_semaphore_create(1);
  }
  return _semaphore;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    _items = [[NSMutableArray alloc] init];
    _count = 0;
  }
  return self;
}

- (void)insert:(id)object
{
  BOOL result = [self.items containsObject:object];
  if (result) { return; }
  [self.items insertObject:object atIndex:0];
  self.count = [self.items count];
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
  dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
  id obj = nil;
  if ([self.items count]) {
    obj = self.items[0];
    [self.items removeObjectAtIndex:0];
  }
  self.count = [self.items count];
  dispatch_semaphore_signal(self.semaphore);
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
