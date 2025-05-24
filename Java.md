# Java

| No grammar, just some key points

## Java GC:

1. Tag-and-Sweep  
| create memory fragment
   - Mark objects that are reachable
   - Sweep unmarked objects


2. Tag-and-Compact  
| time complexity high
   - Mark reachable objects
   - Compact memory by moving objects together


3. Copying  
| fast, but requires double memory
   - Divide memory into two halves
   - Copy live objects from one half to the other
   - Swap roles of the halves

4. Generational  
| divide memory into generations
![Generational GC](./Images/Java%20GC.png)
   - Young Generation: short-lived objects
   - Old Generation: long-lived objects
   - Minor GC for Young Generation, Major GC for Old Generation

5. G1 garbage collector
| designed for large heaps
   - Divides heap into regions
   - Prioritizes collection of regions with most garbage
   - Concurrent and parallel phases

## Java Memory Model
![video](https://www.bilibili.com/video/BV12t411u726)
![Java Memory Model](./Images/Java%20Memory%20Model.png)

