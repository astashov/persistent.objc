//
//  AATransientHashMapPrivate.h
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseHashMapPrivate.h"
#import "AATransientHashMap.h"

@interface AATransientHashMap ()

-(instancetype)initWithCount:(NSUInteger)count root:(id<AAINode>)root owner:(AAOwner *)owner;

@end
