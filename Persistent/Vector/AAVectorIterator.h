//
//  AAVectorIterator.h
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIIterator.h"

@interface AAVectorIterator : NSObject <AAIIterator> {
    NSArray *_array;
    NSUInteger _index;
    id<AAIIterator> _iterator;
}

@end
