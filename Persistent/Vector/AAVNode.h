//
//  AAVNode.h
//  Persistent
//
//  Created by Anton Astashov on 01/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AAOwner;
@class AABool;

@interface AAVNode : NSObject {
    NSMutableArray *_array;
    AAOwner *_owner;
}

-(instancetype)initWithArray: (NSMutableArray *)array andOwner: (AAOwner *)owner;
-(NSUInteger)count;
-(BOOL)isEmpty;
-(void)set:(id)value toIndex:(NSUInteger)index;
-(id)get:(NSUInteger)index;
-(instancetype)removeAfter:(NSUInteger)newSize withOwner:(AAOwner *)owner;
-(instancetype)update:(NSUInteger)index withValue:(id)value level:(NSUInteger)level owner:(AAOwner *)owner didAlter:(AABool *)didAlter;
//-(void)compact;

@property NSMutableArray *array;
@property AAOwner *owner;

@end
