//
//  AABitmapIndexedNode.h
//  Persistent
//
//  Created by Anton Astashov on 24/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AAINode.h"
@class AAOwner;

@interface AABitmapIndexedNode : NSObject <AAINode> {
    NSUInteger _bitmap;
    NSMutableArray *_array;
    AAOwner *_owner;
}

+(instancetype)empty;
-(id)initWithBitmap:(NSUInteger)bitmap array:(NSMutableArray *)array owner:(AAOwner *)owner;

@end
