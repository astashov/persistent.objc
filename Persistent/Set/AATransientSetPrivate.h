//
//  AATransientSetPrivate.h
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseSetPrivate.h"
#import "AATransientSet.h"

@class AATransientHashMap;

@interface AATransientSet ()

-(instancetype)initWithHashMap:(AATransientHashMap *)hashMap;

@end
