## Persistent Data Structures for Objective-C

The goal of this project is to implement persistent data structures for Objective-C. Mostly, it's port of [Clojure's PersistentVector](https://github.com/clojure/clojure/blob/master/src/jvm/clojure/lang/PersistentVector.java) and [Dart's Persistent Vector](https://github.com/vacuumlabs/persistent/blob/master/lib/src/vector_impl.dart). It uses the same optimizations, which are used in Clojure and Dart - tails and transients.

There is only AAPersistentVector for now, check out https://github.com/astashov/persistent.objc/blob/master/Persistent/AABaseVector.h for its API.

Basically there are `push`/`pop` and `get`/`set` operations, and also `withTransient` method, which allows you to temporarily make the vector mutable and make modifications without creating instances every single time we make operations with it.

It doesn't have methods for inserting/removing elements in the middle of the vector. Unfortunately, you have to do that in a slow way - by creating a new vector from the scratch with (or without) the element.

## Reading

* [Why Persistent Data Structures are cool](https://github.com/vacuumlabs/persistent#got-it-and-it-is-cool-because)
* [How Persistent Vectors work](http://hypirion.com/musings/understanding-persistent-vector-pt-1)

## TODO

* Improve NSFastEnumeration for AABaseVector
* Add AAPersistentHashMap
* Add AAPersistentSet

