# note of front-end

## HTML
1. DOM: Document Object Model - 文档对象模型，

2. Defer v.s. Async
Defer: 顺序加载的并行脚本（脚本，库）
async: 纯并行加载（第三方广告）

3. CORS (Cross-origin Resource Sharing)
允许浏览器加载不同来源的资源

4. IndexedDB: 本地数据库，支持结构化数据并离线存储

5. Storage  

| 特性 | `localStorage` | `sessionStorage` | cookies |
| ------ | --------------- | ---------------- | ------- |
| 存储容量 | 5-10MB | 5-10MB | 4KB |
| 生命周期 | 永久 | 会话 | 永久或会话 |
| 是否随请求发送 | 否 | 否 | 是 |
| 场景 | 长期存储 | 临时存储 | 用户认证 |



## CSS
1. 伪类：元素的特定状态(:hover), 伪元素：元素的一部分(::before)

2. 如何清楚浮动:
```css
.clearfix::after {
    content: "";
    display: block;
    clear: both;
}
/* 或在父元素中应用： */
.parent {
    overflow: hidden;
}
```

## Javascript
1. null: 空, undefined: 变量已声明但未赋值

2. 判断值的类型:
```Javascript
typeof value;   // 判断原始类型
value instanceof Type;  //判断对象是否为某构造函数的实例
Object.prototype.toString.call(value);
```

3. NaN: Not-a-Number. isNaN 会先尝试类型转换

4. 变量作用域：
    - 全局作用域
    - 函数作用域
    - 块级作用域 (ES6, 通过 let/const 定义)

5. "!!" 强行转换为布尔值
```Javascript
!!'abc' -> true
!!0 -> false
!!NaN -> false
!!undefined -> false
!!null -> false
```

6. Boolean([]) 与 Boolean({})
都返回true，因为所有引用类型（对象，数组，函数）都为真

7. `"5" + 3 -> "53"`, `"5" - 3 -> 2`. 因为减法时会进行类型转换

8. 变量提升（variable hoisting）：使用 `var` 声明的变量会被提升到函数或全局作用域的顶部。使用 `let` 和 `const` 声明的变量也会被提升，但会保存在暂时性死区（Temporal Dead Zone, TDZ）中，无法在声明之前访问。

9. `this` 的指向：

| Scenario | `this` 的指向 |
| -------- | -------------- |
| 全局上下文 | 指向全局对象（浏览器中为 `window`） |
| 函数调用 | 指向调用该函数的对象（非严格模式下） |
| 方法调用 | 指向调用该方法的对象 |
| 构造函数 | 指向新创建的实例对象 |
| DOM 事件 | 指向触发事件的 DOM 元素 |
| 箭头函数 | 指向定义时的外部作用域（上下文） |
| `call/apply/bind` | 指向第一个参数指定的对象 |


10. 立即执行函数（IIFE, Immediately Invoked Function Expression）：
```Javascript
// 避免变量污染全局
(function() {
    // 代码块
})();
```

11. 闭包（Closure）： 将函数与其词法环境（作用域）绑定在一起
```Javascript
function outer() {
    let outerVar = '外部变量';
    function inner() {
        console.log(outerVar);
    }
    return inner;
}
let innerFunc = outer();
innerFunc();  // 输出 '外部变量'
```

12. 实现 `sleep` 函数：通过 `Promise` 和 `async/await`
```Javascript
function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
}
```

13. 垃圾回收：可达性分析（标记清除，Mark-and-Sweep）和引用计数（Reference Counting）。
    - 标记清除：通过标记所有可达对象，然后清除未标记的对象。
    - 引用计数：每个对象维护一个引用计数，当引用计数为零时，回收该对象。

14. 深拷贝与浅拷贝（只复制一层）
```Javascript
// 1, 结构简单时可用JSON
const copy = JSON.parse(JSON.stringify(original));

// 2. 结构复杂时可用递归
function deepClone(obj) {
    if (obj === null || typeof obj !== 'object') return obj;
    const result = Array.isArray(obj) ? [] : {};
    for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
            result[key] = deepClone(obj[key]);
        }
    }
    return result;
}

// 3. 使用库
import _ from 'lodash';
const copy = _.cloneDeep(original);
```

15