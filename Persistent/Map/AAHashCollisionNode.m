//
//  AAHashCollisionNode.m
//  Persistent
//
//  Created by Anton Astashov on 28/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAHashCollisionNode.h"
#import "AABitmapIndexedNode.h"
#import "AANullNode.h"
#import "AABool.h"
#import "AAOwner.h"
#import "Persistent-Prefix.pch"
#import "AAMapNodeIterator.h"

static const NSUInteger notFound = -1;

@implementation AAHashCollisionNode

-(instancetype)initWithHash:(NSUInteger)hash count:(NSUInteger)count array:(NSMutableArray *)array owner:(AAOwner *)owner {
    self = [self init];
    if (self) {
        _hash = hash;
        self.count = count;
        self.array = array;
        self.owner = owner;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[HC %@ (%p, %lu)]", [self.array componentsJoinedByString:@", "], self.owner, (unsigned long)self.count];
}

-(id)get:(id)key shift:(NSUInteger)shift {
    NSUInteger idx = [self findIndex:key];
    if (idx != notFound && [key isEqual:self.array[idx]]) {
        return self.array[idx + 1];
    } else {
        return nil;
    }
}

-(id<AAINode>)remove:(id)key shift:(NSUInteger)shift didRemoveLeaf:(AABool *)didRemoveLeaf owner:(AAOwner *)owner {
    NSUInteger idx = [self findIndex:key];
    if (idx == notFound) {
        return self;
    } else {
        didRemoveLeaf.value = YES;
        if (self.count == 1) {
            return nil;
        } else {
            AAHashCollisionNode *owned = [self ensureOwned:owner];
            [owned.array removeObjectAtIndex:idx];
            [owned.array removeObjectAtIndex:idx];
            owned.count -= 1;
            return owned;
        }
    }
}

-(id<AAINode>)set:(id)key withValue:(id)value shift:(NSUInteger)shift didAddLeaf:(AABool *)didAddLeaf owner:(AAOwner *)owner {
    if ([key hash] == _hash) {
        NSUInteger idx = [self findIndex:key];
        AAHashCollisionNode *node = [self ensureOwned:owner];
        if (idx != notFound) {
            if ([value isEqual:self.array[idx + 1]]) {
                return self;
            } else {
                node.array[idx + 1] = value;
                return node;
            }
        } else {
            [node.array addObject:key];
            [node.array addObject:value];
            node.count += 1;
            didAddLeaf.value = YES;
            return node;
        }
    } else {
        NSMutableArray *newArray = [NSMutableArray arrayWithObjects:[AANullNode node], self, [AANullNode node], [AANullNode node], nil];
        AABitmapIndexedNode *node = [[AABitmapIndexedNode alloc] initWithBitmap:bitpos(_hash, shift) array:newArray owner:owner];
        return [node set:key withValue:value shift:shift didAddLeaf:didAddLeaf owner:owner];
    }
}

-(NSUInteger)findIndex:(id)key {
    for (NSUInteger i = 0; i < 2 * self.count; i += 2) {
        if ([key isEqual:self.array[i]]) {
            return i;
        }
    }
    return notFound;
}

-(instancetype)ensureOwned:(AAOwner *)owner {
    if (self.owner && self.owner == owner) {
        return self;
    } else {
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray:self.array];
        return [[AAHashCollisionNode alloc] initWithHash:_hash count:self.count array:newArray owner:owner];
    }
}

-(void)each:(void(^)(id, id))block {
    for (NSUInteger i = 0; i < [self.array count]; i += 2) {
        block(self.array[i], self.array[i + 1]);
    }
}

-(BOOL)isEmpty {
    return [self.array count] == 0;
}

-(id<AAIIterator>)iterator {
    return [AAMapNodeIterator create:self.array];
}

@end
