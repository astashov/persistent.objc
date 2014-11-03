//
//  AAArrayNode.m
//  Persistent
//
//  Created by Anton Astashov on 27/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAArrayNode.h"
#import "AABitmapIndexedNode.h"
#import "AAINode.h"
#import "AABool.h"
#import "Persistent-Prefix.pch"

@interface AAArrayNode ()
@property AAOwner *owner;
@property NSMutableArray *array;
@property NSUInteger count;
@end

@implementation AAArrayNode

-(instancetype)initWithCount:(NSUInteger)count array:(NSMutableArray *)array owner:(AAOwner *)owner {
    self = [self init];
    if (self) {
        self.count = count;
        self.array = array;
        self.owner = owner;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[A %@ (%p, %lu)]", [self.array componentsJoinedByString:@", "], self.owner, (unsigned long)self.count];
}

-(id)get:(id)key shift:(NSUInteger)shift {
    NSUInteger hash = [key hash];
    NSUInteger idx = mask(hash, shift);
    id<AAINode> node = self.array[idx];
    if (node) {
        if ([node isEqual:[NSNull null]]) {
            return nil;
        } else {
            return [node get:key shift:shift + SHIFT];
        }
    } else {
        return nil;
    }
}

-(id<AAINode>)set:(id)key withValue:(id)value shift:(NSUInteger)shift didAddLeaf:(AABool *)didAddLeaf owner:(AAOwner *)owner {
    NSUInteger hash = [key hash];
    NSUInteger idx = mask(hash, shift);
    id<AAINode> node = self.array[idx];
    if ([node isEqual:[NSNull null]]) {
        id<AAINode> newNode = [[AABitmapIndexedNode empty] set:key withValue:value shift:shift + SHIFT didAddLeaf:didAddLeaf owner:owner];
        AAArrayNode *owned = [self ensureOwned:owner];
        owned.array[idx] = newNode;
        owned.count = owned.count + 1;
        return owned;
    } else {
        id<AAINode> n = [node set:key withValue:value shift:shift + SHIFT didAddLeaf:didAddLeaf owner:owner];
        if ([n isEqual:node]) {
            return self;
        } else {
            AAArrayNode *owned = [self ensureOwned:owner];
            owned.array[idx] = n;
            return owned;
        }
    }
}

-(id<AAINode>)remove:(id)key shift:(NSUInteger)shift didRemoveLeaf:(AABool *)didRemoveLeaf owner:(AAOwner *)owner {
    NSUInteger hash = [key hash];
    NSUInteger idx = mask(hash, shift);
    id<AAINode> node = self.array[idx];
    if ([node isEqual:[NSNull null]]) {
        return self;
    } else {
        id<AAINode> n = [node remove:key shift:shift + SHIFT didRemoveLeaf:didRemoveLeaf owner:owner];
        if ([n isEqual:node]) {
            return self;
        } else if ([n isEqual:[NSNull null]]) {
            if (self.count <= SIZE / 4) {
                return [self pack:idx owner:owner];
            } else {
                AAArrayNode *owned = [self ensureOwned:owner];
                owned.array[idx] = n;
                owned.count -= 1;
                return owned;
            }
        } else {
            AAArrayNode *owned = [self ensureOwned:owner];
            if ([n isEmpty]) {
                owned.array[idx] = [NSNull null];
                owned.count -= 1;
            } else {
                owned.array[idx] = n;
            }
            if (owned.count <= SIZE / 4) {
                return [owned toBitmapNode:owner];
            } else {
                return owned;
            }
        }
    }
}

-(instancetype)ensureOwned:(AAOwner *)owner {
    if (self.owner && self.owner == owner) {
        return self;
    } else {
        return [[AAArrayNode alloc]
            initWithCount:self.count array:[[NSMutableArray alloc] initWithArray:self.array] owner:owner];
    }
}

-(AABitmapIndexedNode *)pack:(NSUInteger)idx owner:(AAOwner *)owner {
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:2 * (self.count - 1)];
    NSUInteger j = 1;
    NSUInteger bitmap = 0;
    for (NSUInteger i = 0; i < [self.array count]; i += 1) {
        if (![self.array[i] isEqual:[NSNull null]]) {
            newArray[j] = self.array[i];
            bitmap |= (1 << i);
            j += 2;
        }
        if (i == idx - 1) {
            i += 1;
        }
    }
    return [[AABitmapIndexedNode alloc] initWithBitmap:bitmap array:newArray owner:owner];
}

-(AABitmapIndexedNode *)toBitmapNode:(AAOwner *)owner {
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:2 * self.count];
    NSUInteger bitmap = 0;
    for (NSUInteger i = 0; i < [self.array count]; i += 1) {
        if (![self.array[i] isEqual:[NSNull null]]) {
            [newArray addObject:[NSNull null]];
            [newArray addObject:self.array[i]];
            bitmap |= (1 << i);
        }
    }
    return [[AABitmapIndexedNode alloc] initWithBitmap:bitmap array:newArray owner:owner];
}

-(void)each:(void(^)(id, id))block {
    for (NSUInteger i = 0; i < [self.array count]; i += 1) {
        id value = self.array[i];
        if (![value isEqual:[NSNull null]]) {
            [(id<AAINode>)value each:block];
        }
    }
}

-(BOOL)isEmpty {
    return [self.array count] == 0;
}

@end
