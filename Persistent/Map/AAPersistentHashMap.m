//
//  AAPersistentHashMap.m
//  Persistent
//
//  Created by Anton Astashov on 25/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAPersistentHashMap.h"
#import "AATransientHashMap.h"
#import "AAOwner.h"

@implementation AAPersistentHashMap

+(instancetype)empty {
    static AAPersistentHashMap *emptyPersistentHashMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyPersistentHashMap = [[self alloc] init];
    });
    return emptyPersistentHashMap;
}

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [AAPersistentHashMap empty];
    return [self withTransient:^(AATransientHashMap *transient) {
        for (id key in dictionary) {
            transient = [transient setObject:dictionary[key] forKey:key];
        }
        return transient;
    }];
}

-(AATransientHashMap *)asTransient {
    return (AATransientHashMap *)(self.owner ? self : [self ensureOwner:[[AAOwner alloc] init]]);
}

-(AAPersistentHashMap *)withTransient:(AATransientHashMap *(^)(AATransientHashMap *))block {
    AATransientHashMap *transient = [self asTransient];
    transient = block(transient);
    return (AAPersistentHashMap *)(transient.altered ? [transient ensureOwner:self.owner] : self);
}

@end
