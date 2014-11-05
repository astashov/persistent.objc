//
//  AAINode.h
//  Persistent
//
//  Created by Anton Astashov on 24/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIIterator.h"
@class AABool;
@class AAOwner;

@protocol AAINode <NSObject>

-(id<AAINode>)set:(id)key
        withValue:(id)value
            shift:(NSUInteger)shift
       didAddLeaf:(AABool *)didAddLeaf
            owner:(AAOwner *)owner;
-(id<AAINode>)remove:(id)key
               shift:(NSUInteger)shift
      didRemoveLeaf:(AABool *)didRemoveLeaf
               owner:(AAOwner *)owner;
-(id)get:(id)key shift:(NSUInteger)shift;
-(void)each:(void(^)(id key, id value))block;

-(BOOL)isEmpty;

-(id<AAIIterator>)iterator;

@end
