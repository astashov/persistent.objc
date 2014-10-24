//
//  AAPersistentVector.m
//  Persistent
//
//  Created by Anton Astashov on 03/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAPersistentVector.h"

@implementation AAPersistentVector

-(instancetype)initWithSize:(NSUInteger)size level:(NSUInteger)level root:(AAVNode *)root tail:(AAVNode *)tail {
    self = [self init];
    if (self) {
        self.size = size;
        self.level = level;
        self.root = root;
        self.tail = tail;
    }
    return self;
}

@end
