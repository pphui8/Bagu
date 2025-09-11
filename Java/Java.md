# Java

Java low-level function.

## Basic points I may have forgotten
1. `default` and `protected` in Java  

Their similarity is that both are accessible to any class within the same package.
The key difference is how they treat subclasses in different packages. 

`default` members are not accessible to subclasses in different packages, while `protected` members are.

2. 成员变量存储在类中（堆），局部变量存储在栈中。

3. `switch` 可用在：
   - byte, char, short, int, String, enum
   - 不可用在：long, float, double, boolean

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

11. 当创建一个子类对象时，如果子类构造函数没有显式调用父类构造函数，Java 会在子类构造函数的第一行隐式调用父类的无参构造函数。

12. Java 的自动初始化
   1. 成员变量(static, final, 数组的元素)：默认初始化为零值（数值类型为0，布尔类型为false，引用类型为null）。
   2. 局部变量：必须显式初始化，否则编译错误。


13. 静态代码块(static block)在类加载时执行一次，用于初始化静态变量或执行只需运行一次的代码。
   - 静态变量初始化：static int x;，x 默认初始化为 0。
   - 第一个 static 块：x += 1;，此时 x = 1。
   - 第二个 static 块：x += 2;，此时 x = 3。
   - main 方法执行：
   - Test s = new Test(); 调用构造方法，x++，x = 4。
   - s = new Test(); 再次调用构造方法，x++，x = 5。
   - 输出：System.out.println(s.x); 输出 5。

```java
public class Test{
  static int x;
  static{
   x+=1; 
  } 
  static{
   x+=2; 
  }
  Test(){
    x++;
  }
  public static void main(String args[]){
    Test s=new Test();
    s=new Test();
    System.out.println(s.x);
  }
}
```

12. static 不能修饰局部变量。Java 语法规定：static 只能出现在字段声明或静态初始化块里。

12. 变量隐藏
- 成员变量的访问只看引用的编译类型，不看对象的实际类型。
- 子类如果声明了同名变量，会隐藏父类的变量，但不会覆盖。
- 构造方法先执行父类，再执行子类。

```java
class Base{ 
  int var;
  public Base(){
    var=4;
  } 
} 

public class Test extends Base{ 
  int var;
  public Test(){
    var++;
  }
  public static void main(String args[]){ 
    Base b=new Test();
    System.out.println(b.var);
  } 
} 
```

- ase类有一个int var字段，并在Base的构造方法中赋值为4。
- 
- est类也声明了一个int var字段，这会隐藏（不是覆盖）父类的var字段。Test的var和Base的var是- 两个不同的变量。
- 
- 当你执行new Test()时，构造方法的调用顺序是：
- 
- 先调用Base的构造方法（把Base的var赋值为4）
- 再调用Test的构造方法（Test的var自增，但它默认初始值是0，所以变成1）
- 在main方法中，Base b = new Test();，此时b的编译类型是Base，运行时类型是Test，但成员变量- 的访问只看编译类型，即访问的是Base的var字段。
- 
- 所以System.out.println(b.var);打印的是Base类的var字段的值，即4。

13. 另一个编译器只认“引用类型”，不认你实际堆里的对象是什么的例子：
- 1. sub2 = base; 
- 2. sub1 = (Sub1) base; （左右都转为了sub1，绕开了编译器检查）  

其中1. 在编译时会报错，2. 在运行时会报错。

14. Java 的 java.util.Set 集合允许存放Java 对象，但不能直接存放基本类型的数据，不过可以通过Java 的自动装箱（Autoboxing）机制将基本类型数据转化为对应的包装类对象来存放，从而达到“存放基本类型”的效果。

15. 接口可以 `extends`，而且只能 extends，不能 implements。

16. 对象创建顺序
   - 父类静态变量、静态代码块（按出现顺序）
   - 子类静态变量、静态代码块（按出现顺序）
   - 父类实例变量、实例代码块（按出现顺序）
   - 父类构造器
   - 子类实例变量、实例代码块（按出现顺序）
   - 子类构造器

17. `float f=11.3;` 不合法，需要强制转换为 `double`;

18. `final` 变量必须在声明时或构造器中初始化。


## design pattern
1. 适配器模式：将一个接口转换为另一个接口，从而实现接口兼容。



