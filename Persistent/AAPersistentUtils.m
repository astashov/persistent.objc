//
//  AAPersistentUtils.m
//  Persistent
//
//  Created by Anton Astashov on 08/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAPersistentUtils.h"

AAVNode *maybeCopyVNode(AAVNode *node, AAOwner *owner) {
    if (owner != nil && node != nil && owner == node.owner) {
        return node;
    } else {
        return [[AAVNode alloc]
                initWithArray: (node != nil ? [NSMutableArray arrayWithArray:node.array] : [NSMutableArray array])
                andOwner: owner
                ];
    }
}

NSUInteger mask(NSUInteger hash, NSUInteger shift) {
    return (hash >> shift) & MASK;
}

NSUInteger bitpos(NSUInteger hash, NSUInteger shift) {
    return 1 << mask(hash, shift);
}

id<AAINode> createNode(NSUInteger shift, id key1, id val1, id key2, id val2, AAOwner *owner) {
    NSUInteger key1hash = [key1 hash];
    NSUInteger key2hash = [key2 hash];
    if (key1hash == key2hash) {
        NSMutableArray *newArray = [[NSMutableArray alloc] initWithObjects:key1, val1, key2, val2, nil];
        return [[AAHashCollisionNode alloc] initWithHash:key1hash count:2 array:newArray owner:owner];
    } else {
        AABool *didAddLeaf = [[AABool alloc] init];
        return [[[AABitmapIndexedNode empty]
                 set:key1 withValue:val1 shift:shift didAddLeaf:didAddLeaf owner:owner]
                set:key2 withValue:val2 shift:shift didAddLeaf:didAddLeaf owner:owner];

    }
}

NSString *ib(int intValue) {
    int byteBlock = SHIFT;
    int totalBits = SIZE;
    int binaryDigit = 1;
    int byteBlockShift = SIZE % SHIFT;

    NSMutableString *binaryStr = [[NSMutableString alloc] init];

    do {
        [binaryStr insertString:((intValue & binaryDigit) ? @"1" : @"0" ) atIndex:0];

        if (--totalBits && !((totalBits - byteBlockShift) % byteBlock)) {
            [binaryStr insertString:@"|" atIndex:0];
        }

        binaryDigit <<= 1;
    } while (totalBits);

    return binaryStr;
}


// Jenkins hash functions

NSUInteger hashCombine(NSUInteger hash, NSUInteger value) {
    hash = 0x1fffffff & (hash + value);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
}

NSUInteger finish(NSUInteger hash) {
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
}

//

NSUInteger hashObjects(NSObject<NSFastEnumeration> *objects) {
    NSUInteger hash = 0;
    for (id object in objects) {
        hash = hashCombine(hash, [object hash]);
    }
    return finish(hash);
}
