//
//  AABaseVector.h
//  Persistent
//
//  Created by Anton Astashov on 01/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>

// Abstract class
@interface AABaseVector : NSObject <NSFastEnumeration>

-(id)objectAtIndex:(NSUInteger)index;
-(instancetype)replaceObjectAtIndex:(NSUInteger)index withObject:(id)value;

-(instancetype)addObject:(id)value;
-(instancetype)removeLastObject;

-(NSArray *)toArray;

// For debugging only :)
-(NSString *)internals;

-(BOOL)isEqualToVector:(AABaseVector *)vector;

@property(readonly, nonatomic) NSUInteger count;
@property(readonly, nonatomic) NSUInteger hash;

@end