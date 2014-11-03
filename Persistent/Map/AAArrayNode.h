//
//  AAArrayNode.h
//  Persistent
//
//  Created by Anton Astashov on 27/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAINode.h"
@class AAOwner;

@interface AAArrayNode : NSObject <AAINode> {
    NSUInteger _count;
    NSMutableArray *_array;
    AAOwner *_owner;
}

-(instancetype)initWithCount:(NSUInteger)count array:(NSMutableArray *)array owner:(AAOwner *)owner;

@end
