//
//  AABaseHashMap.h
//  Persistent
//
//  Created by Anton Astashov on 02/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIIterator.h"

// Abstract class
@interface AABaseHashMap : NSObject <NSFastEnumeration>

-(id)objectForKey:(id)key;
-(instancetype)setObject:(id)key forKey:(id)value;
-(instancetype)removeObjectForKey:(id)key;

-(NSString *)internals;

-(void)each:(void(^)(id key, id value))block;

-(BOOL)isEqualToHashMap:(AABaseHashMap *)hashMap;

-(id<AAIIterator>)iterator;

-(NSDictionary *)toDictionary;

@property(readonly, nonatomic) NSUInteger count;

@end
