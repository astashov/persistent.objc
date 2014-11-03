//
//  AABaseVector.h
//  Persistent
//
//  Created by Anton Astashov on 01/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AAOwner;
@class AAVNode;
@class AATransientVector;

@interface AABaseVector : NSObject <NSFastEnumeration> {
    NSUInteger _count;
    AAOwner *_owner;
    AAVNode *_root;
    AAVNode *_tail;
    NSUInteger _level;
    BOOL _altered;
    NSUInteger _hash;
}

-(id)get:(NSUInteger)index;
-(instancetype)set:(NSUInteger)index withValue:(id)value;

-(instancetype)push:(id)value;
-(instancetype)pop;

-(AABaseVector *)asTransient;
-(AABaseVector *)asPersistent;
-(AABaseVector *)withTransient:(AABaseVector *(^)(AATransientVector *))block;

-(NSArray *)asArray;

// For debugging only :)
-(NSString *)internals;

-(BOOL)isEqualToVector:(AABaseVector *)vector;

@property(readonly, nonatomic) NSUInteger count;
@property(readonly, nonatomic) NSUInteger hash;

@end