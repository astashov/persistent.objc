//
//  AAMapNodeIterator.h
//  Persistent
//
//  Created by Anton Astashov on 04/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIIterator.h"

@interface AAMapNodeIterator : NSObject <AAIIterator> {
    NSArray *_array;
    NSUInteger _index;
    id<AAIIterator> _iterator;
}
@end
