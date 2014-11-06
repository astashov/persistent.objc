//
//  AAVectorIterator.m
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAVectorIterator.h"
#import "AAVNode.h"

@implementation AAVectorIterator

@synthesize array = _array, index = _index, iterator = _iterator;

+(instancetype)create:(NSArray *)array {
    return [self createWithArray:array index:0 iterator:nil];
}

+(instancetype)createWithArray:(NSArray *)array index:(NSUInteger)index iterator:(id<AAIIterator>)iterator {
    if (iterator) {
        return [[AAVectorIterator alloc] initWithArray:array index:index iterator:iterator];
    } else {
        for (NSUInteger j = index; j < array.count; j += 1) {
            if ([array[j] isKindOfClass:[AAVNode class]]) {
                AAVNode *node = array[j];
                if (node) {
                    id<AAIIterator> nodeIterator = [node iterator];
                    if (nodeIterator) {
                        return [[AAVectorIterator alloc] initWithArray:array index:j + 1 iterator:nodeIterator];
                    }
                }
            } else {
                return [[AAVectorIterator alloc] initWithArray:array index:j iterator:nil];
            }
        }
        return nil;
    }
}

-(instancetype)initWithArray:(NSArray *)array index:(NSUInteger)index iterator:(id<AAIIterator>)iterator {
    self = [self init];
    if (self) {
        self.array = array;
        self.index = index;
        self.iterator = iterator;
    }
    return self;
}

-(id)first {
    if (self.iterator) {
        return [self.iterator first];
    } else {
        return self.array[self.index];
    }
}

-(id<AAIIterator>)next {
    if (self.iterator) {
        return [[self class] createWithArray:self.array index:self.index iterator:[self.iterator next]];
    } else {
        return [[self class] createWithArray:self.array index:self.index + 1 iterator:nil];
    }
}

@end
