//
//  AASetIterator.h
//  Persistent
//
//  Created by Anton Astashov on 05/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAIIterator.h"

@interface AASetIterator : NSObject <AAIIterator> {
    id<AAIIterator> iterator;
}
-(id)initWithIterator:(id<AAIIterator>)anIterator;
@end
