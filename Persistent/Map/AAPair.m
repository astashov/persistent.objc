//
//  AAPair.m
//  Persistent
//
//  Created by Anton Astashov on 05/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAPair.h"

@implementation AAPair

-(instancetype)initWithFirst:(id)first andSecond:(id)second {
    self = [super init];
    if (self) {
        self.first = first;
        self.second = second;
    }
    return self;
}

-(BOOL)isEqualToPair:(AAPair *)other {
    return [self.first isEqual:other.first] && [self.second isEqual:other.second];
}

-(BOOL)isEqual:(id)object {
    return [super isEqual:object] ||
        ([self class] == [object class] && [self isEqualToPair:(AAPair *)object]);
}

-(NSUInteger)hash {
    return [self.first hash] + 31 * [self.second hash];
}

@end
