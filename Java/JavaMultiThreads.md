## Java多线程
1. 创建线程的两种方式
   - 继承Thread类，重写run()方法
   - 实现Runnable接口，重写run()方法

```Java
class MyThread extends Thread {
    public void run() {
        System.out.println("Thread is running");
    }
}
class MyRunnable implements Runnable {
    public void run() {
        System.out.println("Runnable is running");
    }
}
```

2. 线程的生命周期
   - 新建（New）
   - 就绪（Runnable）
   - 运行（Running）
   - 阻塞（Blocked）
   - 死亡（Terminated）