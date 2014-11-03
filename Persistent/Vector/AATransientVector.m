//
//  AATransientVector.m
//  Persistent
//
//  Created by Anton Astashov on 03/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AATransientVector.h"

@implementation AATransientVector

-(instancetype)initWithSize:(NSUInteger)size level:(NSUInteger)level root:(AAVNode *)root tail:(AAVNode *)tail owner:(AAOwner *)owner {
    self = [self init];
    if (self) {
        self.count = size;
        self.level = level;
        self.root = root;
        self.tail = tail;
        self.owner = owner;
    }
    return self;
}

@end
