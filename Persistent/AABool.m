//
//  AABool.m
//  Persistent
//
//  Created by Anton Astashov on 03/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AABool.h"

@implementation AABool

-(id)init {
    self = [super init];
    if (self) {
        self.value = NO;
    }
    return self;
}

@end
