//
//  AABaseSet.h
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIIterator.h"

@class AABaseHashMap;

// Abstract class
@interface AABaseSet : NSObject <NSFastEnumeration> {
    AABaseHashMap *_hashMap;
    // It never changes, just for sake of NSFastEnumeration
    NSUInteger _mutateFlag;
}

-(instancetype)initWithHashMap:(AABaseHashMap *)hashMap;

-(BOOL)containsObject:(id)anObject;
-(instancetype)addObject:(id)anObject;
-(instancetype)removeObject:(id)anObject;

-(void)each:(void(^)(id))block;

-(BOOL)isEqualToSet:(AABaseSet *)set;

-(id<AAIIterator>)iterator;

@property AABaseHashMap *hashMap;
@property(readonly) NSUInteger count;
@end
