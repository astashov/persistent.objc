//
//  AABaseSet.h
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AABaseHashMap;

// Abstract class
@interface AABaseSet : NSObject {
    AABaseHashMap *_hashMap;
}

-(instancetype)initWithHashMap:(AABaseHashMap *)hashMap;

-(BOOL)containsObject:(id)anObject;
-(instancetype)addObject:(id)anObject;
-(instancetype)removeObject:(id)anObject;

-(void)each:(void(^)(id))block;

-(BOOL)isEqualToSet:(AABaseSet *)set;

@property AABaseHashMap *hashMap;
@property(readonly) NSUInteger count;
@end
