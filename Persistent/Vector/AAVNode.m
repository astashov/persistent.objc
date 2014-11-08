//
//  AAVNode.m
//  Persistent
//
//  Created by Anton Astashov on 01/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAVNode.h"
#import "AAPersistentUtils.h"
#import "AABool.h"
#import "AAVectorIterator.h"

@implementation AAVNode

-(instancetype)initWithArray: (NSMutableArray *)array andOwner: (AAOwner *)owner {
    self = [super init];
    if (self) {
        self.array = array;
        self.owner = owner;
    }
    return self;
}

-(NSUInteger)count {
    return [self.array count];
}

-(BOOL)isEmpty {
    return [self count] == 0;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[%@ (%p)]", [self.array componentsJoinedByString:@", "], self.owner];
}

-(void)set:(id)value toIndex:(NSUInteger)index {
    if ([self count] > index) {
        self.array[index] = value;
    } else if ([self count] == index) {
        [self.array addObject:value];
    } else {
        NSException *exception = [[NSException alloc]
            initWithName:[NSString stringWithFormat: @"Should not happen; %@, %@", @([self count]), @(index)]
            reason:@""
            userInfo:@{}
        ];
        [exception raise];
    }
}

-(id)get:(NSUInteger)index {
    return (index < [self count] ? self.array[index] : nil);
}

-(instancetype)removeAfter:(NSUInteger)newSize withOwner:(AAOwner *)owner {
    NSUInteger sizeIndex = (newSize - 1) & MASK;
    if (newSize != 0 && sizeIndex >= [self count] - 1) {
        return self;
    } else {
        AAVNode *editableNode = maybeCopyVNode(self, owner);
        if (newSize == 0) {
            editableNode.array = [NSMutableArray array];
        } else {
            NSRange range = NSMakeRange(sizeIndex + 1, ([editableNode count] - 1 - sizeIndex));
            [editableNode.array removeObjectsInRange:range];
        }
        return editableNode;
    }
}

-(instancetype)update:(NSUInteger)index withValue:(id)value level:(NSUInteger)level owner:(AAOwner *)owner didAlter:(AABool *)didAlter {
    NSUInteger idx = (index >> level) & MASK;
    BOOL nodeHas = idx < [self count];
    if (level > 0) {
        AAVNode *lowerNode = self.array[idx];
        AAVNode *newLowerNode = [lowerNode
            update:index withValue:value level:level - SHIFT owner:owner didAlter:didAlter
        ];
        if (newLowerNode == lowerNode) {
            return self;
        } else {
            AAVNode *newNode = maybeCopyVNode(self, owner);
            [newNode set:newLowerNode toIndex:idx];
            return newNode;
        }
    } else {
        if (nodeHas && self.array[idx] == value) {
            return self;
        } else {
            didAlter.value = YES;
            AAVNode *newNode = maybeCopyVNode(self, owner);
            [newNode set:value toIndex:idx];
            return newNode;
        }
    }
}

-(id<AAIIterator>)iterator {
    return [AAVectorIterator create:self.array];
}

@end