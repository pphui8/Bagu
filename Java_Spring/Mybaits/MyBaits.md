# MyBatis
MyBatis 是一个广受欢迎的持久层（Persistence Layer）框架，它专注于解决Java应用程序与数据库之间的交互问题。你可以把它理解为 Java 代码和 SQL 语句之间一个功能强大的“中间人”。

核心思想：将 SQL 语句从程序代码中彻底分离出来，存放在独立的 XML 文件或注解中，使得 SQL 的管理和优化变得更加容易。

灵活且强大的动态SQL是 MyBatis 最具吸引力的特性之一。它允许你在 XML 中使用 if, choose (类似 a switch 语句), foreach 等标签来根据不同条件动态地拼接 SQL 语句。这对于构建复杂的查询非常有用。

示例：根据用户是否输入了姓名来动态查询

```XML
<select id="findUser" resultType="User">
  SELECT * FROM user WHERE state = 'ACTIVE'
  <if test="name != null">
    AND name LIKE #{name}
  </if>
</select>
```

### MyBatis 的工作原理
MyBatis 的工作原理可以分为以下几个步骤：
1. **配置文件加载**：MyBatis 首先加载配置文件（通常是 `mybatis-config.xml`），该文件包含了数据库连接信息、映射器（Mapper）的位置等。
2. **创建 SqlSessionFactory**：根据配置文件创建 `SqlSessionFactory`，这是 MyBatis 的核心工厂类，用于创建 `SqlSession` 实例。
3. **创建 SqlSession**：通过 `SqlSessionFactory` 创建 `SqlSession`，这是 MyBatis 与数据库交互的主要接口。
4. **执行 SQL 语句**：使用 `SqlSession` 调用映射器方法，这些方法会根据 XML 或注解中的 SQL 语句执行相应的数据库操作。

### 配置文件
```xml
<configuration>
<!-- 数据库环境 -->
  <environments default="development">
    <environment id="development">
      <transactionManager type="JDBC"/>
      <dataSource type="POOLED">
        <property name="driver" value="com.mysql.cj.jdbc.Driver"/>
        <property name="url" value="jdbc:mysql://localhost:3306/mydb"/>
        <property name="username" value="root"/>
        <property name="password" value="password"/>
      </dataSource>
    </environment>
  </environments>
<!-- 引入映射文件 -->
  <mappers>
    <mapper resource="com/example/mapper/UserMapper.xml"/>
  </mappers>
</configuration>
```

### Mapper接口 (MyBaits映射文件)
mapper接口相当于Java代码中的数据访问层(DAO)，它定义了与数据库交互的方法。每个方法通常对应一个 SQL 语句。

ORM（对象关系映射）是 MyBatis 的核心功能之一，它允许你将数据库中的表映射到 Java 对象。通过使用注解或 XML 文件，你可以定义如何将 SQL 查询结果转换为 Java 对象。


```xml
<mapper namespace="com.example.mapper.UserMapper">
  <select id="findById" resultType="User">
    SELECT * FROM user WHERE id = #{id}
  </select>

  <insert id="insertUser">
    INSERT INTO user(name, age) VALUES(#{name}, #{age})
  </insert>

  <update id="updateUser">
    UPDATE user SET name = #{name}, age = #{age} WHERE id = #{id}
  </update>

  <delete id="deleteUser">
    DELETE FROM user WHERE id = #{id}
  </delete>
</mapper>
```
或者直接使用注解方式定义 Mapper 接口方法：
```java
public interface UserMapper {
    @Select("SELECT * FROM user WHERE id = #{id}", resultType = User.class)
    // 使用 @Results 注解可以指定结果映射
    // @Results({
    //     @Result(property = "id", column = "id"),
    //     @Result(property = "name", column = "name"),
    //     @Result(property = "age", column = "age")
    // })
    // 如果需要使用 MapKey 注解来指定结果集的键，可以使用 @MapKey 注解
    // @MapKey("id")
    User findById(int id);

    @Insert("INSERT INTO user(name, age) VALUES(#{name}, #{age})")
    void insertUser(User user);

    @Update("UPDATE user SET name = #{name}, age = #{age} WHERE id = #{id}")
    void updateUser(User user);

    @Delete("DELETE FROM user WHERE id = #{id}")
    void deleteUser(int id);
}
```

使用 MyBatis 时，你通常会创建一个 `SqlSessionFactory` 实例，然后通过它获取 `SqlSession`，接着调用 Mapper 接口中的方法来执行 SQL 语句。

```java
InputStream inputStream = Resources.getResourceAsStream("mybatis-config.xml");
SqlSessionFactory sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
try (SqlSession session = sqlSessionFactory.openSession()) {
    UserMapper userMapper = session.getMapper(UserMapper.class);
    User user = userMapper.findById(1);
    System.out.println(user);
}
```
或者
```java
SqlSession session = sqlSessionFactory.openSession();
UserMapper userMapper = session.getMapper(UserMapper.class);
User user = userMapper.findById(1);
System.out.println(user);
session.close();
```

### 加入log4j2
在 MyBatis 中集成 log4j2 可以帮助你记录 SQL 执行的详细信息，便于调试和性能分析。以下是如何在 MyBatis 中配置 log4j2 的步骤：
1. **添加依赖**：确保你的项目中已经添加了 log4j2 的依赖。如果你使用 Maven，可以在 `pom.xml` 中添加以下依赖：

```xml
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-core</artifactId>
    <version>2.x.x</version>
</dependency>
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-api</artifactId>
    <version>2.x.x</version>
</dependency>
<dependency>
    <groupId>org.apache.logging.log4j</groupId>
    <artifactId>log4j-slf4j-impl</artifactId>
    <version>2.x.x</version>
</dependency>
<dependency>
    <groupId>org.mybatis.logging</groupId>
    <artifactId>mybatis-log4j2</artifactId>
    <version>2.x.x</version>
</dependency>
```
2. **配置 log4j2**：在项目的资源目录下创建一个 `log4j2.xml` 文件，配置日志记录器和输出格式。例如：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Configuration status="WARN">
    <Appenders>
        <Console name="Console" target="SYSTEM_OUT">
            <PatternLayout pattern="%d{yyyy-MM-dd HH:mm:ss} %-5p %c{1} - %m%n"/>
        </Console>
    </Appenders>
    <Loggers>
        <Logger name="org.mybatis" level="DEBUG" additivity="false">
            <AppenderRef ref="Console"/>
        </Logger>
        <Root level="INFO">
            <AppenderRef ref="Console"/>
        </Root>
    </Loggers>
</Configuration>
```
3. **配置 MyBatis 使用 log4j2**：在 MyBatis 的配置文件 `mybatis-config.xml` 中，设置日志实现为 log4j2：

```xml
<configuration>
    <settings>
        <setting name="logImpl" value="LOG4J2"/>
    </settings>
    <!-- 其他配置 -->
    <mappers>
        <mapper resource="com/example/mapper/UserMapper.xml"/>
    </mappers>
</configuration>
```

### MyBatis Mapper
MyBatis 的 Mapper 是一个重要的概念，它定义了 SQL 语句与 Java 方法之间的映射关系。

```Java
public interface UserMapper {
    @Select("SELECT * FROM user")
    List<User> findAll();
}

public class UserService {
    private UserMapper userMapper;

    public UserService(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public List<User> getAllUsers() {
        return userMapper.findAll();
    }
}
```

### 整合事务管理 transaction management
在 MyBatis 中整合事务管理可以通过配置数据源和事务管理器来实现。
```java
@Configuration
@EnableTransactionManagement
public class MyBatisConfig {
    @Bean
    public DataSource dataSource() {
        // 配置数据源
        return new PooledDataSource("com.mysql.cj.jdbc.Driver", "jdbc:mysql://localhost:3306/mydb", "root", "password");
    }
    @Bean
    public SqlSessionFactory sqlSessionFactory(DataSource dataSource) throws Exception {
        SqlSessionFactoryBean sessionFactory = new SqlSessionFactoryBean();
        sessionFactory.setDataSource(dataSource);
        return sessionFactory.getObject();
    }
    @Bean
    public PlatformTransactionManager transactionManager(DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }
}
```
```java
@Service
public class UserService {
    @Autowired
    private UserMapper userMapper;

    @Transactional
    public void createUser(User user) {
        userMapper.insertUser(user);
        // 其他业务逻辑
    }
}
```

### MyBatis 获取参数值的两种方式

**占位符赋值**：在 MyBatis 中，参数可以通过两种方式传递给 SQL 语句：`${}` 和 `#{}`。这两种方式的区别在于它们如何处理参数值。
- `${}`：用于直接将参数值插入到 SQL 语句中，适用于动态 SQL 生成。它会直接将参数值替换到 SQL 中，因此需要小心 SQL 注入风险。
- `#{}`：用于将参数值作为预处理语句的参数传递，MyBatis 会自动处理 SQL 注入问题。它适用于大多数情况，尤其是当你需要传递复杂对象或多个参数时。

MyBatis 在处理参数时，会将参数存储在一个 `Map` 中。
1. 以 `arg0`, `arg1`, ... 为键，以方法参数为值。
2. 以 `param1`, `param2`, ... 为键，以方法参数为值。
使用 ${}/#{} 以键的方式即可访问值

| 赋值方式 | 本质 |
| ----- | ----------------- |
| `${}` | 字符串拼接 |
| `#{}` | 占位符赋值 |

#### mapper接口 访问实体类型的参数
#{} / ${} 访问实体类型的参数时，MyBatis 会将实体类的属性作为键来访问。
```java
public interface UserMapper {
    @Insert("INSERT INTO user(name, age) VALUES(#{name}, #{age})")
    void insertUser(User user);
}
```

#### 使用 @Param 注解
当方法有多个参数时，可以使用 `@Param` 注解为每个参数指定一个名称，这样在 SQL 中就可以通过这个名称来访问参数值。

```java
public interface UserMapper {
    @Insert("INSERT INTO user(name, age) VALUES(#{user.name}, #{user.age})")
    void insertUser(@Param("user") User user);
}
```


### 一对多的映射关系
在 MyBatis 中，一对多的映射关系可以通过使用 `@One` 和 `@Many` 注解来实现。通常情况下，一对多关系涉及到两个实体类：一个是主实体（如用户），另一个是从属实体（如订单）。

1. 通过级联查询来实现一对多关系的映射。
```java
@select("SELECT * FROM emp left join dept on emp.dept_id = dept.id where emp.id = #{id}")
@Results({
    @Result(property = "id", column = "id"),
    @Result(property = "name", column = "name"),
    @Result(property = "departments.id", column = "dept_id"),
    @Result(property = "departments.name", column = "dept_name")
})
Emp findEmpAndDepartmentsById(@Param("id") int id);
```

2. 使用 `Association` 和 `Collection` 注解来处理一对多关系。

```java
@select("SELECT * FROM emp left join dept on emp.dept_id = dept.id where emp.id = #{id}")
@Results({
    @Result(property = "id", column = "id"),
    @Result(property = "name", column = "name"),
    @Association(property = "department", column = "dept_id", javaType = Department.class, one = @One(select = "com.example.mapper.DepartmentMapper.findById")),
    @Collection(property = "departments", column = "dept_id", javaType = List.class, many = @Many(select = "com.example.mapper.DepartmentMapper.findByDeptId"))
})
Emp findEmpAndDepartmentsById(@Param("id") int id);
```

3. 分布式查询
分布式查询是指在 MyBatis 中通过多个 Mapper 接口来查询不同的实体类，并将它们组合成一个完整的对象。

```java
@Select("SELECT * FROM emp WHERE id = #{id}")
@Results({
    @Result(property = "id", column = "id"),
    @Result(property = "name", column = "name"),
    @Result(property = "department", column = "dept_id", one = @One(select = "com.example.mapper.DepartmentMapper.findById"))
})
Emp findEmpById(@Param("id") int id);
```

### 延迟加载
延迟加载（Lazy Loading）是 MyBatis 中的一种性能优化技术，它允许在需要时才加载关联的对象，而不是在查询主对象时立即加载所有关联对象。（分布式查询）
```java
@Select("SELECT * FROM emp WHERE id = #{id}")
@Results({
    @Result(property = "id", column = "id"),
    @Result(property = "name", column = "name"),
    @Result(property = "department", column = "dept_id", one = @One(select = "com.example.mapper.DepartmentMapper.findById", fetchType = FetchType.LAZY))
})
Emp findEmpById(@Param("id") int id);
```

### 动态SQL
动态 SQL 是 MyBatis 的一个强大特性，它允许你根据条件动态生成 SQL 语句。MyBatis 提供了多种方式来实现动态 SQL，包括使用 `<if>`, `<choose>`, `<when>`, `<otherwise>`, `<foreach>` 等标签。
```xml
<mapper namespace="com.example.mapper.UserMapper">
    <select id="findUsers" resultType="User">
        SELECT * FROM user
        <where>
            <if test="name != null and name != ''">
                AND name LIKE CONCAT('%', #{name}, '%')
            </if>
            <if test="age != null">
                AND age = #{age}
            </if>
        </where>
    </select>
</mapper>
```
```java
public interface UserMapper {
    @Select({
        "<script>",
        "SELECT * FROM user",
        "<where>",
        "<if test='name != null'>",
        "AND name LIKE CONCAT('%', #{name}, '%')",
        "</if>",
        "<if test='age != null'>",
        "AND age = #{age}",
        "</if>",
        "</where>",
        "</script>"
    })
    List<User> findUsers(@Param("name") String name, @Param("age") Integer age);
}
```

#### Foreach
`<foreach>` 标签用于处理集合或数组类型的参数，可以用于生成 IN 子句或批量插入等场景。
```xml
<mapper namespace="com.example.mapper.UserMapper">
    <select id="findUsersByIds" resultType="User">
        SELECT * FROM user WHERE id IN
        <foreach item="id" collection="ids" open="(" separator="," close=")">
            #{id}
        </foreach>
    </select>
</mapper>
```


### MyBatis 的缓存机制
如果缓存中存在数据，则直接从缓存中获取；如果缓存中不存在数据，则执行 SQL 查询，并将结果存入缓存。

MyBatis 提供了一级缓存和二级缓存两种缓存机制。
- **一级缓存**：是 SqlSession 级别的缓存，每次打开 SqlSession都会创建一个新的一级缓存。一级缓存的生命周期与 SqlSession 相同，当 SqlSession 关闭时，一级缓存也会被清空。（默认开启）
- **二级缓存**：是 Mapper 级别的缓存，可以跨 SqlSession 共享。二级缓存需要在 MyBatis 配置文件中进行配置，并且需要实现 Serializable 接口。(默认关闭)

一级缓存失效的情况包括：
1. 不同的 `SqlSession` 实例之间无法共享一级缓存。
2. 同一个 `SqlSession` 中执行了更新、删除或插入操作，这会导致一级缓存失效。
3. 执行了 `clearCache()` 方法，手动清空一级缓存。


#### 开启二级缓存
MyBatis 的二级缓存需要满足：
1. 在 MyBatis 配置文件中开启二级缓存。
2. 在 Mapper XML 文件中配置二级缓存。
3. 二级缓存必须在 `SqlSession` 关闭或提交之后才有效。
4. 实体类需要实现 `Serializable` 接口，以便 MyBatis 能够将其序列化存储到缓存中。

二级缓存失效的情况只可能是：执行了更新、删除或插入操作

开启步骤：
1. 在 MyBatis 配置文件中开启二级缓存：
```xml
<configuration>
    <settings>
        <setting name="cacheEnabled" value="true"/>
    </settings>
    <mappers>
        <mapper resource="com/example/mapper/UserMapper.xml"/>
    </mappers>
</configuration>
```
2. 在 Mapper XML 文件中配置二级缓存：
```xml
<mapper namespace="com.example.mapper.UserMapper">
    <cache/>
        <select id="findById" resultType="User">
            SELECT * FROM user WHERE id = #{id}
        </select>
        <insert id="insertUser">
            INSERT INTO user(name, age) VALUES(#{name}, #{age})
        </insert>
        <update id="updateUser">
            UPDATE user SET name = #{name}, age = #{age} WHERE id = #{id}
        </update>
        <delete id="deleteUser">
            DELETE FROM user WHERE id = #{id}
        </delete>
</mapper>
```

#### 缓存查询的顺序
1. 首先检查二级缓存，如果存在则直接返回。
2. 如果二级缓存不存在，则检查一级缓存。
3. 如果一级缓存也不存在，则执行 SQL 查询，并将结果存入一级缓存和二级缓存。


### MyBatis逆向工程

Reverse Engineering: 是指以数据库表结构为标准，自动生成Java持久层代码 (Official support)

Database -> Code

### MyBatis分页
不一次降大量结果发回，而是一次次发。