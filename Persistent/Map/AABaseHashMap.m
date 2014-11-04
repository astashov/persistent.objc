//
//  AABaseHashMap.m
//  Persistent
//
//  Created by Anton Astashov on 02/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AABaseHashMap.h"
#import "AAINode.h"
#import "AABool.h"
#import "AABitmapIndexedNode.h"
#import "AAPersistentHashMap.h"
#import "AATransientHashMap.h"
#import "AAOwner.h"

@implementation AABaseHashMap

-(instancetype)initWithCount:(NSUInteger)count root:(id<AAINode>)root {
    self = [self init];
    if (self) {
        self.count = count;
        self.root = root;
        self.altered = NO;
    }
    return self;
}

+(instancetype)empty {
    static AAPersistentHashMap *emptyPersistentHashMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyPersistentHashMap = [[self alloc] initWithCount:0 root:[AABitmapIndexedNode empty]];
    });
    return emptyPersistentHashMap;
}

#pragma mark API

-(id)objectForKey:(id)key {
    return [self.root get:key shift:0];
}

-(instancetype)setObject:(id)value forKey:(id)key {
    AABool *didAddLeaf = [[AABool alloc] init];
    id<AAINode> newRoot = [self.root set:key withValue:value shift:0 didAddLeaf:didAddLeaf owner:self.owner];
    if (!self.owner && self.root == newRoot) {
        return self;
    } else if (self.owner) {
        self.root = newRoot;
        if (didAddLeaf.value) {
            self.count += 1;
        }
        self.altered = YES;
        return self;
    } else {
        return [[AAPersistentHashMap alloc] initWithCount:didAddLeaf.value ? self.count + 1 : self.count root:newRoot];
    }
}

-(instancetype)removeObjectForKey:(id)key {
    AABool *didRemoveLeaf = [[AABool alloc] init];
    id<AAINode> newRoot = [self.root remove:key shift:0 didRemoveLeaf:didRemoveLeaf owner:self.owner];
    if (!self.owner && self.root == newRoot) {
        return self;
    } else if (self.owner) {
        self.root = newRoot;
        if (didRemoveLeaf.value && self.count > 0) {
            self.count -= 1;
        }
        self.altered = YES;
        return self;
    } else {
        return [[AAPersistentHashMap alloc] initWithCount:didRemoveLeaf.value ? self.count - 1 : self.count root:newRoot];
    }
}

-(AATransientHashMap *)asTransient {
    return (AATransientHashMap *)(self.owner ? self : [self ensureOwner:[[AAOwner alloc] init]]);
}

-(AAPersistentHashMap *)asPersistent {
    return (AAPersistentHashMap *)[self ensureOwner:nil];
}

-(AABaseHashMap *)withTransient:(AATransientHashMap *(^)(AATransientHashMap *))block {
    AATransientHashMap *transient = [self asTransient];
    transient = (AATransientHashMap *)block(transient);
    return transient.altered ? [transient ensureOwner:self.owner] : self;
}

-(NSString *)internals {
    NSMutableDictionary *a = [[NSMutableDictionary alloc] init];
    a[@"count"] = @(self.count);
    a[@"root"] = self.root;
    return [a description];
}

-(void)each:(void(^)(id, id))block {
    [self.root each:block];
}

-(NSUInteger)hash {
    if (!_hash) {
        _hash = 0;
        [self each:^(id key, id value) {
            _hash += [key hash] ^ [value hash];
            _hash = _hash & 0x1fffffff;
        }];
    }
    return _hash;
}

-(BOOL)isEqual:(id)object {
    return [super isEqual:object] ||
    ([self class] == [object class] && [self isEqualToHashMap:(AABaseHashMap *)object]);
}

-(BOOL)isEqualToHashMap:(AABaseHashMap *)hashMap {
    if (self.hash != ((AABaseHashMap *)hashMap).hash) {
        return NO;
    }
    if (self.count != ((AABaseHashMap *)hashMap).count) {
        return NO;
    }
    __block BOOL result = YES;
    [self each:^(id key, id value) {
        result = result && [[self objectForKey:key] isEqual:[hashMap objectForKey:key]];
    }];
    return result;
}


# pragma mark Private Methods

-(AABaseHashMap *)ensureOwner:(AAOwner *)owner {
    if (owner == self.owner) {
        return self;
    } else if (!owner) {
        self.owner = owner;
        return [[AAPersistentHashMap alloc] initWithCount:self.count root:self.root];
    } else {
        return [[AATransientHashMap alloc] initWithCount:self.count root:self.root owner:owner];
    }
}

@end
