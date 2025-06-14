## 基于注解的Spring配置

```XML
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xmlns:context="http://www.springframework.org/schema/context"
       xsi:schemaLocation="
       http://www.springframework.org/schema/beans
       http://www.springframework.org/schema/beans/spring-beans.xsd
       http://www.springframework.org/schema/context
       http://www.springframework.org/schema/context/spring-context.xsd
       ">
    <!-- 注解组件扫描：扫描指定包及其子包 -->
    <context:component-scan base-package="com.pphui8" />
</beans>
```

```java
// <bean id="userDao" class="com.pphui8.spring.dao.impl.UserDaoImpl/>
// “userDao”可以省略，Spring会自动生成一个唯一的ID，为类名首字母小写
@Component("userDao")
public class UserDaoImpl implements UserDao {

}
```

### 使用注解代替XML配置

| xml配置 | 注解配置 | 描述 |
| --- | --- | --- |
| `<bean scope="singleton" />` | `@Scope` | 单例/多例 |
| `<bean lazy-init="" />` | `@Lazy` | 延迟加载 |
| `<bean init-method="" />` | `@PostConstruct` | 初始化方法 |
| 注解在方法上： | ============= | ======= |
| `<bean destroy-method="" />` | `@PreDestroy` | 销毁方法 |
| `<property name="" value="" />` | `@Value` | 属性注入 |

### 衍生注解

| 注解 | 描述 |
| --- | --- |
| `@Repository` | 标记数据访问层组件(DAO层) |
| `@Service` | 标记业务逻辑层组件(Service层) |
| `@Controller` | 标记控制器组件(Web层) |
| `@Component` | 标记通用组件(可用于任何层) |

## Bean依赖注入注解开发

| 注解 | 描述 |
| --- | --- |
| `@Value` | 注入简单类型属性 |
| `@Autowired` | 自动装配依赖，根据类型注入引用数据 |
| `@Qualifier` | 指定注入的Bean名称 |
| `@Resource` | JSR-250标准注解，自动装配Bean（类型或名称）|

### @Value
```txt
// 配置文件 "application.properties" 中的属性
app.name=MySpringApp
```
```XML
 <context:property-placeholder location="classpath:application.properties" />
```

```java
// 注入简单类型属性
@Value("Hello, Spring!")
private String greeting;

// 注入配置文件中的属性
@Value("${app.name}")
private String appName;

// 注入数组或集合
@Value("${app.servers}")
private String[] servers;

// 注入默认值
@Value("${app.timeout:5000}") // 如果未配置，则使用默认值5000
private int timeout;
```

### @Autowired
```java
@Autowired
private UserDao userDao; // 根据类型自动装配UserDao

// 根据名称注入
@Autowired @Qualifier("userDao")    // 需要一起使用@Qualifier指定Bean名称
private UserDao userDao; // 使用@Qualifier指定Bean名称

@Autowired  // 根据方法参数匹配，用得较少
public void setUserDao(UserDao userDao) {
    this.userDao = userDao; // 通过setter方法注入
}

@Autowired  // 找所有UserDao类型的Bean
public void init(List<UserDao> userDaos) {
    this.userDaos = userDaos; // 注入List类型的依赖
}
```

### 非自定义Bean的注解开发
非自定义Bean需要使用工厂方法创建，通常使用`@Bean`注解。

```java
// 需要Component注解来标注为可以被扫描到的类
@Component
public class OtherBean {
    // 默认name为方法名首字母小写
    @Bean
    // @Bean("dataSource") or @Bean(name = "dataSource")
    public DataSource dataSource() {
        DruidDataSource dataSource = new DruidDataSource();
        // 设置基本参数
        return dataSource;
    }

    @Bean
    public Jdbc jdbc(@Value("${jdbc.url}") String url,
                     @Value("${jdbc.username}") String username,
                     @Value("${jdbc.password}") String password) {
        DruidDataSource dataSource = new DruidDataSource();
        return new JdbcTemplate(dataSource);
    }
}


### 完全替代XML配置的方式
主要是将Context等相关的配置都放在Java类中。

```java
// com.pphui8/config/SpringConfig.java
@Configuration
// <context:component-scan base-package="pphui8.spring" />
// @ComponentScan(value = "pphui8.spring")
@ComponentScan("pphui8.spring")
// <context:property-placeholder location="application.properties" />
// @PropertySource(value = "classpath:application.properties")
// 可以一次引入多个配置文件
@PropertySource("classpath:application.properties")
// import其他配置类
@Import({OtherBean.class, AnotherConfig.class})
public class SpringConfig {
}
```
```java
// AnnotationConfigApplicationTest
public static void main(String[] args) {
    // 创建应用上下文
    ApplicationContext context = new AnnotationConfigApplicationContext(SpringConfig.class);
    UserService userService = context.getBean(UserService.class);
}
```

### 其他注解
| 注解 | 描述 |
| --- | --- |
| `@Primary` | 相同类型的Bean优先引入，与@Component和@Bean一起使用 |
| `@Profile` | 指定Bean的激活环境，通常用于区分开发、测试、生产环境 |


### Spring注解解析原理
Spring注解解析的核心在于`BeanDefinition`的注册和处理。Spring通过反射机制扫描类上的注解，并将其转换为`BeanDefinition`对象，存储在`ApplicationContext`中。
#### 注解解析流程
1. **类扫描**：使用`@ComponentScan`注解指定的包路径，Spring会扫描该路径下的所有类。
2. **注解处理**：对于每个类，Spring会检查是否有`@Component`、`@Service`、`@Repository`、`@Controller`等注解。
3. **BeanDefinition注册**：如果类上有这些注解，Spring会创建一个`BeanDefinition`对象，并将其注册到`ApplicationContext`中。
4. **依赖注入**：在创建Bean实例时，Spring会根据`@Autowired`、`@Value`等注解进行依赖注入。（在BeanPostProcessor中处理）

#### 组件扫描原理
组件扫描是通过`ClassPathBeanDefinitionScanner`类实现的。它会扫描指定包路径下的所有类，并根据注解生成`BeanDefinition`。

### 注解方式注入第三方框架
以MyBatis为例，使用`@MapperScan`注解来扫描Mapper接口。

```java
@Configuration
@ComponentScan("com.pphui8.spring")
@PropertySource("classpath:application.properties")
// MapperScan注解用于扫描MyBatis的Mapper接口
@MapperScan("com.pphui8.spring.mapper")
public class MyBatisConfig {
    @Bean
    public DataSource dataSource(
        @Value("${jdbc.driver}") String driver,
        @Value("${jdbc.url}") String url,
        @Value("${jdbc.username}") String username,
        @Value("${jdbc.password}") String password
    ) {
        DruidDataSource dataSource = new DruidDataSource();
        dataSource.setDriverClassName(driver);
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }

    @Bean
    public SqlSessionFactoryBean sqlSessionFactoryBean(DataSource dataSource) throws Exception {
        SqlSessionFactoryBean factoryBean = new SqlSessionFactoryBean();
        factoryBean.setDataSource(dataSource);
        // 设置MyBatis配置文件路径
        factoryBean.setConfigLocation(new ClassPathResource("mybatis-config.xml"));
        return factoryBean;
    }
```