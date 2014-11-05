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
    for (int i = 0; i < 72; i += 1) { v = [v setObject:bar(i) forKey:foo(i)]; }
    for (int i = 0; i < 72; i += 1) {
        XCTAssertEqualObjects([v objectForKey:foo(i)], bar(i));
    }
}

-(void)testRemove {
    AAPersistentHashMap *v = [AAPersistentHashMap empty];
    for (int i = 0; i < 72; i += 1) { v = [v setObject:bar(i) forKey:foo(i)]; }
    for (int i = 20; i < 32; i += 1) { v = [v removeObjectForKey:foo(i)]; }
    for (int i = 0; i < 72; i += 1) {
        XCTAssertEqualObjects([v objectForKey:foo(i)], (i >= 20 && i < 32) ? nil : bar(i));
    }
}

-(void)testAsTransient {
    AAPersistentHashMap *v = [AAPersistentHashMap empty];
    v = (AAPersistentHashMap *)[v withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 72; i += 1) { [transient setObject:bar(i) forKey:foo(i)]; }
        [transient setObject:@"bar123" forKey:@"foo50"];
        for (int i = 0; i < 10; i += 1) { [transient removeObjectForKey:foo(i)]; }
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
        XCTAssertEqualObjects([v objectForKey:foo(i)], val);
    }
    XCTAssertEqual(v.count, 62);
}

-(void)testImmutability {
    AAPersistentHashMap *v = [AAPersistentHashMap empty];
    AAPersistentHashMap *a = (AAPersistentHashMap *)[v withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 100; i += 1) { [transient setObject:bar(i) forKey:foo(i)]; }
        return transient;
    }];
    AAPersistentHashMap *b = (AAPersistentHashMap *)[a withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 50; i += 1) { [transient removeObjectForKey:foo(i)]; }
        return transient;
    }];
    AAPersistentHashMap *c = (AAPersistentHashMap *)[b withTransient:^(AATransientHashMap *transient) {
        for (int i = 0; i < 25; i += 1) { [transient setObject:bar(i + 100) forKey:foo(i)]; }
        return transient;
    }];
    AAPersistentHashMap *d = [a setObject:bar(1000) forKey:foo(1000)];
    AAPersistentHashMap *e = [b removeObjectForKey:foo(25)];
    AAPersistentHashMap *f = [c setObject:bar(2000) forKey:foo(10)];

    XCTAssertEqual(v.count, 0);

    XCTAssertEqual(a.count, 100);
    for (int i = 0; i < 100; i += 1) {
        XCTAssertEqualObjects([a objectForKey:foo(i)], bar(i));
    }

    XCTAssertEqual(b.count, 50);
    for (int i = 0; i < 100; i += 1) {
        XCTAssertEqualObjects([b objectForKey:foo(i)], i < 50 ? nil : bar(i));
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
        XCTAssertEqualObjects([c objectForKey:foo(i)], val);
    }

    XCTAssertEqual(d.count, 101);
    XCTAssertEqualObjects([d objectForKey:foo(1000)], bar(1000));

    XCTAssertEqual(e.count, 50);
    XCTAssertEqualObjects([e objectForKey:foo(25)], nil);

    XCTAssertEqual(f.count, 75);
    XCTAssertEqualObjects([f objectForKey:foo(10)], bar(2000));
}

-(void)testEquality {
    AAPersistentHashMap *a = [AAPersistentHashMap empty];
    for (int i = 0; i < 100; i += 1) { a = [a setObject:bar(i) forKey:foo(i)]; }

    AAPersistentHashMap *b = [AAPersistentHashMap empty];
    for (int i = 0; i < 100; i += 1) { b = [b setObject:bar(i) forKey:foo(i)]; }

    AAPersistentHashMap *c = [AAPersistentHashMap empty];
    for (int i = 0; i < 99; i += 1) { c = [c setObject:bar(i) forKey:foo(i)]; }

    XCTAssertEqualObjects(a, a);
    XCTAssertEqualObjects(a, b);
    XCTAssertNotEqualObjects(a, c);
}

-(void)testIterator {
    AAPersistentHashMap *a = [AAPersistentHashMap empty];
    for (int i = 0; i < 100; i += 1) { a = [a setObject:bar(i) forKey:foo(i)]; }

    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    id b = [a iterator];
    while (b) {
        d[[b first][0]] = [b first][1];
        b = [b next];
    }
    for (int i = 0; i < 100; i += 1) {
        XCTAssertEqualObjects(d[foo(i)], bar(i));
    }
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
