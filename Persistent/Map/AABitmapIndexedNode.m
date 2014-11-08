//
//  AABitmapIndexedNode.m
//  Persistent
//
//  Created by Anton Astashov on 24/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AABitmapIndexedNode.h"
#import "AAArrayNode.h"
#import "AAINode.h"
#import "AABool.h"
#import "AANullNode.h"
#import "AAPersistentUtils.h"
#import "AAMapNodeIterator.h"

@interface AABitmapIndexedNode ()
@property AAOwner *owner;
@property NSMutableArray *array;
@property NSUInteger bitmap;
@end

@implementation AABitmapIndexedNode

+(instancetype)empty {
    static AABitmapIndexedNode *emptyBitmapIndexedNode = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:SIZE];
        emptyBitmapIndexedNode = [[self alloc] initWithBitmap:0 array:arr owner:nil];
    });
    return emptyBitmapIndexedNode;
}

-(instancetype)initWithBitmap:(NSUInteger)bitmap array:(NSMutableArray *)array owner:(AAOwner *)owner {
    self = [self init];
    if (self) {
        self.bitmap = bitmap;
        self.array = array;
        self.owner = owner;
    }
    return self;
}

-(NSUInteger)index:(NSUInteger)bit {
    return __builtin_popcount((int)self.bitmap & (bit - 1));
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[BI %@ (%p, %@)]", [self.array componentsJoinedByString:@", "], self.owner, ib((int)self.bitmap)];
}

-(id)get:(id)key shift:(NSUInteger)shift {
    NSUInteger hash = [key hash];
    NSUInteger bit = bitpos(hash, shift);
    if ((self.bitmap & bit) != 0) {
        NSUInteger idx = [self index:bit];
        id keyOrNull = self.array[2 * idx];
        id valOrNode = self.array[2 * idx + 1];
        if ([keyOrNull isEqual:[AANullNode node]]) {
            return [(id<AAINode>)valOrNode get:key shift:shift + SHIFT];
        } else if ([key isEqual:keyOrNull]) {
            return valOrNode;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

-(id<AAINode>)set:(id)key withValue:(id)value shift:(NSUInteger)shift didAddLeaf:(AABool *)didAddLeaf owner:(AAOwner *)owner {
    NSUInteger hash = [key hash];
    NSUInteger bit = bitpos(hash, shift);
    NSUInteger idx = [self index:bit];
    if ((self.bitmap & bit) != 0) {
        id keyOrNull = self.array[2 * idx];
        id valOrNode = self.array[2 * idx + 1];
        if ([keyOrNull isEqual:[AANullNode node]]) {
            id<AAINode> n = [(id<AAINode>)valOrNode set:key withValue:value shift:shift + SHIFT didAddLeaf:didAddLeaf owner:owner];
            if ([n isEqual:valOrNode]) {
                return self;
            } else {
                AABitmapIndexedNode *owned = [self ensureOwned:owner];
                owned.array[2 * idx + 1] = n;
                return owned;
            }
        } else if ([key isEqual:keyOrNull]) {
            if (value == valOrNode) {
                return self;
            } else {
                AABitmapIndexedNode *owned = [self ensureOwned:owner];
                owned.array[2 * idx + 1] = value;
                return owned;
            }
        } else {
            didAddLeaf.value = YES;
            AABitmapIndexedNode *owned = [self ensureOwned:owner];
            owned.array[2 * idx] = [AANullNode node];
            owned.array[2 * idx + 1] = createNode(shift + SHIFT, keyOrNull, valOrNode, key, value, owner);
            return owned;

        }
    } else {
        NSUInteger n = __builtin_popcount((int)self.bitmap);
        if (n >= SIZE / 2) {
            NSMutableArray *nodes = [[NSMutableArray alloc] initWithCapacity:SIZE];
            NSUInteger jdx = mask(hash, shift);
            int j = 0;
            for (NSUInteger i = 0; i < SIZE; i += 1) {
                if (i == jdx) {
                    nodes[jdx] = [[AABitmapIndexedNode empty] set:key withValue:value shift:shift + SHIFT didAddLeaf:didAddLeaf owner:owner];
                } else {
                    nodes[i] = [AANullNode node];
                }
                if (((self.bitmap >> i) & 1) != 0) {
                    if ([self.array[j] isEqual:[AANullNode node]]) {
                        nodes[i] = self.array[j + 1];
                    } else {
                        nodes[i] = [[AABitmapIndexedNode empty]
                            set:self.array[j]
                            withValue:self.array[j + 1]
                            shift:shift + SHIFT
                            didAddLeaf:didAddLeaf
                            owner:owner
                        ];
                    }
                    j += 2;
                }
            }
            return [[AAArrayNode alloc] initWithCount:n + 1 array:nodes owner:owner];
        } else {
            didAddLeaf.value = YES;
            AABitmapIndexedNode *owned = [self ensureOwned:owner];
            [owned.array insertObject:value atIndex:2 * idx];
            [owned.array insertObject:key atIndex:2 * idx];
            owned.bitmap |= bit;
            return owned;
        }
    }
    
    return self;
}

-(id<AAINode>)remove:(id)key shift:(NSUInteger)shift didRemoveLeaf:(AABool *)didRemoveLeaf owner:(AAOwner *)owner {
    NSUInteger hash = [key hash];
    NSUInteger bit = bitpos(hash, shift);
    if ((self.bitmap & bit) == 0) {
        return self;
    } else {
        NSUInteger idx = [self index:bit];
        id keyOrNull = self.array[2 * idx];
        id valOrNode = self.array[2 * idx + 1];
        if ([keyOrNull isEqual:[AANullNode node]]) {
            id<AAINode> n = [(id<AAINode>)valOrNode remove:key shift:shift + SHIFT didRemoveLeaf:didRemoveLeaf owner:owner];
            if ([n isEqual:valOrNode]) {
                return self;
            } else if (![n isEqual:[AANullNode node]]) {
                AABitmapIndexedNode *owned = [self ensureOwned:owner];
                if ([n isEmpty]) {
                    owned.bitmap ^= bit;
                    [owned.array removeObjectAtIndex:idx * 2];
                    [owned.array removeObjectAtIndex:idx * 2];
                } else {
                    owned.array[2 * idx + 1] = n;
                }
                return owned;
            } else if (self.bitmap == bit) {
                return nil;
            } else {
                AABitmapIndexedNode *owned = [self ensureOwned:owner];
                owned.bitmap ^= bit;
                [owned.array removeObjectAtIndex:idx * 2];
                [owned.array removeObjectAtIndex:idx * 2];
                return owned;
            }
        } else if ([key isEqual:keyOrNull]) {
            didRemoveLeaf.value = YES;
            AABitmapIndexedNode *owned = [self ensureOwned:owner];
            owned.bitmap ^= bit;
            [owned.array removeObjectAtIndex:idx * 2];
            [owned.array removeObjectAtIndex:idx * 2];
            return owned;
        } else {
            return self;
        }
    }
}

-(BOOL)isEmpty {
    return [self.array count] == 0;
}

-(void)each:(void(^)(id, id))block {
    for (NSUInteger i = 0; i < [self.array count]; i += 2) {
        id keyOrNull = self.array[i];
        id valOrNode = self.array[i + 1];
        if ([keyOrNull isEqual:[AANullNode node]]) {
            if (![valOrNode isEqual:[AANullNode node]]) {
                [valOrNode each:block];
            }
        } else {
            block(keyOrNull, valOrNode);
        }
    }
}

-(instancetype)ensureOwned:(AAOwner *)owner {
    if (self.owner && self.owner == owner) {
        return self;
    } else {
        NSUInteger n = __builtin_popcount((unsigned int)self.bitmap);
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithCapacity:2 * (n + 1)];
        [newArray addObjectsFromArray:self.array];
        return [[AABitmapIndexedNode alloc] initWithBitmap:self.bitmap array:newArray owner:owner];
    }
}

-(id<AAIIterator>)iterator {
    return [AAMapNodeIterator create:self.array];
}

@end
