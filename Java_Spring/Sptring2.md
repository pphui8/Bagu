## 工厂后处理器 (Factory Post Processor)
Spring 提供了一个工厂后处理器接口 `BeanFactoryPostProcessor`，允许开发者在 Spring 容器实例化任何 bean 之前修改应用上下文的内部属性。
### 1. BeanFactoryPostProcessor 接口
在BeanDefinitionMap填充完毕，Bean实例化之前执行

![bean post processor](./Images/bean%20post%20factory.png)

```Java
public interface BeanFactoryPostProcessor {
    void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException;
}

public class MyBeanFactoryPostProcessor implements BeanFactoryPostProcessor {
    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        // 例如：修改名为 "dataSource" 的 Bean 的属性
        BeanDefinition beanDefinition = beanFactory.getBeanDefinition("dataSource");
        // 修改属性值，比如将数据库URL改为测试环境
        beanDefinition.getPropertyValues().add("url", "jdbc:mysql://localhost:3306/testdb");
        System.out.println("BeanFactoryPostProcessor: 修改了 dataSource 的 url 属性");
    }
}
```




#### 使用示例
使用BeanFactoryPostProcessor扩展点完成自定义注解扫描

1. 自定义@MyComponent注解
2. 使用第三方包扫描器工具BaseClassScanUtil扫描包下的类
3. 自定义BeanFactoryPostProcessor实现类，获取到扫描到的类，注册到Spring容器中

```Java
// 自定义注解 MyComponent
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
public @interface MyComponent {
    String value() default ""; // Bean 名称
}
```

```Java
// 使用第三方包扫描工具 BaseClassScanUtil
@MyComponent("myService")
public class MyServiceImpl implements MyService {
    public void doSomething() {
        System.out.println("MyService is doing something!");
    }
}
```

```Java
public class MyComponentScanner implements BeanDefinitionRegistryPostProcessor {
    @Override
    public void postProcessBeanDefinitionRegistry(BeanDefinitionRegistry registry) throws BeansException {
        // 使用 BaseClassScanUtil 扫描包下的类
        Set<Class<?>> classes = BaseClassScanUtil.scanPackage("com.example.myapp");
        for (Class<?> clazz : classes) {
            if (clazz.isAnnotationPresent(MyComponent.class)) {
                MyComponent annotation = clazz.getAnnotation(MyComponent.class);
                String beanName = annotation.value();
                BeanDefinition beanDefinition = BeanDefinitionBuilder.genericBeanDefinition(clazz).getBeanDefinition();
                registry.registerBeanDefinition(beanName, beanDefinition);
                System.out.println("注册 Bean: " + beanName + " -> " + clazz.getName());
            }
        }
    }

    @Override
    public void postProcessBeanFactory(ConfigurableListableBeanFactory beanFactory) throws BeansException {
        // 不需要实现
    }
}
```

```XML
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean class="com.example.myapp.MyComponentScanner" />
```

## BeanPostProcessor 接口
在Bean实例化之后，填充到单例池(singletonObjects)之前执行  
BeanPostProcessor 允许开发者在 Bean 实例化之后、初始化之前对 Bean 进行修改或增强。它主要用于实现 AOP（面向切面编程）等功能。  

| 方法 | 描述 |
| ---- | ---- |
| FactoryPostProcessor | 在 BeanFactory 实例化之后执行，主要对Bean **定义** 进行操作 |
| BeanPostProcessor | 在 Bean 实例化之后执行，主要对Bean **对象** 进行操作 |

```Java
public interface BeanPostProcessor {
    Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException;
    Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException;
}

public class MyBeanPostProcessor implements BeanPostProcessor {
    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        // 在 Bean 初始化之前执行
        System.out.println("BeanPostProcessor: 在 " + beanName + " 初始化之前执行");
        return bean; // 返回原始或修改后的 Bean
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        // 在 Bean 初始化之后执行
        System.out.println("BeanPostProcessor: 在 " + beanName + " 初始化之后执行");
        return bean; // 返回原始或修改后的 Bean
    }
}
```

### 使用示例
使用BeanPostProcessor扩展点进行日志增强
```Java
public class LoggingBeanPostProcessor implements BeanPostProcessor {
    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        // 使用动态代理或其他方式增强 Bean 的日志功能
        Proxy proxy = Proxy.newProxyInstance(
            bean.getClass().getClassLoader(),
            bean.getClass().getInterfaces(),
            (proxyInstance, method, args) -> {
                System.out.println("调用方法: " + new Date() + " - " + method.getName());
                Object result = method.invoke(bean, args);
                System.out.println("方法调用结束: " + new Date() + " - " + method.getName());
                return result;
            }
        );
        
        return bean;
    }
}
```

```XML
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean class="com.example.myapp.LoggingBeanPostProcessor" />
```

## Spring Bean 生命周期
Spring Bean 的生命周期包括多个阶段，从 Bean 的创建到销毁。以下是 Spring Bean 生命周期的主要步骤：

- Overall:

| 阶段编号 | 生命周期阶段描述 | 相关接口/方法 |
|---------|----------------|--------------|
| Bean实例化阶段 | Spring取出配置文件或注解定义的 Bean 信息，使用反射创建 Bean 实例 | 构造方法 |
| Bean初始化阶段 | 对半成品的 Bean 进行属性填充和依赖注入 | `setXxx` 方法、依赖注入 |
| Bean完成阶段 | Bean 完成初始化并存储到单例池，准备就绪供应用程序使用 | `postProcessBeforeInitialization`、`postProcessAfterInitialization` |


- Detailed:

| 阶段编号 | 生命周期阶段描述 | 相关接口/方法 |
|---------|----------------|--------------|
| 1 | 实例化：Spring 使用反射创建 Bean 的实例 | 构造方法 |
| 2 | 填充属性：Spring 将配置文件或注解中定义的属性值注入到 Bean 中 | setXxx 方法、依赖注入 |
| 3 | 调用 BeanNameAware 接口：将 Bean 的名称传递给它 | `setBeanName` (BeanNameAware) |
| 4 | 调用 BeanFactoryAware 接口：将 BeanFactory 引用传递给它 | `setBeanFactory` (BeanFactoryAware) |
| 5 | 调用 ApplicationContextAware 接口：将 ApplicationContext 引用传递给它 | `setApplicationContext` (ApplicationContextAware) |
| 6 | 调用 BeanPostProcessor 的 postProcessBeforeInitialization 方法 | `postProcessBeforeInitialization` |
|=============|==================|==================|
| 7 | 调用 InitializingBean 的 afterPropertiesSet 方法 | `afterPropertiesSet` (InitializingBean) |
| 8 | 调用自定义 init-method 方法 | `init-method` |
| 9 | 调用 BeanPostProcessor 的 postProcessAfterInitialization 方法 | `postProcessAfterInitialization` |
| 10 | Bean 准备就绪：Bean 已经可以被应用程序使用 | - |
|==============|===================|==================|
| 11 | 销毁：调用销毁方法销毁 Bean | `destroy` (DisposableBean) / `destroy-method` |


## 循环依赖问题
在 Spring 中，循环依赖是指两个或多个 Bean 互相依赖，形成一个闭环。这种情况会导致 Bean 无法正确创建和注入。

```XML
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans
                           http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="userService" class="com.example.UserService">
        <property name="userRepository" ref="userRepository"/>
    </bean>
    <bean id="userDao" class="com.example.UserDao">
        <property name="userService" ref="userService"/>
    </bean>
```

![infuse loop](./Images/infuse%20loop.png)
Problem: UserService 依赖 UserDao，UserDao 又依赖 UserService，形成循环依赖， 而容器中的 UserService 和 UserDao 都没有创建完成，导致无法注入。

### 三级缓存解决循环依赖
Core：**完整实例** 存到一个地方，**半成品实例** 存到另一个地方

```Java
public class DefaultSingletonBeanRegistry {
    // 完整实例，即单例池，一级缓存
    private final Map<String, Object> singletonObjects = new ConcurrentHashMap(256);
    // 半成品实例，且当前对象已经被其它对象引用，二级缓存
    private final Map<String, Object> earlySingletonObjects = new ConcurrentHashMap(16);
    // 单例工厂，三级缓存，且当前对象未被其它对象引用，可以被创建，三级缓存
    private final Map<String, ObjectFactory<?>> singletonFactories = new ConcurrentHashMap(16);
}
```

1. **一级缓存**：存储完整的 Bean 实例，只有在 Bean 完全创建完成后才会放入。
2. **二级缓存**：存储半成品的 Bean 实例，当 Bean 正在创建过程中，如果被其他 Bean 依赖，则将其放入二级缓存。
3. **三级缓存**：存储 Bean 的工厂方法，用于创建 Bean 的半成品实例。

### 解决循环依赖的步骤
1. **创建 Bean 实例**：当 Spring 容器需要创建一个 Bean 时，首先会检查一级缓存，如果不存在，则创建一个新的 Bean 实例。
2. **放入二级缓存**：在 Bean 实例化过程中，如果遇到依赖注入的情况，Spring 会将当前 Bean 的半成品实例放入二级缓存。
3. **依赖注入**：当其他 Bean 需要依赖这个半成品实例时，Spring 会从二级缓存中获取。
4. **完成 Bean 实例化**：当所有依赖都注入完成后，Spring 会将完整的 Bean 实例放入一级缓存，并从二级缓存中移除半成品实例。