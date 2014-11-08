//
//  AAPersistentUtils.h
//  Persistent
//
//  Created by Anton Astashov on 04/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAVNode.h"
#import "AABitmapIndexedNode.h"
#import "AAHashCollisionNode.h"
#import "AABool.h"

static const NSUInteger SHIFT = 5;
static const NSUInteger SIZE = 1 << SHIFT;
static const NSUInteger MASK = SIZE - 1;

AAVNode *maybeCopyVNode(AAVNode *node, AAOwner *owner);
NSUInteger mask(NSUInteger hash, NSUInteger shift);
NSUInteger bitpos(NSUInteger hash, NSUInteger shift);
id<AAINode> createNode(NSUInteger shift, id key1, id val1, id key2, id val2, AAOwner *owner);
NSString *ib(int intValue);
NSUInteger hashObjects(NSObject<NSFastEnumeration> *objects);
