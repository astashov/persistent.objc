//
//  AAPair.h
//  Persistent
//
//  Created by Anton Astashov on 05/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAPair : NSObject {
    id _first;
    id _second;
}

-(BOOL)isEqualToPair:(AAPair *)other;

@property id first;
@property id second;

@end
