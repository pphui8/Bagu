# 基础知识

## 基础语法
1. ```distinct```: 消除重复列 （只能用在第一个列名之前）

2. 所有包含 NULL的计算，结果肯定是 NULL

3. 这是 AND运算符优先于 OR运算符

4. COUNT函数的结果根据参数的不同而不同。COUNT(*)会得到包含 NULL的数据行数，而 COUNT(<列名 >)会得到 NULL之外的数据行数。

    但是sum与avg中null直接不参与计算

5. 计算去除重复数据后的数据行数
```sql
SELECT COUNT(DISTINCT product_type)
FROM Product;
```

6. 
GROUP BY和 WHERE并用时 SELECT语句的执行顺序

FROM
→
WHERE
→
GROUP BY
→
SELECT

| 所以```SELECT``` 中不能写 ```GROUP BY```没写的键值

7. 使用 COUNT函数等对表中数据进行汇总操作时，为其指定条件的不是WHERE子句，而是 HAVING子句。

8. 排序键中包含NULL时，会在开头或者末尾进行汇总

7. GROUP BY子句中不能使用`SELECT`子句中定义的别名，但是在 ORDER BY子句中却是允许使用别名的。

8. 多重视图会降低SQL的性能

9. 子查询可以理解为一次性的视图

10. 原则上子查询必须设定名称
```SQL
SELECT col1, col2
FROM (
    SELECT col3
    WHERE id = '1'
) AS findById;
```

11. 标量子查询：只返回单一值的查询，例如```SELECT AVG(xxx)```或者 ```SUM()```产生的结果
    标量子查询可以使用在任何地方。（类似常数）

12. 相关子查询：子查询中引用了外层查询的列
```SQL
SELECT emp_id, emp_name
FROM Employee AS E1
WHERE emp_salary >
    (SELECT AVG(emp_salary)
     FROM Employee AS E2
     WHERE E1.emp_dept = E2.emp_dept);
```

13. ```||``` 连接符：用于字符串连接
```SQL
SELECT 'Hello' || ' ' || 'World' AS Greeting;
```

14. CASE表达式
```SQL
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    ...
    ELSE resultN    // 匹配所有条件都不满足时的结果
END
```
ELSE 不写会省略为 ELSE NULL

### 集合运算符  UNION （将多个查询结果合并为一个结果集）
- 并集：UNION
- 差集：EXCEPT
- 交集：INTERSECT

1. UNION：合并两个查询的结果集，自动去除重复行
```SQL
SELECT column1, column2 FROM table1
UNION
SELECT column1, column2 FROM table2;
```
2. UNION ALL：合并两个查询的结果集，保留重复行

### 连结
连结 JOIN 是把其他表中的列添加进来，UNION是纵向合并，JOIN是横向合并

1. 内连结（INNER JOIN）：只返回两个表中匹配的行
```SQL
SELECT A.column1, B.column2
FROM TableA AS A
INNER JOIN TableB AS B ON A.common_column = B.common_column;
```

2. 外连结（OUTER JOIN）：返回匹配的行以及未匹配的行
   - 左外连结（LEFT OUTER JOIN）：返回左表中的所有行，即使在右表中没有匹配 （指定左表为主表）
   - 右外连结（RIGHT OUTER JOIN）：返回右表中的所有行，即使在左表中没有匹配 （指定右表为主表）
   - 全外连结（FULL OUTER JOIN）：返回两个表中的所有行

3. 交叉连结（CROSS JOIN）：返回两个表的笛卡尔积 （所有可能的组合）

4. 自我连结（SELF JOIN）：将表与其自身进行连结，通常用于比较同一表中的不同行

### 差集 （EXCEPT）
1. EXCEPT：返回在第一个查询结果中存在但在第二个查询结果中不存在的行
```SQL
SELECT column1, column2 FROM table1
EXCEPT
SELECT column1, column2 FROM table2;
```

### 交集 （INTERSECT）
1. INTERSECT：返回两个查询结果中都存在的行
```SQL
SELECT column1, column2 FROM table1
INTERSECT
SELECT column1, column2 FROM table2;
```

### 窗口函数
OLAP (Online Analytical Processing)函数，也称为窗口函数，用于在查询结果集中执行计算，而不需要将结果集分组。
1. 语法
```SQL
<窗口函数> OVER (
    [PARTITION BY partition_expression]
    [ORDER BY order_expression]
    [ROWS frame_specification]
)
```

2. 常用窗口函数
- 聚合函数：SUM(), AVG(), COUNT(), MIN(), MAX()
- 专有函数：ROW_NUMBER(), RANK(), DENSE_RANK(), NTILE()

#### RANK -> 分组并排序
RANK() 函数为结果集中的每一行分配一个唯一的排名，排名相同的行会获得相同的排名值，后续排名会跳过相应的数字。
```SQL
SELECT emp_name, emp_salary,
       RANK() OVER (PARTITION BY emp_dept ORDER BY emp_salary DESC) AS dept_rank
FROM Employee;
```
PARTITION BY 子句用于将结果集按部门进行分区，ORDER BY 子句用于按薪资降序排列。
（PARTITION分组，ORDER排序）

不指定PARTITION BY时，整个结果集作为一个分区。

1. RANK(): 为每一行分配排名，排名相同的行会获得相同的排名值，后续排名会跳过相应的数字。
2. DENSE_RANK(): 与 RANK() 类似，但不会跳过排名数字
3. ROW_NUMBER(): 为每一行分配一个唯一的序号，即使排名相同的行也会有不同的序号。

通常窗口函数不需要参数。

#### 移动平均
```SQL
SELECT emp_name, emp_salary,
         AVG(emp_salary) OVER (
             ORDER BY emp_salary
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW AND 1 FOLLOWING
         ) AS moving_avg
FROM Employee;
```
PRECEDING表示前几行，FOLLOWING表示后几行, CURRENT ROW表示当前行。

#### GROUPING
同时得到汇总行和明细行 （总计和小计）
```SQL
SELECT product_type, SUM(sales_amount) AS total_sales,
FROM Sales
GROUP BY ROLLUP (product_type);
``` 
ROLLUP 会生成一个额外的汇总行，显示所有产品类型的总销售额。(键值默认为NULL)

ROLLUP 可以用于多列，相当于对每一列进行汇总
``` GROUP BY ROLLUP (col1, col2) ```
==
1. ```GROUP BY ROLLUP ()```
2. ```GROUP BY ROLLUP (col1)```
3. ```GROUP BY ROLLUP (col1, col2)```
然后再将结果UNION起来。

GROUPING函数用于区分汇总行和明细行
```SQL
SELECT product_type,
         SUM(sales_amount) AS total_sales,
            GROUPING(product_type) AS is_summary
FROM Sales
GROUP BY ROLLUP (product_type);
```
is_summary为1表示汇总行，0表示明细行。
