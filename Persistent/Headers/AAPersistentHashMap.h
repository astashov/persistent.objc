//
//  AAPersistentHashMap.h
//  Persistent
//
//  Created by Anton Astashov on 25/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseHashMap.h"

@class AATransientHashMap;

@interface AAPersistentHashMap : AABaseHashMap

+(instancetype)empty;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(AATransientHashMap *)asTransient;
-(AAPersistentHashMap *)withTransient:(AATransientHashMap *(^)(AATransientHashMap *))block;

@end
