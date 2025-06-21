## SpringWeb

三大组件：

| 组件 | 作用 | 特点 |
| ---- | ---- | ---- |
| Servlet | 接收请求，响应请求 | 单例对象，轻量级，性能高。每个Servlet有一个service方法，每次访问都会执行service方法 |
| Flilter | 过滤请求和响应 | 单例对象，可用于日志记录、权限检查等 |
| Listener | 监听ServletContext、HttpSession等事件 | 用于处理应用程序级别的事件 |

### Spring整合web环境的思路及其实现
MVC模式：Model（模型）、View（视图）、Controller（控制器）

Web层：注入Service
Service层：注入Dao（Mapper）