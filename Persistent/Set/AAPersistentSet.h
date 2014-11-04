//
//  AAPersistentSet.h
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseSet.h"

@class AAPersistentHashMap;
@class AATransientSet;

@interface AAPersistentSet : AABaseSet

+(instancetype)empty;
-(instancetype)initWithHashMap:(AAPersistentHashMap *)hashMap;
-(AATransientSet *)asTransient;
-(AAPersistentSet *)withTransient:(AATransientSet *(^)(AATransientSet *))block;

-(BOOL)isEqualToSet:(AAPersistentSet *)set;

@end
