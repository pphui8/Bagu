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
@Component("userDao")
public class UserDaoImpl implements UserDao {

}
```

