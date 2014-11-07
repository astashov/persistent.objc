//
//  AABaseVectorPrivate.h
//  Persistent
//
//  Created by Anton Astashov on 23/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseVector.h"

@class AAOwner;
@class AAVNode;
@class AATransientVector;

@interface AABaseVector () {
    NSUInteger _count;
    AAOwner *_owner;
    AAVNode *_root;
    AAVNode *_tail;
    NSUInteger _level;
    BOOL _altered;
    NSUInteger _hash;
}

-(AABaseVector *)ensureOwner:(AAOwner *)owner;
-(AATransientVector *)asTransient;
-(AABaseVector *)withTransient:(AATransientVector *(^)(AATransientVector *))block;

@property AAOwner *owner;
@property AAVNode *root;
@property AAVNode *tail;
@property NSUInteger level;
@property BOOL altered;
@property(nonatomic) NSUInteger count;

@end

