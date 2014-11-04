//
//  AANullNode.m
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AANullNode.h"

@implementation AANullNode

+(instancetype)node {
    static AANullNode *nullNode = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nullNode = [[self alloc] init];
    });
    return nullNode;
}

-(id<AAINode>)set:(id)key
        withValue:(id)value
            shift:(NSUInteger)shift
       didAddLeaf:(AABool *)didAddLeaf
            owner:(AAOwner *)owner {
    [NSException raise:@"This should not happen" format:@"This method should never be called on AANullNode"];
    return nil;
}

-(id<AAINode>)remove:(id)key
               shift:(NSUInteger)shift
       didRemoveLeaf:(AABool *)didRemoveLeaf
               owner:(AAOwner *)owner {
    [NSException raise:@"This should not happen" format:@"This method should never be called on AANullNode"];
    return nil;
}

-(id)get:(id)key shift:(NSUInteger)shift {
    [NSException raise:@"This should not happen" format:@"This method should never be called on AANullNode"];
    return nil;
}

-(void)each:(void(^)(id key, id value))block {
    [NSException raise:@"This should not happen" format:@"This method should never be called on AANullNode"];
}

-(BOOL)isEmpty {
    [NSException raise:@"This should not happen" format:@"This method should never be called on AANullNode"];
    return NO;
}

@end
