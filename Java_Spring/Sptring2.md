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


### 2. BeanPostProcessor 接口
在Bean实例化之后，填充到单例池(singletonObjects)之前执行
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

## 后处理器 (Post Processor)
在 Spring 中，后处理器是指在 Bean 实例化之后、填充属性之前或之后执行的一些处理逻辑。它们可以用于修改 Bean 的属性、执行额外的逻辑等。