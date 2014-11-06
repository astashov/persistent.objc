## Persistent Data Structures for Objective-C

The goal of this project is to implement [persistent data structures](http://en.wikipedia.org/wiki/Persistent_data_structure) for Objective-C.

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

// With each
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

### [Set](https://github.com/astashov/persistent.objc/blob/master/Persistent/Headers/AAPersistentSet.h)

It's just a proxy on top of `AAPersistentHashMap`, implementing set functionality on top of persistent hash map.

## Not really production ready

These data structures are not really production ready, they are not thoroughly tested so far. But you are more than encouraged to try it out and tell me if you find any bugs or want any additional features :) Pull Requests are also very welcomed.

## Reading

* [Why Persistent Data Structures are cool](https://github.com/vacuumlabs/persistent#got-it-and-it-is-cool-because)
* [How Persistent Vectors work](http://hypirion.com/musings/understanding-persistent-vector-pt-1)
* [How Persistent Hash Maps work](http://blog.higher-order.net/2009/09/08/understanding-clojures-persistenthashmap-deftwice.html)

## TODO

* Wrap it into CocoaPod
