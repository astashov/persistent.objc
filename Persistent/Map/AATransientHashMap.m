//
//  AATransientHashMap.m
//  Persistent
//
//  Created by Anton Astashov on 02/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AATransientHashMap.h"

@implementation AATransientHashMap

-(instancetype)initWithCount:(NSUInteger)count root:(id<AAINode>)root owner:(AAOwner *)owner {
    self = [self initWithCount:count root:root];
    if (self) {
        self.owner = owner;
    }
    return self;
}

@end
