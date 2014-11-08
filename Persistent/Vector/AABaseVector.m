//
//  AABaseVector.m
//  Persistent
//
//  Created by Anton Astashov on 01/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AABaseVectorPrivate.h"
#import "AATransientVector.h"
#import "AATransientVectorPrivate.h"
#import "AAPersistentVector.h"
#import "AAPersistentVectorPrivate.h"
#import "AAVNode.h"
#import "AAPersistentUtils.h"
#import "AABool.h"
#import "AAOwner.h"
#import "AAVectorIterator.h"
#import "AAPersistentFunctions.h"

@implementation AABaseVector

-(instancetype)init {
    self = [super init];
    if (self) {
        self.altered = NO;
        self.root = [[AAVNode alloc] initWithArray:[NSMutableArray array] andOwner:self.owner];
        self.tail = self.root;
        self.level = SHIFT;
        self.count = 0;
        _hash = 0;
    }
    return self;
}

#pragma mark API

-(id)objectAtIndex:(NSUInteger)index {
    if (index > self.count - 1) {
        return nil;
    } else {
        AAVNode *node = [self vectorNodeFor:index];
        NSUInteger maskedIndex = index & MASK;
        return [node get:maskedIndex];
    }
}

-(instancetype)replaceObjectAtIndex:(NSUInteger)index withObject:(id)value {
    if (index < self.count) {
        AAVNode *newTail = self.tail;
        AAVNode *newRoot = self.root;
        AABool *didAlter = [[AABool alloc] init];
        if (index >= [self tailOffset]) {
            newTail = [newTail update:index withValue:value level:0 owner:self.owner didAlter:didAlter];
        } else {
            newRoot = [newRoot update:index withValue:value level:self.level owner:self.owner didAlter:didAlter];
        }
        if (!didAlter.value) {
            return self;
        } else if (self.owner) {
            self.root = newRoot;
            self.tail = newTail;
            self.altered = YES;
            return self;
        } else {
            return [[AAPersistentVector alloc] initWithSize:self.count level:self.level root:newRoot tail:newTail];
        }
    } else {
        NSString *format = self.count == 0 ? @"empty vector" : [NSString stringWithFormat:@"[0 .. %lu]", (unsigned long)self.count - 1];
        [NSException raise:NSRangeException format:@"index %lu beyond bounds for %@", (unsigned long)index, format];
    }
    return nil;
}

-(instancetype)addObject:(id)value {
    NSUInteger length = self.count;
    return [self withTransient:^(AATransientVector *transient) {
        return (AATransientVector *)[[transient increaseSize] replaceObjectAtIndex:length withObject:value];
    }];
}

-(void)each:(void(^)(id))block {
    for (id value in self) {
        block(value);
    }
}

-(instancetype)removeLastObject {
    if (self.count > 0) {
        return [self decreaseSize];
    } else {
        return self;
    }
}

-(AATransientVector *)asTransient {
    return (AATransientVector *)(self.owner ? self : [self ensureOwner:[[AAOwner alloc] init]]);
}

-(AABaseVector *)withTransient:(AATransientVector *(^)(AATransientVector *))block {
    AATransientVector *transient = (AATransientVector *)[self asTransient];
    transient = (AATransientVector *)block(transient);
    return (AAPersistentVector *)(transient.altered ? [transient ensureOwner:self.owner] : self);
}

-(NSArray *)toArray {
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i < self.count; i += 1) {
        [a addObject:[self objectAtIndex:i]];
    }
    return [NSArray arrayWithArray:a];
}

-(NSString *)description {
    return [[self toArray] description];
}

-(NSString *)internals {
    NSMutableDictionary *a = [[NSMutableDictionary alloc] init];
    a[@"owner"] = self.owner ?: [NSNull null];
    a[@"root"] = self.root;
    a[@"tail"] = self.tail;
    a[@"level"] = @(self.level);
    return [a description];
}

-(AABaseVector *)ensureOwner:(AAOwner *)owner {
    if (owner == self.owner) {
        return self;
    } else if (!owner) {
        self.owner = owner;
        return [[AAPersistentVector alloc] initWithSize:self.count level:self.level root:self.root tail:self.tail];
    } else {
        return [[AATransientVector alloc] initWithSize:self.count level:self.level root:self.root tail:self.tail owner:owner];
    }
}

-(id)objectAt:(NSArray *)path {
    return objectAt(self, path);
}

-(instancetype)insertAt:(NSArray *)path withValue:(id)value {
    return (AABaseVector *)insertAt(self, path, value);
}

-(instancetype)removeAt:(NSArray *)path {
    return (AABaseVector *)removeAt(self, path);
}

# pragma mark Private Methods

-(AABaseVector *)increaseSize {
    return [self resize:YES];
}

-(AABaseVector *)decreaseSize {
    return [self resize:NO];
}

-(AABaseVector *)resize:(BOOL)isIncrease {
    NSUInteger newSize = isIncrease ? self.count + 1 : self.count - 1;
    AAOwner *owner = self.owner == nil ? nil : [[AAOwner alloc] init];
    NSUInteger oldTailOffset = [self tailOffset];
    NSUInteger newTailOffset = [self tailOffsetWithSize:newSize];
    BOOL isNewTail = oldTailOffset != newTailOffset;

    AAVNode *newRoot = self.root;
    NSUInteger newLevel = self.level;
    AAVNode *newTail = self.tail;

    if (isIncrease) {
        if (isNewTail) {
            newTail = [[AAVNode alloc] initWithArray:[NSMutableArray array] andOwner:owner];

            // Create wrapping root if we are out of space in the current root
            if (newTailOffset >= (1 << (newLevel + SHIFT))) {
                NSMutableArray *newArray = [NSMutableArray arrayWithArray:@[self.root]];
                newRoot = [[AAVNode alloc] initWithArray:newArray andOwner:owner];
                newLevel += SHIFT;
            }
            newRoot = maybeCopyVNode(newRoot, owner);

            // Move tail to the appropriate trie leaf, recreating all the nodes down the path
            AAVNode *node = newRoot;
            for (NSUInteger level = newLevel; level > SHIFT; level -= SHIFT) {
                NSUInteger idx = (oldTailOffset >> level) & MASK;
                [node set:maybeCopyVNode([node get:idx], owner) toIndex:idx];
                node = [node get:idx];
            }
            [node set:self.tail toIndex:((oldTailOffset >> SHIFT) & MASK)];
        }
    } else {
        if (isNewTail) {
            newTail = [self vectorNodeFor:newSize - 1];
            newRoot = maybeCopyVNode(newRoot, owner);

            AAVNode *node = newRoot;
            AAVNode *parent;
            NSUInteger idx = 0;

            // Recreating all nodes down the path to the target trie leaf
            for (NSUInteger level = newLevel; level > SHIFT; level -= SHIFT) {
                parent = node;
                idx = (newTailOffset >> level) & MASK;
                [node set:maybeCopyVNode([node get:idx], owner) toIndex:idx];
                node = [node get:idx];
            }
            AAVNode *newNode = [node removeAfter:[node count] - 1 withOwner:owner];
            if (parent) {
                [parent set:newNode toIndex:idx];
            } else {
                newRoot = newNode;
            }
        }
        newTail = [newTail removeAfter:newSize withOwner:owner];
    }

    if (owner) {
        self.count = newSize;
        self.level = newLevel;
        self.root = newRoot;
        self.tail = newTail;
        self.altered = YES;
        return self;
    } else {
        return [[AAPersistentVector alloc] initWithSize:newSize level:newLevel root:newRoot tail:newTail];
    }

}

-(AAVNode *)vectorNodeFor:(NSUInteger)index {
    if (index >= [self tailOffset]) {
        return self.tail;
    } else if (index < (1 << (self.level + SHIFT))) {
        AAVNode *node = self.root;
        NSUInteger level = self.level;
        while (node != nil && level > 0) {
            node = [node get:((index >> level) & MASK)];
            level -= SHIFT;
        }
        return node;
    } else {
        // TODO: Not sure when this could happen...
        return nil;
    }
}

-(NSUInteger)tailOffset {
    return [self tailOffsetWithSize:self.count];
}

-(NSUInteger)tailOffsetWithSize:(NSUInteger)size {
    return size < SIZE ? 0 : (((size - 1) >> SHIFT) << SHIFT);
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                 objects:(id __unsafe_unretained [])buffer
                                   count:(NSUInteger)len {
    if (state->state == 0) {
        state->state = 1;
        state->mutationsPtr = (unsigned long *)&_count;
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

-(NSUInteger)hash {
    if (!_hash) {
        _hash = hashObjects(self);
    }
    return _hash;
}

-(BOOL)isEqual:(id)object {
    return [super isEqual:object] ||
        ([self class] == [object class] && [self isEqualToVector:(AABaseVector *)object]);
}

-(BOOL)isEqualToVector:(AABaseVector *)vector {
    if ([super isEqual:vector]) {
        return true;
    }
    if ([self class] != [vector class]) {
        return false;
    }
    if (self.hash != ((AABaseVector *)vector).hash) {
        return false;
    }
    if (self.count != ((AABaseVector *)vector).count) {
        return false;
    }
    for (NSUInteger i = 0; i < self.count; i += 1) {
        if ([self objectAtIndex:i] != [vector objectAtIndex:i]) {
            return false;
        }
    }
    return true;
}

-(id<AAIIterator>)iterator {
    return [AAVectorIterator create:@[self.root, self.tail]];
}

@end
