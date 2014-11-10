//
//  AABaseHashMap.h
//  Persistent
//
//  Created by Anton Astashov on 02/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIIterator.h"
#import "AAIPersistent.h"

// Abstract class
@interface AABaseHashMap : NSObject <NSFastEnumeration, AAIPersistent>

-(id)objectForKey:(id)key;
-(instancetype)setObject:(id)key forKey:(id)value;
-(instancetype)removeObjectForKey:(id)key;

-(NSString *)internals;

-(void)each:(void(^)(id key, id value))block;

-(BOOL)isEqualToHashMap:(AABaseHashMap *)hashMap;

-(id<AAIIterator>)iterator;

-(NSDictionary *)toDictionary;

-(id)objectAt:(NSArray *)path;
-(instancetype)setAt:(NSArray *)path withValue:(id)value;
-(instancetype)removeAt:(NSArray *)path;
-(instancetype)addAt:(NSArray *)path withValue:(id)value;

@property(readonly, nonatomic) NSUInteger count;

@end
