//
//  AAMNode.h
//  Persistent
//
//  Created by Anton Astashov on 06/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AAOwner;

@interface AAMNode : NSObject {
    NSUInteger _length;
    AAOwner *_owner;
    BOOL _isLeaf;
}

@property NSUInteger length;
@property AAOwner *owner;
@property BOOL isLeaf;

@end
