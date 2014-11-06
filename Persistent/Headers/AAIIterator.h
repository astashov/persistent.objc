//
//  AAIIterator.h
//  Persistent
//
//  Created by Anton Astashov on 04/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AAIIterator <NSObject>

-(id)first;
-(id<AAIIterator>)next;

@optional

+(instancetype)create:(NSArray *)array;
+(instancetype)createWithArray:(NSArray *)array index:(NSUInteger)index iterator:(id<AAIIterator>)iterator;
-(instancetype)initWithArray:(NSArray *)array index:(NSUInteger)index iterator:(id<AAIIterator>)iterator;

@property NSArray *array;
@property NSUInteger index;
@property id<AAIIterator> iterator;

@end
