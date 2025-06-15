## SpringAOP
JavaAOP （Aspect Oriented Programming）是面向切面编程的缩写，是一种编程范式，它通过将关注点分离来提高代码的模块化。Spring AOP 是 Spring 框架的一部分，提供了对 AOP 的支持。

OOP是纵向对一个事物的抽象，一个对象的属性和方法。AOP是横向对一个事物的抽象，多个对象的公共行为。

实现：Proxy（代理）模式，增强Java方法的功能。(动态代理)

### AOP思想的实现
```Java
// A obj
public class A {
    method1();
    method2();
    method3();
}

// B obj
public class B {
    method1();
    method2();
}

// enhaved A with B`s methods
public class ProxyA {
    Obj_B_method1()
    Obj_A_method1()
    Obj_B_method2()
}
public class ProxyB {
    Obj_A_method1()
    Obj_B_method2()
    Obj_A_method2()
}
```

### 具体实现
1. 使用BeanPostProcessor接口实现Bean的后处理器。
2. 在BeanPostProcessor的postProcessAfterInitialization方法中，对需要增强的Bean进行代理。
3. 使用ApplicationContextAware接口获取ApplicationContext，以便获取Advice对象。
4. 在UserServiceImpl中直接注入Advice对象，并在Invoke前后执行Advice的方法。

```Java
public class MockAOPBeanPostProcessor implements BeanPostProcessor, ApplicationContextAware {
    private ApplicationContext applicationContext;

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        // 对UserService中的show1和show2方法，使用Advice中的beforeAdvice和afterAdvice进行增强
        // 对userService中的所有对象进行增强
        if(bean instanceof UserServiceImpl) {
            // 执行增强对象的before方法
            // 执行增强对象的方法
            return Proxy.newProxyInstance(
                    bean.getClass().getClassLoader(),
                    bean.getClass().getInterfaces(),
                    (proxy, method, args) -> {
                        // 执行增强对象的before方法
                        Advice myAdvice = applicationContext.getBean(Advice.class);
                        myAdvice.beforeAdvice();
                        // 执行增强对象的方法
                        Object result = method.invoke(bean, args);
                        // 执行
                        myAdvice.afterAdvice();
                        return result;
                    }
            );
        }
        // 如果无需增强
        return bean;
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }
}
```

### Spring AOP的实现
Spring AOP 使用动态代理来实现切面编程。它可以在运行时创建一个代理对象，该对象可以拦截方法调用并在调用前后执行额外的逻辑。

| 概念 | 关键字 | 描述 |
| ---- | ------ | ---- |
| 目标对象 | target | 被代理的对象，通常是一个业务类 |
| 代理对象 | proxy | 代理目标对象的对象，拦截方法调用并执行额外逻辑 |
| 连接点 | join point | 程序执行的某个点，例如方法调用 |
| 切点 | pointcut | 定义在哪些连接点上应用切面，通常是方法执行 |
| 通知 | advice | 在切点处执行的代码，分为前置通知、后置通知、异常通知等 |
| 切面 | aspect | 由切点和通知组成的模块，定义了在哪些连接点上应用哪些通知 |
| 引入 | introduction | 向目标对象添加新的方法或属性 |
| 织入 | weaving | 将切面应用到目标对象的过程，可以在编译时、类加载时或运行时进行 |

![Spring AOP](./Images/AOP.jpeg)