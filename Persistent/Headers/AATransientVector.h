//
//  AATransientVector.h
//  Persistent
//
//  Created by Anton Astashov on 03/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AABaseVector.h"
#import "AAPersistentVector.h"

@interface AATransientVector : AABaseVector

-(AAPersistentVector *)asPersistent;

@end
