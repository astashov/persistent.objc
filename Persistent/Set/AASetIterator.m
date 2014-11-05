//
//  AASetIterator.m
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AASetIterator.h"

@implementation AASetIterator

-(id)initWithIterator:(id<AAIIterator>)anIterator {
    self = [self init];
    if (self) {
        iterator = anIterator;
    }
    return self;
}

-(id)first {
    id value = [iterator first];
    if ([value isKindOfClass:[NSArray class]]) {
        return (NSArray *)value[0];
    } else {
        return value;
    }
}

-(id<AAIIterator>)next {
    return [iterator next];
}

@end
