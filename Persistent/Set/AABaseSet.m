//
//  AABaseSet.m
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AABaseSet.h"
#import "AABaseHashMap.h"
#import "AASetIterator.h"

@implementation AABaseSet

-(instancetype)initWithHashMap:(AABaseHashMap *)hashMap {
    self = [self init];
    if (self) {
        self.
        self.hashMap = hashMap;
        _mutateFlag = 0;
    }
    return self;
}

-(NSUInteger)count {
    return self.hashMap.count;
}

-(instancetype)addObject:(id)anObject {
    return [[[self class] alloc] initWithHashMap:[self.hashMap setObject:anObject forKey:anObject]];
}

-(instancetype)removeObject:(id)anObject {
    return [[[self class] alloc] initWithHashMap:[self.hashMap removeObjectForKey:anObject]];
}

-(BOOL)containsObject:(id)anObject {
    return !![self.hashMap objectForKey:anObject];
}

-(void)each:(void(^)(id))block {
    [self.hashMap each:^(id key, id _) {
        block(key);
    }];
}

-(NSSet *)toSet {
    NSMutableSet *set = [[NSMutableSet alloc] init];
    [self each:^(id object) {
        [set addObject:object];
    }];
    return [NSSet setWithSet:set];
}

-(NSUInteger)hash {
    return self.hashMap.hash;
}

-(BOOL)isEqual:(id)object {
    return [super isEqual:object] ||
    ([self class] == [object class] && [self isEqualToSet:(AABaseSet *)object]);
}

-(BOOL)isEqualToSet:(AABaseSet *)set {
    return [self.hashMap isEqualToHashMap:set.hashMap];
}

-(id<AAIIterator>)iterator {
    id<AAIIterator> i = [self.hashMap iterator];
    if (i) {
        return [[AASetIterator alloc] initWithIterator:i];
    } else {
        return nil;
    }
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                 objects:(id __unsafe_unretained [])buffer
                                   count:(NSUInteger)len {
    if (state->state == 0) {
        state->state = 1;
        state->mutationsPtr = (unsigned long *)&_mutateFlag;
        state->extra[0] = (unsigned long)(__bridge_retained void *)[self iterator];
    }
    id<AAIIterator> iterator = (__bridge_transfer id<AAIIterator>)(void *)state->extra[0];
    NSUInteger i;
    for (i = 0; i < len && iterator != nil; i += 1) {
        id __unsafe_unretained value = [iterator first];
        buffer[i] = value;
        iterator = [iterator next];
    }
    if (i > 0) {
        state->extra[0] = (unsigned long)(__bridge_retained void *)iterator;
    }
    state->itemsPtr = buffer;
    return i;
}

@end
