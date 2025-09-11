# Java

Java low-level function.

## Basic points I may have forgotten
1. `default` and `protected` in Java  

Their similarity is that both are accessible to any class within the same package.
The key difference is how they treat subclasses in different packages. 

`default` members are not accessible to subclasses in different packages, while `protected` members are.

2. 成员变量存储在类中（堆），局部变量存储在栈中。

3. `switch` 可用在：
   1. String
   2. int
   3. enum

4. Java只有值传递，没有引用传递。
   传递`class`时，实际上是传递了一个引用的副本。  
   `==` 比较的是引用地址，`equals()` 比较的是内容。

5. `Object` 以及方法
   1. `equals()`: default compares memory address
   2. `hashCode()`: default returns memory address as int
   3. `toString()`
   4. `clone()`
   5. `finalize()`

6. 重写 `equals()` 时，必须重写 `hashCode()`:  
`HashMap()` 比较逻辑：先比较`hashCode()` - 地址，再比较`equals()`。

7. `try` 中含有return时，`finally` 仍然会执行。
8. `transient` 关键字：阻止变量被序列化。
9. 反射运行时对类进行改动:
   1. 获取类的字节码：`Class.forName("className")`
   2. 创建对象：`Class.newInstance()`
   3. 获取构造函数：`Class.getConstructor()`
   4. 获取成员变量：`Class.getField()`
   5. 获取成员方法：`Class.getMethod()`
   6. 获取父类：`Class.getSuperclass()`
   7. 获取包信息：`Class.getPackage()`
   8. 获取类加载器：`Class.getClassLoader()`
   9. 获取注解：`Class.getAnnotation()`

10. 动态代理：在运行时动态生成代理类，实现对目标类的功能增强。
    1. 创建接口
    2. 创建实现类
    3. 创建处理器类，实现`InvocationHandler`接口
    4. 使用`Proxy.newProxyInstance()`创建代理对象

## design pattern
1. 适配器模式：将一个接口转换为另一个接口，从而实现接口兼容。



## Java GC:

1. Tag-and-Sweep  
| create memory fragment
   - Mark objects that are reachable
   - Sweep unmarked objects


2. Tag-and-Compact  
| time complexity high
   - Mark reachable objectss
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

