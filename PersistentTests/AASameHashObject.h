//
//  AASameHashObject.h
//  Persistent
//
//  Created by Anton Astashov on 06/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AASameHashObject : NSObject {
    NSString *_string;
}

-(instancetype)initWithString:(NSString *)str;

@property(readonly) NSString *string;

@end
