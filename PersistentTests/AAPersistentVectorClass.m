//
//  AAPersistentVectorClass.m
//  Persistent
//
//  Created by Anton Astashov on 04/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AAPersistent.h"

@interface AAPersistentVectorClass : XCTestCase
@end

@implementation AAPersistentVectorClass

-(void)testPushPop {
    AAPersistentVector *v = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 72; i += 1) { v = [v addObject:@(i)]; }
    for (int i = 0; i < 67; i += 1) { v = [v removeLastObject]; }
    for (int i = 0; i < 70; i += 1) { v = [v addObject:@(i)]; }
    for (int i = 0; i < 65; i += 1) { v = [v removeLastObject]; }
    NSArray *expected = @[@(0), @(1), @(2), @(3), @(4), @(0), @(1), @(2), @(3), @(4)];
    XCTAssertEqualObjects([v toArray], expected);
}

-(void)testGet {
    AAPersistentVector *v = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 72; i += 1) { v = [v addObject:@(i)]; }
    for (int i = 0; i < 72; i += 1) {
        XCTAssertEqualObjects([v objectAtIndex:i], @(i));
    }
}

-(void)testSet {
    AAPersistentVector *v = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 72; i += 1) { v = [v addObject:@(i)]; }
    v = [v replaceObjectAtIndex:37 withObject:@(100500)];
    for (int i = 0; i < 72; i += 1) {
        XCTAssertEqualObjects([v objectAtIndex:i], i == 37 ? @(100500) : @(i));
    }
}

-(void)testAsTransient {
    AAPersistentVector *v = [[AAPersistentVector alloc] init];
    v = (AAPersistentVector *)[v withTransient:^(AATransientVector *transient) {
        AATransientVector* tmp = transient;
        for (int i = 0; i < 72; i += 1) { [tmp addObject:@(i)]; }
        [tmp replaceObjectAtIndex:50 withObject:@(123)];
        for (int i = 0; i < 10; i += 1) { [tmp removeLastObject]; }
        return tmp;
    }];
    XCTAssertEqual(v.count, 62);
    for (int i = 0; i < 62; i += 1) {
        XCTAssertEqual([v objectAtIndex:i], i == 50 ? @(123) : @(i));
    }
    XCTAssertEqual(v.count, 62);
}

-(void)testImmutability {
    AAPersistentVector *v = [[AAPersistentVector alloc] init];
    AAPersistentVector *a = (AAPersistentVector *)[v withTransient:^(AATransientVector *transient) {
        for (int i = 0; i < 100; i += 1) { [transient addObject:@(i)]; }
        return transient;
    }];
    AAPersistentVector *b = (AAPersistentVector *)[a withTransient:^(AATransientVector *transient) {
        for (int i = 0; i < 50; i += 1) { [transient removeLastObject]; }
        return transient;
    }];
    AAPersistentVector *c = (AAPersistentVector *)[b withTransient:^(AATransientVector *transient) {
        for (int i = 0; i < 25; i += 1) { [transient replaceObjectAtIndex:i withObject:@(i + 100)]; }
        return transient;
    }];
    AAPersistentVector *d = [a addObject:@(1000)];
    AAPersistentVector *e = [b removeLastObject];
    AAPersistentVector *f = [c replaceObjectAtIndex:10 withObject:@(2000)];

    XCTAssertEqual(v.count, 0);

    XCTAssertEqual(a.count, 100);
    for (int i = 0; i < 100; i += 1) {
        XCTAssertEqual([a objectAtIndex:i], @(i));
    }

    XCTAssertEqual(b.count, 50);
    for (int i = 0; i < 50; i += 1) {
        XCTAssertEqual([b objectAtIndex:i], @(i));
    }

    XCTAssertEqual(c.count, 50);
    for (int i = 0; i < 50; i += 1) {
        NSNumber *value = i < 25 ? @(i + 100) : @(i);
        XCTAssertEqual([c objectAtIndex:i], value);
    }

    XCTAssertEqual(d.count, 101);
    XCTAssertEqual([d objectAtIndex:100], @(1000));

    XCTAssertEqual(e.count, 49);

    XCTAssertEqual(f.count, 50);
    XCTAssertEqual([f objectAtIndex:10], @(2000));
}

-(void)testIterator {
    AAPersistentVector *a = [AAPersistentVector empty];
    for (int i = 0; i < 100; i += 1) { a = [a addObject:@(i)]; }

    NSMutableArray *d = [[NSMutableArray alloc] init];
    id<AAIIterator> b = [a iterator];
    while (b) {
        [d addObject:[b first]];
        b = [b next];
    }
    for (int i = 0; i < 100; i += 1) {
        XCTAssert([d containsObject:@(i)]);
    }
}

-(void)testFastEnumeration {
    AAPersistentVector *v = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 100; i += 1) { v = [v addObject:@(i)]; }

    NSUInteger i = 0;
    for (id value in v) {
        XCTAssertEqual(value, [v objectAtIndex:i]);
        i += 1;
    }
}

-(void)testEquality {
    AAPersistentVector *a = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 100; i += 1) { a = [a addObject:@(i)]; }

    AAPersistentVector *b = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 100; i += 1) { b = [b addObject:@(i)]; }

    AAPersistentVector *c = [[AAPersistentVector alloc] init];
    for (int i = 0; i < 99; i += 1) { c = [c addObject:@(i)]; }

    XCTAssertEqualObjects(a, a);
    XCTAssertEqualObjects(a, b);
    XCTAssertNotEqualObjects(a, c);
}

@end
