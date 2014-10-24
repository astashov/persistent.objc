//
//  AABaseVectorPrivate.h
//  Persistent
//
//  Created by Anton Astashov on 23/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseVector.h"

@interface AABaseVector ()

@property AAOwner *owner;
@property AAVNode *root;
@property AAVNode *tail;
@property NSUInteger level;
@property BOOL altered;
@property NSUInteger size;
@property NSUInteger hash;

@end

