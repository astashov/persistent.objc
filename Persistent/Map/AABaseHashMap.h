//
//  AABaseHashMap.h
//  Persistent
//
//  Created by Anton Astashov on 02/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAINode.h"
@class AAPersistentHashMap;
@class AATransientHashMap;


@interface AABaseHashMap : NSObject {
    NSUInteger _count;
    id<AAINode> _root;
    AAOwner *_owner;
    BOOL _altered;
    NSUInteger _hash;
}

+(instancetype)empty;
-(instancetype)initWithCount:(NSUInteger)count root:(id<AAINode>)root;

-(id)get:(id)key;
-(instancetype)set:(id)key withValue:(id)value;
-(instancetype)remove:(id)key;

-(NSString *)internals;

-(AATransientHashMap *)asTransient;
-(AAPersistentHashMap *)asPersistent;
-(AABaseHashMap *)withTransient:(AATransientHashMap *(^)(AATransientHashMap *))block;

-(void)each:(void(^)(id key, id value))block;

@property NSUInteger count;
@property id<AAINode> root;
@property AAOwner *owner;
@property BOOL altered;
@property(readonly, nonatomic) NSUInteger hash;

@end
