//
//  AAPersistentFunctions.m
//  Persistent
//
//  Created by Anton Astashov on 07/11/14.
//  Copyright (c) 2014 Anton Astashov. All rights reserved.
//

#import "AAPersistentFunctions.h"
#import "AAPersistentHashMap.h"
#import "AATransientHashMap.h"
#import "AAPersistentVector.h"
#import "AATransientVector.h"
#import "AAPersistentSet.h"
#import "AATransientSet.h"


id persist(id object) {
    if ([object isKindOfClass:[NSDictionary class]]) {
        AAPersistentHashMap *map = [AAPersistentHashMap empty];
        return [map withTransient:^(AATransientHashMap *transient) {
            for (id key in object) {
                transient = [transient setObject:persist(object[key]) forKey:persist(key)];
            }
            return transient;
        }];
    } else if ([object isKindOfClass:[NSArray class]]) {
        AAPersistentVector *vector = [AAPersistentVector empty];
        return [vector withTransient:^(AATransientVector *transient) {
            for (id value in object) {
                [transient addObject:persist(value)];
            }
            return transient;
        }];
    } else if ([object isKindOfClass:[NSSet class]]) {
        AAPersistentSet *set = [AAPersistentSet empty];
        return [set withTransient:^(AATransientSet *transient) {
            for (id value in object) {
                [transient addObject:persist(value)];
            }
            return transient;
        }];
    } else {
        return object;
    }
}

id unpersist(id object) {
    if ([object isKindOfClass:[AAPersistentHashMap class]]) {
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        [(AAPersistentHashMap *)object each:^(id key, id value) {
            [dictionary setObject:unpersist(value) forKey:unpersist(key)];
        }];
        return [[NSDictionary alloc] initWithDictionary:dictionary];
    } else if ([object isKindOfClass:[AAPersistentVector class]]) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [(AAPersistentVector *)object each:^(id value) {
            [array addObject:unpersist(value)];
        }];
        return [[NSArray alloc] initWithArray:array];
    } else if ([object isKindOfClass:[AAPersistentSet class]]) {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        [(AAPersistentSet *)object each:^(id value) {
            [set addObject:unpersist(value)];
        }];
        return [[NSSet alloc] initWithSet:set];
    } else {
        return object;
    }
}

id objectAt(id<AAIPersistent> object, NSArray *path) {
    if ([path count] == 0) {
        return object;
    } else {
        id segment = path[0];
        NSMutableArray *mutablePath = [path mutableCopy];
        [mutablePath removeObjectAtIndex:0];
        path = [[NSArray alloc] initWithArray:mutablePath];

        if ([object isKindOfClass:[AABaseHashMap class]]) {
            return objectAt([(AABaseHashMap *)object objectForKey:segment], path);
        } else if ([object isKindOfClass:[AABaseVector class]]) {
            return objectAt([(AABaseVector *)object objectAtIndex:[(NSNumber *)segment unsignedIntegerValue]], path);
        } else {
            [NSException raise:@"This should never happen" format:@"We should not call objectAt on %@", [object class]];
            return nil;
        }
    }
}

typedef id<AAIPersistent> (^traverseBlock)(id<AAIPersistent>, NSArray *newPath);

id traverse(id<AAIPersistent> object, NSArray *path, traverseBlock block) {
    id segment = path[0];
    NSMutableArray *mutablePath = [path mutableCopy];
    [mutablePath removeObjectAtIndex:0];
    path = [[NSArray alloc] initWithArray:mutablePath];

    if ([object isKindOfClass:[AABaseHashMap class]]) {
        id newObject = block([(AABaseHashMap *)object objectForKey:segment], path);
        return [(AABaseHashMap *)object setObject:newObject forKey:segment];
    } else if ([object isKindOfClass:[AABaseVector class]]) {
        NSUInteger index = [(NSNumber *)segment unsignedIntegerValue];
        id newObject = block([(AABaseVector *)object objectAtIndex:index], path);
        return [(AABaseVector *)object replaceObjectAtIndex:index withObject:newObject];
    } else {
        [NSException raise:@"This should never happen" format:@"We should not call insertAt on %@", [object class]];
        return nil;
    }

}

id<AAIPersistent> insertAt(id<AAIPersistent> object, NSArray *path, id value) {
    id segment = path[0];
    if ([path count] > 1) {
        return traverse(object, path, ^(id<AAIPersistent> nextObj, NSArray *newPath) {
            return insertAt(nextObj, newPath, value);
        });
    } else {
        if ([object isKindOfClass:[AABaseHashMap class]]) {
            return [(AABaseHashMap *)object setObject:value forKey:segment];
        } else if ([object isKindOfClass:[AABaseVector class]]) {
            NSUInteger index = [(NSNumber *)segment unsignedIntegerValue];
            if ([(AABaseVector *)object count] == index) {
                return [(AABaseVector *)object addObject:value];
            } else {
                return [(AABaseVector *)object replaceObjectAtIndex:index withObject:value];
            }
        } else {
            [NSException raise:@"This should never happen" format:@"We should not call insertAt on %@", [object class]];
            return nil;
        }
    }
}

id<AAIPersistent> removeAt(id<AAIPersistent> object, NSArray *path) {
    id segment = path[0];
    if ([path count] > 1) {
        return traverse(object, path, ^(id<AAIPersistent> nextObj, NSArray *newPath) {
            return removeAt(nextObj, newPath);
        });
    } else {
        if ([object isKindOfClass:[AABaseHashMap class]]) {
            return [(AABaseHashMap *)object removeObjectForKey:segment];
        } else if ([object isKindOfClass:[AABaseVector class]]) {
            NSUInteger index = [(NSNumber *)segment unsignedIntegerValue];
            if ([(AABaseVector *)object count] - 1 == index) {
                return [(AABaseVector *)object removeLastObject];
            } else {
                [NSException raise:@"Non-allowed operation" format: @"Cannot delete non last element in a vector %@", object];
                return nil;
            }
        } else {
            [NSException raise:@"This should never happen" format:@"We should not call insertAt on %@", [object class]];
            return nil;
        }
    }
}

id<AAIPersistent> addAt(id<AAIPersistent> object, NSArray *path, id value) {
    if ([path count] > 0) {
        return traverse(object, path, ^(id<AAIPersistent> nextObj, NSArray *newPath) {
            return addAt(nextObj, newPath, value);
        });
    } else {
        if ([object isKindOfClass:[AABaseVector class]]) {
            return [(AABaseVector *)object addObject:value];
        } else {
            [NSException raise:@"addAt's path leads to not a vector" format:@"We should not call addAt on %@", [object class]];
            return nil;
        }
    }
}

