## Persistent Data Structures for Objective-C

The goal of this project is to implement [persistent data structures](http://en.wikipedia.org/wiki/Persistent_data_structure) for Objective-C. Right now, there are Vector, Set and HashMap.

## Install

With CocoaPods, as easy as adding

```ruby
pod 'Persistent'
```

to your `Podfile`.

## Usage

### [Vector](https://github.com/astashov/persistent.objc/blob/master/Persistent/Headers/AAPersistentVector.h)

For now, it's a port of [Clojure's PersistentVector](https://github.com/clojure/clojure/blob/master/src/jvm/clojure/lang/PersistentVector.java) and [Dart's Persistent Vector](https://github.com/vacuumlabs/persistent/blob/master/lib/src/vector_impl.dart). It's a persistent bit-partitioned vector trie, and it uses the same optimizations, which are used in Clojure and Dart - tails and transients.

Basically there are `addObject:`/`removeLastObject` and `objectAtIndex:`/`replaceObjectAtIndex:withObject:` operations, and also `withTransient` method, which allows you to temporarily make the vector mutable and make modifications without creating instances every single time you make operations on it.

It doesn't have methods for inserting/removing elements in the middle of the vector. Unfortunately, you have to do that in a slow way - by creating a new vector from the scratch with (or - for deletion - without) the element.

#### Examples

```objc
#import "AAPersistentVector.h"
#import "AATransientVector.h"
#import "AAIIterator.h"

/// Initialization

AAPersistentVector *vector1 = [[AAPersistentVector alloc] init];

// But if you need a persistent empty vector, better use the pre-created empty one.
AAPersistentVector *vector2 = [AAPersistentVector empty];

// Or you can load an array into it during initialization:
AAPersistentVector *vector = [[AAPersistentVector alloc] initWithArray:@[@1, @2, @3]];

/// CRUD operations
[vector objectAtIndex:1]; // => @2
vector = [vector addObject:@4]; // => vector with @1, @2, @3, @4
vector = [vector replaceObjectAtIndex:2 withObject:@5]; // => vector with @1, @2, @5, @4
vector = [vector removeLastObject]; // => vector with @1, @2, @5

/// Convert to NSArray
[vector toArray]; // => @[@1, @2, @5]

/// Iterating

// With Fast Enumeration
for (id value in vector) {
    // going to iterate through values with `value` = @1, @2 and @5
}

// With Iterator
id<AAIIterator> iterator = [vector iterator];
while (iterator) {
    [iterator first]; // => @1, @2 and @5
    iterator = [iterator next];
}

// With each (fastest way)
[vector each:^(id value) {
    // going to iterate through values with `value` = @1, @2 and @5
}];

/// Transients

// Efficiently add 100 objects to the vector. Will be ~10 times faster than
// adding without transient
[vector withTransient:^(AATransientVector *transient) {
    for (NSUInteger i = 0; i < 100; i += 1) {
        transient = [transient addObject:@(i)];
    }
    return transient;
}];

// You can also do that without a block, if you want
AATransientVector *transientVector = [vector asTransient];
for (NSUInteger i = 0; i < 100; i += 1) {
    transientVector = [transientVector addObject:@(i)];
}
vector = [transientVector asPersistent];
```

### [HashMap](https://github.com/astashov/persistent.objc/blob/master/Persistent/Headers/AAPersistentHashMap.h)

It's also a port of [Clojure's PersistentHashMap](https://github.com/clojure/clojure/blob/master/src/jvm/clojure/lang/PersistentHashMap.java). It's a Hash Array Mapped Trie based data structure, just persistent and with some optimizations (transients) - the same optimizations Clojure's Hash Map has.

Main methods are `objectForKey:`, `setObject:forKey`, and `removeObjectForKey:`, allowing you to add, modify, read and delete keys and values from the map.
Also, it has the `withTransient` method too, allowing to make bulk operations with the map faster.

#### Examples

```objc
#import "AAPersistentHashMap.h"
#import "AATransientHashMap.h"
#import "AAIIterator.h"

/// Initialization

AAPersistentHashMap *map1 = [[AAPersistentHashMap alloc] init];

// But if you need a persistent empty map, better use the pre-created empty one.
AAPersistentHashMap *map2 = [AAPersistentHashMap empty];

// Or you can load a dictionary into it during initialization:
AAPersistentHashMap *map = [[AAPersistentHashMap alloc]
    initWithDictionary:@{@1: @2, @3: @4}
];

/// CRUD operations
[map objectForKey:@1]; // => @2
map = [map setObject:@6 forKey:@5]; // => map with @1: @2, @3: @4, @5: @6
map = [map removeObjectForKey:@3]; // => map with @1: @2, @5: @6

/// Convert to NSDictionary
[map toDictionary]; // => @{@1: @2, @5: @6}

/// Iterating

// With Fast Enumeration
for (id value in map) {
    // going to iterate through values with `value` = @1 and @5
}

// With Iterator
id<AAIIterator> iterator = [map iterator];
while (iterator) {
    [iterator first]; // => @[@1, @2] and @[@5, @6]
    iterator = [iterator next];
}

// With each (fastest way)
[map each:^(id key, id value) {
    // going to iterate through keys and values
}];

/// Transients

// Efficiently set 100 objects in the map. Will be ~10 times faster than
// adding without transient
[map withTransient:^(AATransientHashMap *transient) {
    for (NSUInteger i = 0; i < 100; i += 1) {
        transient = [transient setObject:@(i + 1) forKey:@(i)];
    }
    return transient;
}];

// You can also do that without a block, if you want
AATransientHashMap *transientMap = [map asTransient];
for (NSUInteger i = 0; i < 100; i += 1) {
    transientMap = [transientMap setObject:@(i + 1) forKey:@(i)];
}
map = [transientMap asPersistent];
```

### [Set](https://github.com/astashov/persistent.objc/blob/master/Persistent/Headers/AAPersistentSet.h)

It's just a proxy on top of `AAPersistentHashMap`, implementing set functionality on top of persistent hash map.

#### Examples

```objc
#import "AAPersistentSet.h"
#import "AATransientSet.h"
#import "AAIIterator.h"

/// Initialization

AAPersistentSet *set1 = [[AAPersistentSet alloc] init];

// But if you need a persistent empty vector, better use the pre-created empty one.
AAPersistentSet *set2 = [AAPersistentSet empty];

// Or you can load an array into it during initialization:
AAPersistentSet *set = [[AAPersistentSet alloc]
    initWithSet:[NSSet setWithObjects:@1, @2, @3, nil]
];

/// CRUD operations
[set containsObject:@1]; // => YES
set = [set addObject:@4]; // => set with @1, @2, @3, @4
set = [set addObject:@3]; // => set with @1, @2, @3, @4
set = [set removeObject:@3]; // => set with @1, @2, @4

/// Convert to NSSet
[set toSet]; // => NSSet with @1, @2 and @4

/// Iterating

// With Fast Enumeration
for (id value in set) {
    // going to iterate through values with `value` = @1, @2 and @4
}

// With Iterator
id<AAIIterator> iterator = [set iterator];
while (iterator) {
    [iterator first]; // => @1, @2 and @4
    iterator = [iterator next];
}

// With each (fastest way)
[set each:^(id value) {
    // going to iterate through values with `value` = @1, @2 and @4
}];

/// Transients

// Efficiently add 100 objects to the set. Will be ~10 times faster than
// adding without transient
[set withTransient:^(AATransientSet *transient) {
    for (NSUInteger i = 0; i < 100; i += 1) {
        transient = [transient addObject:@(i)];
    }
    return transient;
}];

// You can also do that without a block, if you want
AATransientSet *transientVector = [set asTransient];
for (NSUInteger i = 0; i < 100; i += 1) {
    transientVector = [transientVector addObject:@(i)];
}
set = [transientVector asPersistent];
```

## Performance

Tested in a pretty naive way - made the following operations with 1000000 records and compared the results. Used transients for persistent data structures where possible. I tested on my MacbookPro i7 2.7GHz with 16GB RAM.

### HashMap / Set

It's slower than NSMutableDictionary:

* ~20x (6.893s / 0.329s) for setObject:ForKey:
* ~15x (3.853s / 0.233s) for objectForKey:
* ~15x (1.243s / 0.074s) for iteration (with for-in for NSMutableDictionary and `each:` for AAPersistentHashMap)

### Vector

It's slower than NSMutableArray:

* ~100x (4.074s / 0.048s) for addObject:
* ~100x (1.169s / 0.011s) for objectForKey:
* ~120x (5.24s / 0.042s) for iteration (with for-in for NSMutableDictionary and `each:` for AAPersistentVector)

## Not really production ready

These data structures are not really production ready, they are not thoroughly tested so far. But you are more than encouraged to try it out and tell me if you find any bugs or want any additional features :) Pull Requests are also very welcomed.

## Reading

* [Why Persistent Data Structures are cool](https://github.com/vacuumlabs/persistent#got-it-and-it-is-cool-because)
* [How Persistent Vectors work](http://hypirion.com/musings/understanding-persistent-vector-pt-1)
* [How Persistent Hash Maps work](http://blog.higher-order.net/2009/09/08/understanding-clojures-persistenthashmap-deftwice.html)
