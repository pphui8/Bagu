## 事务控制
Core：确保一组操作（通常是数据库操作）要么全部成功，要么全部失败，从而保证数据的完整性和一致性。这在多用户、高并发的应用程序中至关重要。

- 想象一个银行转账的场景：A账户向B账户转账100元。这个操作包含两个步骤：  
    1. 从A账户扣除100元。  
    2. 向B账户增加100元。  

如果没有事务控制，如果在第一步成功后，第二步执行前系统崩溃，那么A账户的钱少了，而B账户的钱没有增加，导致数据不一致。事务控制可以防止这种情况的发生。

### 相关对象
`PlatformTransactionManager` 是 Spring 提供的事务管理器接口，通常用于管理数据库事务。

| 对象 | 说明 |
| ---- | ---- |
| `TransactionStatus` | 事务状态 |
| `commit` | 提交事务 |
| `rollback` | 回滚事务 |

`PlatformTransactionManager` 方法：
| 方法 | 说明 |
| ---- | ---- |
| `getIsolationLevel()` | 获取事务隔离级别 |
| `getPropagationBehavior()` | 获取事务传播行为 |
| `getTimeout()` | 获取事务超时时间 |
| `isReadOnly()` | 判断事务是否为只读 |

#### 事务隔离级别
| 隔离级别 | 描述 |
| ------- | ---- |
| `ISOLATION_DEFAULT` | 使用数据库默认的隔离级别 |
| `ISOLATION_READ_UNCOMMITTED` | 允许读取未提交的数据 |
| `ISOLATION_READ_COMMITTED` | 只允许读取已提交的数据 |
| `ISOLATION_REPEATABLE_READ` | 保证在同一事务中多次读取同一数据时结果一致 |
| `ISOLATION_SERIALIZABLE` | 最严格的隔离级别，完全隔离 |
| `ISOLATION_NONE` | 不使用事务 |


#### 事务传播行为
| 传播行为 | 描述 |
| ---------- | ---- |
| `PROPAGATION_REQUIRED` | 如果存在事务，则加入该事务；如果不存在事务，则创建一个新的事务（一般使用这个） |
| `PROPAGATION_SUPPORTS` | 如果存在事务，则加入该事务；如果不存在
事务，则以非事务方式执行 |
| `PROPAGATION_MANDATORY` | 如果存在事务，则加入该事务；如果不存在事务，则抛出异常 |
| `PROPAGATION_REQUIRES_NEW` | 创建一个新的事务，并挂起当前事务（如果存在） |
| `PROPAGATION_NOT_SUPPORTED` | 以非事务方式执行，并挂起当前事务（如果存在） |
| `PROPAGATION_NEVER` | 以非事务方式执行，如果存在事务则抛出异常 |
| `PROPAGATION_NESTED` | 如果存在事务，则在当前事务中执行；如果不存在事务，则创建一个新的事务 |
| `PROPAGATION_ISOLATED` | 创建一个新的事务，并隔离当前事务（如果存在） |

#### `TransactionStatus` 接口
`TransactionStatus` 接口用于表示事务的状态，提供了以下方法：
| 方法 | 描述 |
| ---- | ---- |
| `hasSavepoint()` | 判断事务是否有保存点 |
| `usComplete()` | 判断事务是否已完成 |
| `isNewTransaction()` | 判断事务是否是新事务 |
| `isRollbackOnly()` | 判断事务是否只能回滚 |


### 基于XML的事务配置
```xml
<beans xmlns="http://www.springframework.org/schema/beans"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xmlns:tx="http://www.springframework.org/schema/tx"
         xsi:schemaLocation="
              http://www.springframework.org/schema/beans
              http://www.springframework.org/schema/beans/spring-beans.xsd
              http://www.springframework.org/schema/tx
              http://www.springframework.org/schema/tx/spring-tx.xsd">
    
     <bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">
          <property name="dataSource" ref="dataSource"/>
     </bean>
    
     <tx:advice id="txAdvice" transaction-manager="transactionManager">
          <tx:attributes>
                <tx:method name="*" propagation="REQUIRED"/>
          </tx:attributes>
     </tx:advice>
    
     <aop:config>
          <aop:pointcut id="serviceMethods" expression="execution(* com.example.service.*.*(..))"/>
          <aop:advisor advice-ref="txAdvice" pointcut-ref="serviceMethods"/>
     </aop:config>
</beans>
```

### 基于注解的事务配置
```java
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.transaction.annotation.TransactionManagementConfigurer;
@Configuration
@EnableTransactionManagement
public class TransactionConfig implements TransactionManagementConfigurer {

    @Bean
    public PlatformTransactionManager transactionManager() {
        // 返回具体的事务管理器实现，例如 DataSourceTransactionManager
        return new DataSourceTransactionManager(dataSource());
    }

    @Override
    public PlatformTransactionManager annotationDrivenTransactionManager() {
        return transactionManager();
    }
}
```