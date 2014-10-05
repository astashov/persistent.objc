//
//  AABaseVector.m
//  Persistent
//
//  Created by Anton Astashov on 01/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AABaseVector.h"
#import "AATransientVector.h"
#import "AAPersistentVector.h"
#import "AAVNode.h"
#import "Persistent-Prefix.pch"
#import "AABool.h"
#import "AAOwner.h"

@implementation AABaseVector

-(instancetype)init {
    self = [super init];
    if (self) {
        self.altered = NO;
        self.root = [[AAVNode alloc] initWithArray:[NSMutableArray array] andOwner:self.owner];
        self.tail = self.root;
        self.level = SHIFT;
        self.size = 0;
        self.hash = 0;
    }
    return self;
}

-(id)get:(NSUInteger)index {
    AAVNode *node = [self vectorNodeFor:index];
    NSUInteger maskedIndex = index & MASK;
    return [node get:maskedIndex];
}

-(instancetype)set:(NSUInteger)index withValue:(id)value {
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
        return [[AAPersistentVector alloc] initWithSize:self.size level:self.level root:newRoot tail:newTail];
    }
}

-(instancetype)push:(id)value {
    NSUInteger length = self.size;
    return [self withTransient:^(AATransientVector *transient) {
        [transient resize:length + 1];
        [transient set:length withValue:value];
    }];
}

-(instancetype)pop {
    if (self.size > 0) {
        return [self resize:self.size - 1];
    } else {
        return self;
    }
}

-(NSString *)description {
    return [[self all] description];
}

-(AABaseVector *)asTransient {
    return self.owner ? self : [self ensureOwner:[[AAOwner alloc] init]];
}

-(AABaseVector *)asPersistent {
    return [self ensureOwner:nil];
}

-(AABaseVector *)withTransient:(void (^)(AATransientVector *))block {
    AATransientVector *transient = (AATransientVector *)[self asTransient];
    block(transient);
    return transient.altered ? [transient ensureOwner:self.owner] : self;
}

-(AABaseVector *)ensureOwner:(AAOwner *)owner {
    if (owner == self.owner) {
        return self;
    } else if (!owner) {
        self.owner = owner;
        return [[AAPersistentVector alloc] initWithSize:self.size level:self.level root:self.root tail:self.tail];
    } else {
        return [[AATransientVector alloc] initWithSize:self.size level:self.level root:self.root tail:self.tail owner:owner];
    }
}

-(AABaseVector *)resize:(NSUInteger)newSize {
    NSUInteger oldSize = self.size;
    if (oldSize == newSize) {
        return self;
    } else {
        AAOwner *owner = self.owner == nil ? nil : [[AAOwner alloc] init];
        NSUInteger newLevel = self.level;
        AAVNode *newRoot = self.root;
        NSUInteger oldTailOffset = [self tailOffset];
        NSUInteger newTailOffset = [self tailOffsetWithSize:newSize];
        while (newTailOffset >= (1 << (newLevel + SHIFT))) {
            NSMutableArray *newArray;
            if (newRoot && [newRoot count] > 0) {
                newArray = [NSMutableArray arrayWithArray:@[newRoot]];
            } else {
                newArray = [NSMutableArray array];
            }
            newRoot = [[AAVNode alloc] initWithArray:newArray andOwner:owner];
            newLevel += SHIFT;
        }
        AAVNode *oldTail = self.tail;
        AAVNode *newTail;
        if (newTailOffset < oldTailOffset) {
            newTail = [self vectorNodeFor:newSize - 1];
        } else if (newTailOffset > oldTailOffset) {
            newTail = [[AAVNode alloc] initWithArray:[NSMutableArray array] andOwner:owner];
        } else {
            newTail = oldTail;
        }

        if (newTailOffset > oldTailOffset && oldSize > 0 && [oldTail count] > 0) {
            newRoot = transientVNode(newRoot, owner);
            AAVNode *node = newRoot;
            for (NSUInteger level = newLevel; level > SHIFT; level -= SHIFT) {
                NSUInteger idx = (oldTailOffset >> level) & MASK;
                [node set:transientVNode([node get:idx], owner) toIndex:idx];
                node = [node get:idx];
            }
            [node set:oldTail toIndex:((oldTailOffset >> SHIFT) & MASK)];
        }

        if (newTailOffset < oldTailOffset) {
            newRoot = transientVNode(newRoot, owner);
            AAVNode *node = newRoot;
            AAVNode *parent;
            NSUInteger idx = 0;
            for (NSUInteger level = newLevel; level > SHIFT; level -= SHIFT) {
                parent = node;
                idx = (newTailOffset >> level) & MASK;
                [node set:transientVNode([node get:idx], owner) toIndex:idx];
                node = [node get:idx];
            }
            AAVNode *newNode = [node removeAfter:[node count] - 1 withOwner:owner];
            if (parent) {
                [parent set:newNode toIndex:idx];
            } else {
                newRoot = newNode;
            }
        }

        if (newSize < oldSize) {
            newTail = [newTail removeAfter:newSize withOwner:owner];
        }

        if (owner) {
            self.size = newSize;
            self.level = newLevel;
            self.root = newRoot;
            self.tail = newTail;
            self.altered = YES;
            return self;
        } else {
            return [[AAPersistentVector alloc] initWithSize:newSize level:newLevel root:newRoot tail:newTail];
        }
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
        return nil;
    }
}

-(NSUInteger)tailOffset {
    return [self tailOffsetWithSize:self.size];
}

-(NSUInteger)tailOffsetWithSize:(NSUInteger)size {
    return size < SIZE ? 0 : (((size - 1) >> SHIFT) << SHIFT);
}

-(NSArray *)all {
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (id value in self) {
        [a addObject:value];
    }
    return [NSArray arrayWithArray:a];
}

-(NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                 objects:(id __unsafe_unretained [])buffer
                                   count:(NSUInteger)len {
    if (state->state == 0) {
        state->mutationsPtr = (unsigned long *)&_size;
        state->state = 1;
        state->extra[0] = 0;
    }
    id __unsafe_unretained value = [self get:state->extra[0]];
    NSUInteger i;
    for (i = 0; i < len && value != nil; i += 1) {
        buffer[i] = value;
        state->extra[0] += 1;
        value = [self get:state->extra[0]];
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
    if ([super isEqual:object]) {
        return true;
    }
    if ([self class] != [object class]) {
        return false;
    }
    if (self.hash != ((AABaseVector *)object).hash) {
        return false;
    }
    if (self.size != ((AABaseVector *)object).size) {
        return false;
    }
    for (NSUInteger i = 0; i < self.size; i += 1) {
        if ([self get:i] != [(AABaseVector *)object get:i]) {
            return false;
        }
    }
    return true;
}

@end