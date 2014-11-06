//
//  AASameHashObject.m
//  Persistent
//
//  Created by Anton Astashov on 06/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AASameHashObject.h"

@implementation AASameHashObject

-(instancetype)initWithString:(NSString *)str {
    self = [self init];
    if (self) {
        _string = str;
    }
    return self;
}

-(NSString *)description {
    return self.string;
}

-(NSUInteger)hash {
    return 123;
}

-(BOOL)isEqual:(id)object {
    return [super isEqual:object] ||
        ([self class] == [object class] && [self isEqualToObject:(AASameHashObject *)object]);
}

-(BOOL)isEqualToObject:(AASameHashObject *)object {
    return [self.string isEqualToString:object.string];
}

@end
