//
//  AAHashCollisionNode.h
//  Persistent
//
//  Created by Anton Astashov on 28/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAINode.h"
@class AAOwner;

@interface AAHashCollisionNode : NSObject <AAINode> {
    NSUInteger _hash;
    NSMutableArray *_array;
    AAOwner *_owner;
}

-(instancetype)initWithHash:(NSUInteger)hash count:(NSUInteger)count array:(NSMutableArray *)array owner:(AAOwner *)owner;

@property NSUInteger count;
@property NSMutableArray *array;
@property AAOwner *owner;

@end
