//
//  PersistentTests.m
//  PersistentTests
//
//  Created by Anton Astashov on 04/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AAPersistentVector.h"
#import "AATransientVector.h"

@interface PersistentTests : XCTestCase

@end

@implementation PersistentTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
//        AAPersistentVector *v = [[AAPersistentVector alloc] init];
//        AATransientVector *t = (AATransientVector *)[v asTransient];
//        for (int i = 0; i < 10000; i += 1) {
//            t = [t push:@(i)];
//        }
//        v = (AAPersistentVector *)[t asPersistent];
//        NSUInteger a = 0;
//        for (NSNumber *i in v) {
//            a += [i unsignedIntegerValue];
//        }
//        NSLog(@"%lu", a);

//        NSMutableArray *b = [[NSMutableArray alloc] init];
//        for (int i = 0; i < 10000; i += 1) {
//            [b addObject:@(i)];
//        }
//        NSUInteger c = 0;
//        for (NSNumber *i in b) {
//            c += [i unsignedIntegerValue];
//        }
//        NSLog(@"%lu", c);

//        NSArray *d = [[NSArray alloc] init];
//        for (int i = 0; i < 10000; i += 1) {
//            NSMutableArray *a = [NSMutableArray arrayWithArray:d];
//            [a addObject:@(i)];
//            d = [NSArray arrayWithArray:a];
//        }
//        NSUInteger c = 0;
//        for (NSNumber *i in d) {
//            c += [i unsignedIntegerValue];
//        }
//        NSLog(@"%lu", c);
    }];
}

@end
