//
//  AAMNode.m
//  Persistent
//
//  Created by Anton Astashov on 06/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAMNode.h"

typedef id (^Combine)(id left, id right);

@implementation AAMNode

-(instancetype)initWithLength:(NSUInteger)length isLeaf:(BOOL)isLeaf owner:(AAOwner *)owner {
    self = [super init];
    if (self) {
        self.length = length;
        self.isLeaf = isLeaf;
        self.owner = owner;
    }
    return self;
}

//-(instancetype)insertWithKey:(id)key value:(id)value combine:(Combine)combine owner:(AAOwner *)owner {
//
//}


@end
