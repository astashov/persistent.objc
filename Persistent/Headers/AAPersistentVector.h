//
//  AAPersistentVector.h
//  Persistent
//
//  Created by Anton Astashov on 03/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseVector.h"

@class AATransientVector;

@interface AAPersistentVector : AABaseVector

+(instancetype)empty;
-(instancetype)initWithArray:(NSArray *)array;

-(AAPersistentVector *)withTransient:(AATransientVector *(^)(AATransientVector *))block;
-(AATransientVector *)asTransient;

@end
