//
//  AAPersistentFunctions.m
//  Persistent
//
//  Created by Anton Astashov on 07/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "AAPersistent.h"

@interface AAPersistentFunctions : XCTestCase
@end

@implementation AAPersistentFunctions

-(void)testPersist {
    AAPersistentHashMap *map = (AAPersistentHashMap *)persist(@{@"foo": @"bar", @"bla": @[@"zoo", @{@"abc": @"def"}]});
    NSString *result = [map objectAt:@[@"bla", @1, @"abc"]];
    XCTAssertEqualObjects(result, @"def");
}

-(void)testUnpersist {
    NSDictionary *dict = unpersist(persist(@{@"foo": @"bar", @"bla": @[@"zoo", @{@"abc": @"def"}]}));
    NSDictionary *result = @{@"foo": @"bar", @"bla": @[@"zoo", @{@"abc": @"def"}]};
    XCTAssertEqualObjects(dict, result);
}

-(void)testSet {
    AAPersistentHashMap *map = (AAPersistentHashMap *)persist(@{@"foo": @"bar", @"bla": @[@"zoo", @{@"abc": @"def"}]});
    map = [map setAt:@[@"bla", @1, @"abc"] withValue:@"deg"];
    XCTAssertEqualObjects(objectAt(map, @[@"bla", @1, @"abc"]), @"deg");
}

-(void)testInsert {
    AAPersistentHashMap *map = (AAPersistentHashMap *)persist(@{@"foo": @"bar", @"bla": @[@"zoo", @[@"a", @"c"]]});
    map = [map insertAt:@[@"bla", @1, @1] withValue:@"b"];
    id result = objectAt(map, @[@"bla", @1]);
    id expected = @[@"a", @"b", @"c"];
    XCTAssertEqualObjects(unpersist(result), expected);
}

-(void)testRemove {
    AAPersistentHashMap *map = (AAPersistentHashMap *)persist(@{@"foo": @"bar", @"bla": @[@"zoo", @{@"abc": @"def"}]});
    map = [map removeAt:@[@"bla", @1, @"abc"]];
    XCTAssertEqualObjects(objectAt(map, @[@"bla", @1, @"abc"]), nil);
}

-(void)testRemoveVector {
    AAPersistentHashMap *map = (AAPersistentHashMap *)persist(@{@"foo": @"bar", @"bla": @[@"zoo", @[@"a", @"b", @"c"]]});
    map = [map removeAt:@[@"bla", @1, @1]];
    id result = objectAt(map, @[@"bla", @1]);
    id expected = @[@"a", @"c"];
    XCTAssertEqualObjects(unpersist(result), expected);
}

-(void)testAdd {
    AAPersistentHashMap *map = (AAPersistentHashMap *)persist(@{@"foo": @{@"bar": @[@"a", @"b"]}});
    map = [map addAt:@[@"foo", @"bar"] withValue:@"c"];
    id result = objectAt(map, @[@"foo", @"bar"]);
    id expected = @[@"a", @"b", @"c"];
    XCTAssertEqualObjects(unpersist(result), expected);
}

-(void)testFailAdd {
    AAPersistentHashMap *map = (AAPersistentHashMap *)persist(@{@"foo": @{@"bar": @[@"a", @"b"]}});
    XCTAssertThrows([map addAt:@[@"foo"] withValue:@"c"]);
}

@end
