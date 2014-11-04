//
//  AABaseSet.m
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AABaseSet.h"
#import "AABaseHashMap.h"

@implementation AABaseSet

-(instancetype)initWithHashMap:(AABaseHashMap *)hashMap {
    self = [self init];
    if (self) {
        self.hashMap = hashMap;
    }
    return self;
}

-(NSUInteger)count {
    return self.hashMap.count;
}

-(instancetype)addObject:(id)anObject {
    return [[[self class] alloc] initWithHashMap:[self.hashMap set:anObject withValue:anObject]];
}

-(instancetype)removeObject:(id)anObject {
    return [[[self class] alloc] initWithHashMap:[self.hashMap remove:anObject]];
}

-(BOOL)containsObject:(id)anObject {
    return !![self.hashMap get:anObject];
}

-(void)each:(void(^)(id))block {
    [self.hashMap each:^(id key, id _) {
        block(key);
    }];
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

@end
