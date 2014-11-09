//
//  AAPersistentSetClass.m
//  Persistent
//
//  Created by Anton Astashov on 03/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AAPersistent.h"

@interface AAPersistentSetClass : XCTestCase

@end

@implementation AAPersistentSetClass

-(void)testSet {
    AAPersistentSet *v = [AAPersistentSet empty];
    for (int i = 0; i < 72; i += 1) { v = [v addObject:@(i)]; }
    for (int i = 0; i < 72; i += 1) {
        XCTAssert([v containsObject:@(i)]);
    }
}

-(void)testRemove {
    AAPersistentSet *v = [AAPersistentSet empty];
    for (int i = 0; i < 72; i += 1) { v = [v addObject:@(i)]; }
    for (int i = 20; i < 32; i += 1) { v = [v removeObject:@(i)]; }
    for (int i = 0; i < 72; i += 1) {
        BOOL result = [v containsObject:@(i)];
        XCTAssert((i >= 20 && i < 32) ? !result : result);
    }
}

-(void)testAsTransient {
    AAPersistentSet *v = [AAPersistentSet empty];
    v = [v withTransient:^(AATransientSet *transient) {
        for (int i = 0; i < 72; i += 1) { [transient addObject:@(i)]; }
        [transient addObject:@(123)];
        for (int i = 0; i < 10; i += 1) { [transient removeObject:@(i)]; }
        return transient;
    }];
    for (int i = 0; i < 10; i += 1) { XCTAssert(![v containsObject:@(i)]); }
    for (int i = 10; i < 72; i += 1) { XCTAssert([v containsObject:@(i)]); }
    XCTAssert([v containsObject:@(123)]);
}

-(void)testImmutability {
    AAPersistentSet *v = [AAPersistentSet empty];
    AAPersistentSet *a = [v withTransient:^(AATransientSet *transient) {
        for (int i = 0; i < 100; i += 1) { [transient addObject:@(i)]; }
        return transient;
    }];
    AAPersistentSet *b = [a withTransient:^(AATransientSet *transient) {
        for (int i = 0; i < 50; i += 1) { [transient removeObject:@(i)]; }
        return transient;
    }];
    AAPersistentSet *c = [b withTransient:^(AATransientSet *transient) {
        for (int i = 0; i < 25; i += 1) { [transient addObject:@(i + 100)]; }
        return transient;
    }];
    AAPersistentSet *d = [a addObject:@(1000)];
    AAPersistentSet *e = [b removeObject:@(25)];
    AAPersistentSet *f = [c addObject:@(2000)];

    XCTAssertEqual(v.count, 0);

    XCTAssertEqual(a.count, 100);
    for (int i = 0; i < 100; i += 1) {
        XCTAssert([a containsObject:@(i)]);
    }

    XCTAssertEqual(b.count, 50);
    for (int i = 0; i < 100; i += 1) {
        BOOL result = [b containsObject:@(i)];
        XCTAssert(i < 50 ? !result : result);
    }

    XCTAssertEqual(c.count, 75);
    for (int i = 0; i < 25; i += 1) { XCTAssert([c containsObject:@(i + 100)]); }
    for (int i = 25; i < 50; i += 1) { XCTAssert(![c containsObject:@(i)]); }
    for (int i = 50; i < 100; i += 1) { XCTAssert([c containsObject:@(i)]); }

    XCTAssertEqual(d.count, 101);
    XCTAssert([d containsObject:@(1000)]);

    XCTAssertEqual(e.count, 50);
    XCTAssert(![e containsObject:@(25)]);

    XCTAssertEqual(f.count, 76);
    XCTAssert([f containsObject:@(2000)]);
}

-(void)testEquality {
    AAPersistentSet *a = [AAPersistentSet empty];
    for (int i = 0; i < 100; i += 1) { a = [a addObject:@(i)]; }

    AAPersistentSet *b = [AAPersistentSet empty];
    for (int i = 0; i < 100; i += 1) { b = [b addObject:@(i)]; }

    AAPersistentSet *c = [AAPersistentSet empty];
    for (int i = 0; i < 99; i += 1) { c = [c addObject:@(i)]; }

    XCTAssertEqualObjects(a, a);
    XCTAssertEqualObjects(a, b);
    XCTAssertNotEqualObjects(a, c);
}

-(void)testFastEnumeration {
    AAPersistentSet *a = [AAPersistentSet empty];
    for (int i = 0; i < 100; i += 1) { a = [a addObject:@(i)]; }

    NSMutableSet *d = [[NSMutableSet alloc] init];
    for (id b in a) {
        [d addObject:b];
    }
    for (int i = 0; i < 100; i += 1) {
        XCTAssert([a containsObject:@(i)]);
    }
}

-(void)testInitWithSet {
    AAPersistentSet *a = [[AAPersistentSet alloc] initWithSet:[NSSet setWithArray:@[@"a", @"b", @"c"]]];
    XCTAssert([a containsObject:@"a"]);
    XCTAssert([a containsObject:@"b"]);
    XCTAssert([a containsObject:@"c"]);
}

-(void)testToSet {
    AAPersistentSet *a = [[AAPersistentSet alloc] initWithSet:[NSSet setWithArray:@[@"a", @"b", @"c"]]];
    NSSet *result = [NSSet setWithArray:@[@"a", @"b", @"c"]];
    XCTAssertEqualObjects([a toSet], result);
}

@end
