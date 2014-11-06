//
//  AABaseSetPrivate.h
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseSet.h"

@class AABaseHashMap;

@interface AABaseSet () {
    AABaseHashMap *_hashMap;
    // It never changes, just for sake of NSFastEnumeration
    NSUInteger _mutateFlag;
}

-(instancetype)initWithHashMap:(AABaseHashMap *)hashMap;

@property AABaseHashMap *hashMap;
@end
