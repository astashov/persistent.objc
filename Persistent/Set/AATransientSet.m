//
//  AATransientSet.m
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AATransientSet.h"
#import "AAPersistentSet.h"
#import "AATransientHashMap.h"

@implementation AATransientSet

-(instancetype)initWithHashMap:(AATransientHashMap *)hashMap {
    self = [super initWithHashMap:hashMap];
    return self;
}

+(instancetype)empty {
    static AATransientSet *emptyPersistentSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyPersistentSet = [[self alloc] initWithHashMap:[AATransientHashMap empty]];
    });
    return emptyPersistentSet;
}

-(AAPersistentSet *)asPersistent {
    return [[AAPersistentSet alloc] initWithHashMap:[self.hashMap asPersistent]];
}

-(BOOL)isEqualToSet:(AATransientSet *)set {
    return [super isEqualToSet:set];
}

@end
