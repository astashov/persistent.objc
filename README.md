## Persistent Data Structures for Objective-C

The goal of this project is to implement persistent data structures for Objective-C.

### [Vector](https://github.com/astashov/persistent.objc/blob/master/Persistent/Vector/AABaseVector.h)

For now, it's a port of [Clojure's PersistentVector](https://github.com/clojure/clojure/blob/master/src/jvm/clojure/lang/PersistentVector.java) and [Dart's Persistent Vector](https://github.com/vacuumlabs/persistent/blob/master/lib/src/vector_impl.dart). It's a persistent bit-partitioned vector trie, and it uses the same optimizations, which are used in Clojure and Dart - tails and transients.

Basically there are `addObject:`/`removeLastObject` and `objectAtIndex:`/`replaceObjectAtIndex:withObject:` operations, and also `withTransient` method, which allows you to temporarily make the vector mutable and make modifications without creating instances every single time you make operations on it.

It doesn't have methods for inserting/removing elements in the middle of the vector. Unfortunately, you have to do that in a slow way - by creating a new vector from the scratch with (or - for deletion - without) the element.

### [HashMap](https://github.com/astashov/persistent.objc/blob/master/Persistent/Map/AABaseHashMap.h)

It's also a port of [Clojure's PersistentHashMap](https://github.com/clojure/clojure/blob/master/src/jvm/clojure/lang/PersistentHashMap.java). It's a Hash Array Mapped Trie based data structure, just persistent and with some optimizations (transients) - the same optimizations Clojure's Hash Map has.

Main methods are `objectForKey:`, `setObject:forKey`, and `removeObjectForKey:`, allowing you to add, modify, read and delete keys and values from the map.
Also, it has the `withTransient` method too, allowing to make bulk operations with the map faster.

### [Set](https://github.com/astashov/persistent.objc/blob/master/Persistent/Set/AAPersistentSet.h)

It's just a proxy on top of `AAPersistentHashMap`, implementing set functionality on top of persistent hash map.

## Not really production ready

These data structures are not really production ready, they are not thoroughly tested so far.

## Reading

* [Why Persistent Data Structures are cool](https://github.com/vacuumlabs/persistent#got-it-and-it-is-cool-because)
* [How Persistent Vectors work](http://hypirion.com/musings/understanding-persistent-vector-pt-1)
* [How Persistent Hash Maps work](http://blog.higher-order.net/2009/09/08/understanding-clojures-persistenthashmap-deftwice.html)

## TODO

* Improve NSFastEnumeration for AABaseVector
* Add NSFastEnumeration for AABaseHashMap
* Add NSFastEnumeration AAPersistentSet
* Add tests for AAHashCollisionNode (i.e. add hash-collisioned keys into hash map)

