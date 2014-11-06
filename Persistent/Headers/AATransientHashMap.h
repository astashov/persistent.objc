//
//  AATransientHashMap.h
//  Persistent
//
//  Created by Anton Astashov on 02/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseHashMap.h"

@class AAPersistentHashMap;

@interface AATransientHashMap : AABaseHashMap

-(AAPersistentHashMap *)asPersistent;

@end
