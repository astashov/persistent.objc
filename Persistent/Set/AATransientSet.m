//
//  AATransientSet.m
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AATransientSetPrivate.h"
#import "AAPersistentSetPrivate.h"
#import "AATransientHashMap.h"

@implementation AATransientSet

-(instancetype)initWithHashMap:(AATransientHashMap *)hashMap {
    self = [super initWithHashMap:hashMap];
    return self;
}

-(AAPersistentSet *)asPersistent {
    return [[AAPersistentSet alloc] initWithHashMap:[(AATransientHashMap *)self.hashMap asPersistent]];
}

-(BOOL)isEqualToSet:(AATransientSet *)set {
    return [super isEqualToSet:set];
}

@end
