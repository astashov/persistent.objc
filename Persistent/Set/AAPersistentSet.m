//
//  AAPersistentSet.m
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAPersistentSet.h"
#import "AATransientSet.h"
#import "AAPersistentHashMap.h"

@implementation AAPersistentSet

-(instancetype)initWithHashMap:(AAPersistentHashMap *)hashMap {
    self = [super initWithHashMap:hashMap];
    return self;
}

+(instancetype)empty {
    static AAPersistentSet *emptyPersistentSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyPersistentSet = [[self alloc] initWithHashMap:[AAPersistentHashMap empty]];
    });
    return emptyPersistentSet;
}

-(AATransientSet *)asTransient {
    return [[AATransientSet alloc] initWithHashMap:[self.hashMap asTransient]];
}

-(AAPersistentSet *)withTransient:(AATransientSet *(^)(AATransientSet *))block {
    AATransientSet *transient = [self asTransient];
    block(transient);
    return [transient asPersistent];
}

-(BOOL)isEqualToSet:(AAPersistentSet *)set {
    return [super isEqualToSet:set];
}

@end
