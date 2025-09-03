# Introduction
[Source: MIT CS 6.824](https://www.youtube.com/watch?v=cQP8WApzIQQ&list=PLrw6a1wE39_tb2fErI4-WkMbsvGQk9_UB)


### Advantages of Distributed systems
1. Parallelism
2. Scalability
3. Fault tolerance
4. security / isolated

### Challenges
1. Concurrency
2. Partial failures

#### Labs
1. [MapReduce: Simplified Data Processing on Large Clusters](https://research.google/pubs/archive/33491.pdf)
2. [Raft: In Search of an Understandable Consensus Algorithm](https://raft.github.io/)
3. K/V server
4. Sharded K/V service

## Intro
Infrastructure:  
- Storage  
- Communication  
- Computation  

**Target:** build an application with simplified API, that looks like a non-distributed system.


### Implementation tools
1. RPC: Remote Procedure Call, a protocol that allows a program to execute a procedure on a remote server.
2. Threads.
3. Concurrency control.


### What we care
1. Scalability.
2. Fault tolerance
    - Availability
    - Partition tolerance
    - Recoverability
    - Non-volatile storage
        - Replication
3. Consistency (Challange: More than one copy of data floating)
    - put(k, v)
    - get(k) -> v
    - Strong promised guarantee (expensive) v.s. weak promised guarantee (nearest or recent only)
    - How to stop failures propagation

## MapReduce
“Map” → split & transform; “Reduce” → group & aggregate; the runtime hides all parallelism, fault-tolerance, shuffling, and I/O.


```Markdown
// three file with 'a', 'b', 'c' characters
// Word count MapReduce
Input1 -> (Map) -> ('a', 1) ('b', 1)

Input2 -> (Map) ->          ('b', 1)

Input3 -> (Map) -> ('a', 1)         ('c', 1)
                       └--------┼------┼-> (Reduce) -> ('a', 2)
                                └------┼-> (Reduce) -> ('b', 2)
                                       └-> (Reduce) -> ('c', 1)
```
**For the `(Map)` function:**
```MD
Map(k, v) /* k: file name, v: file content */
    split v into words
    for each word w in words:
        emit (w, 1)
```
**For the `(Reduce)` function:**
```MD
Reduce(k, v) /* k: word, v: count */
    emit(len(v))
```