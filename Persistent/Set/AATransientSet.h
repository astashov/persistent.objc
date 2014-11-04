//
//  AATransientSet.h
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseSet.h"

@class AATransientHashMap;
@class AAPersistentSet;

@interface AATransientSet : AABaseSet

+(instancetype)empty;
-(instancetype)initWithHashMap:(AATransientHashMap *)hashMap;
-(AAPersistentSet *)asPersistent;

-(BOOL)isEqualToSet:(AAPersistentSet *)set;

@end
