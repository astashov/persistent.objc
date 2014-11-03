//
//  AAPersistentHashMapClass.m
//  Persistent
//
//  Created by Anton Astashov on 28/10/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AAPersistentHashMap.h"
#import "AATransientHashMap.h"

@interface AAPersistentHashMapClass : XCTestCase

@end

static NSString *foo(NSUInteger i) {
    return [NSString stringWithFormat:@"foo%lu", (unsigned long)i];
}

static NSString *bar(NSUInteger i) {
    return [NSString stringWithFormat:@"bar%lu", (unsigned long)i];
}

@implementation AAPersistentHashMapClass

-(void)testSet {
    AAPersistentHashMap *v = [AAPersistentHashMap empty];
    for (int i = 0; i < 72; i += 1) { v = [v set:foo(i) withValue:bar(i)]; }
    for (int i = 0; i < 72; i += 1) {
        XCTAssertEqualObjects([v get:foo(i)], bar(i));
    }
}

-(void)testRemove {
    AAPersistentHashMap *v = [AAPersistentHashMap empty];
    for (int i = 0; i < 72; i += 1) { v = [v set:foo(i) withValue:bar(i)]; }
    for (int i = 20; i < 32; i += 1) { v = [v remove:foo(i)]; }
    for (int i = 0; i < 72; i += 1) {
        XCTAssertEqualObjects([v get:foo(i)], (i >= 20 && i < 32) ? nil : bar(i));
    }
}

-(void)testAsTransient {
    AAPersistentHashMap *v = [AAPersistentHashMap empty];
    v = (AAPersistentHashMap *)[v withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 72; i += 1) { [transient set:foo(i) withValue:bar(i)]; }
        [transient set:@"foo50" withValue:@"bar123"];
        for (int i = 0; i < 10; i += 1) { [transient remove:foo(i)]; }
        return transient;
    }];
    for (int i = 0; i < 72; i += 1) {
        NSString *val;
        if (i < 10) {
            val = nil;
        } else if (i == 50) {
            val = @"bar123";
        } else {
            val = bar(i);
        }
        XCTAssertEqualObjects([v get:foo(i)], val);
    }
    XCTAssertEqual(v.count, 62);
}

-(void)testImmutability {
    AAPersistentHashMap *v = [AAPersistentHashMap empty];
    AAPersistentHashMap *a = (AAPersistentHashMap *)[v withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 100; i += 1) { [transient set:foo(i) withValue:bar(i)]; }
        return transient;
    }];
    AAPersistentHashMap *b = (AAPersistentHashMap *)[a withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 50; i += 1) { [transient remove:foo(i)]; }
        return transient;
    }];
    AAPersistentHashMap *c = (AAPersistentHashMap *)[b withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 25; i += 1) { [transient set:foo(i) withValue:bar(i + 100)]; }
        return transient;
    }];
    AAPersistentHashMap *d = [a set:foo(1000) withValue:bar(1000)];
    AAPersistentHashMap *e = [b remove:foo(25)];
    AAPersistentHashMap *f = [c set:foo(10) withValue:bar(2000)];

    XCTAssertEqual(v.count, 0);

    XCTAssertEqual(a.count, 100);
    for (int i = 0; i < 100; i += 1) {
        XCTAssertEqualObjects([a get:foo(i)], bar(i));
    }

    XCTAssertEqual(b.count, 50);
    for (int i = 0; i < 100; i += 1) {
        XCTAssertEqualObjects([b get:foo(i)], i < 50 ? nil : bar(i));
    }

    XCTAssertEqual(c.count, 75);
    for (int i = 0; i < 100; i += 1) {
        NSString *val;
        if (i < 25) {
            val = bar(i + 100);
        } else if (i >= 25 && i < 50) {
            val = nil;
        } else {
            val = bar(i);
        }
        XCTAssertEqualObjects([c get:foo(i)], val);
    }

    XCTAssertEqual(d.count, 101);
    XCTAssertEqualObjects([d get:foo(1000)], bar(1000));

    XCTAssertEqual(e.count, 50);
    XCTAssertEqualObjects([e get:foo(25)], nil);

    XCTAssertEqual(f.count, 75);
    XCTAssertEqualObjects([f get:foo(10)], bar(2000));
}

-(void)testEquality {
    AAPersistentHashMap *a = [AAPersistentHashMap empty];
    for (int i = 0; i < 100; i += 1) { a = [a set:foo(i) withValue:bar(i)]; }

    AAPersistentHashMap *b = [AAPersistentHashMap empty];
    for (int i = 0; i < 100; i += 1) { b = [b set:foo(i) withValue:bar(i)]; }

    AAPersistentHashMap *c = [AAPersistentHashMap empty];
    for (int i = 0; i < 99; i += 1) { c = [c set:foo(i) withValue:bar(i)]; }

    XCTAssertEqualObjects(a, a);
    XCTAssertEqualObjects(a, b);
    XCTAssertNotEqualObjects(a, c);
}


//-(void)testBenchmarks {
//
//    [self measureBlock:^{
//        //    AAPersistentHashMap *v = [AAPersistentHashMap empty];
//        //    v = (AAPersistentHashMap *)[v withTransient:^(AATransientHashMap *transient) {
//        //        for (int i = 0; i < 100000; i += 1) {
//        //            [transient set:[NSString stringWithFormat:@"foo%d", i] withValue:[NSString stringWithFormat:@"bar%d", i]];
//        //        }
//        //        return transient;
//        //    }];
//        //    // -> ~0.85s
//
//        //    AAPersistentHashMap *v = [AAPersistentHashMap empty];
//        //    for (int i = 0; i < 100000; i += 1) {
//        //        v = [v set:[NSString stringWithFormat:@"foo%d", i] withValue:[NSString stringWithFormat:@"bar%d", i]];
//        //    }
//        //    // -> ~2.65s
//
//        //    NSMutableDictionary *v = [[NSMutableDictionary alloc] init];
//        //    for (int i = 0; i < 100000; i += 1) {
//        //        [v setObject:[NSString stringWithFormat:@"bar%d", i] forKey:[NSString stringWithFormat:@"foo%d", i]];
//        //    }
//        //    // -> ~0.08s
//    }];
//}

@end
