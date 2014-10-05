//
//  AAPersistentVectorClass.m
//  Persistent
//
//  Created by Anton Astashov on 04/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AAPersistentVector.h"

@interface AAPersistentVectorClass : XCTestCase

@end

@implementation AAPersistentVectorClass

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    AAPersistentVector *v = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 500; i += 1) {
        v = [v push:@(i)];
    }
    NSUInteger a = 0;
    for (NSNumber *i in v) {
        a += [i unsignedIntegerValue];
    }
    AAPersistentVector *b = [v push:@(123)];
    AAPersistentVector *c = v;
    AAPersistentVector *d = [[v push:@(123)] pop];
    NSLog(@"%d", [v isEqual:b]);
    NSLog(@"%d", [v isEqual:c]);
    NSLog(@"%d", [v isEqual:d]);
}

@end
