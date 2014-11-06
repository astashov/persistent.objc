//
//  AAPersistentVector.m
//  Persistent
//
//  Created by Anton Astashov on 03/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAPersistentVector.h"
#import "AAPersistentVectorPrivate.h"
#import "AATransientVector.h"
#import "AAOwner.h"

@implementation AAPersistentVector

+(instancetype)empty {
    static AAPersistentVector *emptyPersistentVector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyPersistentVector = [[self alloc] init];
    });
    return emptyPersistentVector;
}

-(instancetype)initWithSize:(NSUInteger)size level:(NSUInteger)level root:(AAVNode *)root tail:(AAVNode *)tail {
    self = [self init];
    if (self) {
        self.count = size;
        self.level = level;
        self.root = root;
        self.tail = tail;
    }
    return self;
}

-(instancetype)initWithArray:(NSArray *)array {
    self = [AAPersistentVector empty];
    return [self withTransient:^(AATransientVector *transient) {
        for (id value in array) {
            [transient addObject:value];
        }
        return transient;
    }];
}

-(AATransientVector *)asTransient {
    return [super asTransient];
}

-(AAPersistentVector *)withTransient:(AATransientVector *(^)(AATransientVector *))block {
    return (AAPersistentVector *)[super withTransient:block];
}

@end
