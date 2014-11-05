//
//  AAMapArrayNodeIterator.m
//  Persistent
//
//  Created by Anton Astashov on 04/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAMapArrayNodeIterator.h"
#import "AANullNode.h"

@implementation AAMapArrayNodeIterator

@synthesize array = _array, index = _index, iterator = _iterator;

+(instancetype)create:(NSArray *)array {
    return [self createWithArray:array index:0 iterator:nil];
}

+(instancetype)createWithArray:(NSArray *)array index:(NSUInteger)index iterator:(id<AAIIterator>)iterator {
    if (iterator) {
        return [[AAMapArrayNodeIterator alloc] initWithArray:array index:index iterator:iterator];
    } else {
        for (NSUInteger j = index; j < array.count; j += 1) {
            if (array[j] != [AANullNode node]) {
                id<AAIIterator> nodeIterator = [array[j] iterator];
                if (nodeIterator) {
                    return [[AAMapArrayNodeIterator alloc] initWithArray:array index:j + 1 iterator:nodeIterator];
                }
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
    return [self.iterator first];
}

-(id<AAIIterator>)next {
    return [[self class] createWithArray:self.array index:self.index iterator:[self.iterator next]];
}

@end
