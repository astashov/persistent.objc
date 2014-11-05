//
//  AAMapNodeIterator.m
//  Persistent
//
//  Created by Anton Astashov on 04/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAMapNodeIterator.h"
#import "AAINode.h"
#import "AANullNode.h"

@implementation AAMapNodeIterator

@synthesize array = _array, index = _index, iterator = _iterator;

+(instancetype)create:(NSArray *)array {
    return [self createWithArray:array index:0 iterator:nil];
}

+(instancetype)createWithArray:(NSArray *)array index:(NSUInteger)index iterator:(id<AAIIterator>)iterator {
    if (iterator) {
        return [[AAMapNodeIterator alloc] initWithArray:array index:index iterator:iterator];
    } else {
        for (NSUInteger j = index; j < array.count; j += 2) {
            if (array[j] != [AANullNode node]) {
                return [[AAMapNodeIterator alloc] initWithArray:array index:j iterator:nil];
            } else {
                id<AAINode> node = array[j + 1];
                if (node != [AANullNode node]) {
                    id<AAIIterator> nodeIterator = [node iterator];
                    if (nodeIterator) {
                        return [[AAMapNodeIterator alloc] initWithArray:array index:j + 2 iterator:nodeIterator];
                    }
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
    if (self.iterator) {
        return [self.iterator first];
    } else {
        return @[self.array[self.index], self.array[self.index + 1]];
    }
}

-(id<AAIIterator>)next {
    if (self.iterator) {
        return [[self class] createWithArray:self.array index:self.index iterator:[self.iterator next]];
    } else {
        return [[self class] createWithArray:self.array index:self.index + 2 iterator:nil];
    }
}

@end
