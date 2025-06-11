### Spring中的get方法
| 方法定义 | 返回值与参数 |
| --- | --- |
| `Object getBean(String name)` | 返回指定名称的bean实例，需要强制转换 |
| `T getBean(Class Type)` | 返回指定类型的bean实例（需要类型唯一） |
| `T getBean(String name, Class type) ` | 返回指定名称和类型的bean实例 |

```Java
UserService userService = (UserService) context.getBean("userService");
UserService userService = context.getBean(UserService.class);
UserService userService = context.getBean("userService", UserService.class);
``` 

### 配置非自定义的bean（第三方jar包）
```xml
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.32</version>
</dependency>
<bean id="dataSource" class="com.mysql.cj.jdbc.Driver">
    <property name="url" value="jdbc:mysql://localhost:3306/test"/>
    <property name="username" value="root"/>
    <property name="password" value="123456"/>
</bean>
```
```Java
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import javax.sql.DataSource;
public class Main {
    public static void main(String[] args) {
        ApplicationContext context = new ClassPathXmlApplicationContext("applicationContext.xml");
        DataSource dataSource = context.getBean(DataSource.class);
        System.out.println(dataSource);
    }
}
```

### 例子
配置sql链接：
```xml
<!-- 配置mysql链接 -->
<bean id="connectionDriver" class="com.mysql.cj.jdbc.Driver" factory-method="forName">
    <constructor-arg value="com.mysql.cj.jdbc.Driver"/>
</bean>
<bean id="connection" class="java.sql.Connection" factory-bean="dataSource" factory-method="getConnection">
    <property name="url" value="jdbc:mysql://localhost:3306/test"/>
    <property name="username" value="root"/>
    <property name="password" value="123456"/>
</bean>
```
其对应的Java代码如下：
```Java
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
public class Main {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection connection = DriverManager.getConnection("jdbc:mysql://localhost:3306/test", "root", "123456");
            System.out.println(connection);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
        }
    }
}
```
---
配置日期：
```xml
<!-- 配置日期 -->
<bean id="simpleDateFormat" class="java.text.SimpleDateFormat">
    <constructor-arg value="yyyy-MM-dd HH:mm:ss"/>
</bean>
```
其对应的Java代码如下：
```Java
SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
Date date = simpleDateFormat.parse("2023-10-01 12:00:00");
```
---
配置mybatis：
```xml
<bean id="inputStream" class="org.mybatis.spring.SqlSessionFactoryBean" factory-method="getResourceAsStream">
    <constructor-arg value="mybatis-config.xml"/>
</bean>
<bean id="builder" class="org.apache.ibatis.session.SqlSessionFactoryBuilder" factory-method="newInstance"/>
<bean id="sqlSessionFactory" class="org.mybatis.spring.SqlSessionFactoryBean" factory-bean="builder" factory-method="build">
    <constructor-arg ref="inputStream"/>
</bean>
<bean id="sqlSession" class="org.mybatis.spring.SqlSessionTemplate" factory-bean="sqlSessionFactory" factory-method="openSession"/>
```
其对应的Java代码如下：
```Java
// 静态工厂方法
InputStream inputStream = Resources.getResourceAsStream("mybatis-config.xml");
// 无参构造实例化
SqlSessionFactoryBuilder builder = new SqlSessionFactoryBuilder();
// 实例工厂方法
SqlSessionFactory sqlSessionFactory = builder.build(inputStream);
SqlSession sqlSession = sqlSessionFactory.openSession();
```

## Bean 实例化的基本流程
-> Core：实例化对象并注入属性，存储到spring容器中


1. Spring容器启动时，读取配置文件，解析bean定义，封装成`BeanDefinition`对象。
   - `BeanDefinition`包含bean的类名、作用域（单例或原型）、构造参数、属性等信息。
2. 根据bean定义，使用反射创建bean实例。
   - 如果是单例模式，直接创建并存储在容器中。
   - 如果是原型模式，每次请求都会创建新的实例。
3. 对bean实例进行依赖注入，设置属性值。
4. 如果bean实现了`InitializingBean`接口，调用`afterPropertiesSet()`方法。
5. 如果配置了`init-method`，调用指定的初始化方法。
6. 如果bean实现了`DisposableBean`接口，调用`destroy()`方法。
