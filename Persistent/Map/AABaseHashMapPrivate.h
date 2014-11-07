//
//  AABaseHashMapPrivate.h
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseHashMap.h"
#import "AAINode.h"

@interface AABaseHashMap () {
    NSUInteger _count;
    id<AAINode> _root;
    AAOwner *_owner;
    BOOL _altered;
    NSUInteger _hash;
}

-(instancetype)initWithCount:(NSUInteger)count root:(id<AAINode>)root;
-(AABaseHashMap *)ensureOwner:(AAOwner *)owner;

@property(nonatomic) NSUInteger count;
@property id<AAINode> root;
@property AAOwner *owner;
@property BOOL altered;
@end
