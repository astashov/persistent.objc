//
//  AATransientSet.h
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseSet.h"

@class AAPersistentSet;

@interface AATransientSet : AABaseSet

-(AAPersistentSet *)asPersistent;

@end
