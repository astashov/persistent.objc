//
//  AAPersistentFunctions.h
//  Persistent
//
//  Created by Anton Astashov on 07/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIPersistent.h"

id persist(id object);
id unpersist(id object);
id objectAt(id object, NSArray *path);
id<AAIPersistent> insertAt(id<AAIPersistent> object, NSArray *path, id value);
id<AAIPersistent> removeAt(id<AAIPersistent> object, NSArray *path);
id<AAIPersistent> addAt(id<AAIPersistent> object, NSArray *path, id value);