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
// 可以抛出异常，并可以返回结果
class MyThread implements Callable<String> {
    public String call() throws Exception {
        return "Callable is running";
    }
}
```

2. 线程的生命周期
   - 新建（New）
   - 就绪（Runnable）
   - 运行（Running）
   - 阻塞（Blocked）
   - 死亡（Terminated）

3. Java中使用的线程调度算法
   - 先来先服务（FCFS）
   - 时间片轮转（RR）
   - 优先级调度（Priority Scheduling） - 抢占式调度

4. `wait` 和 `sleep` 区别
    - `wait()`：释放锁，进入等待状态，必须在同步块或同步方法中调用
    - `sleep()`：不释放锁，进入休眠状态，可以在任何地方调用

5. `yield` 方法
   - `yield()`：让出当前线程的CPU时间片，进入就绪状态，等待重新调度

6. 守护线程
    - 守护线程是为其他线程服务的线程，当所有非守护线程结束时，JVM会退出，守护线程也会随之结束
    - 使用 `setDaemon(true)` 方法将线程设置为守护线程
    - 例子：垃圾回收线程，当所有用户线程结束时，垃圾回收线程也会结束

7. 死锁的条件
    - 互斥条件：资源不能被多个线程共享
    - 请求与保持条件：一个线程持有至少一个资源，并等待获取其他线程持有的资源
    - 不可剥夺条件：资源不能被强制剥夺，必须由持有资源的线程自行释放
    - 循环等待条件：存在一个线程等待资源的循环链

8. 乐观，悲观锁
    - 乐观锁：假设不会发生冲突，操作数据前不加锁，操作后检查是否有冲突（如CAS）
    - 悲观锁：假设会发生冲突，操作数据前加锁，确保数据的一致性
    - 乐观锁的缺点：
        - 可能会导致ABA问题（两次操作之间数据被修改又改回原值）
        - 忙等导致CPU资源浪费
        - 只保证对一个共享变量的原子操作，无法保证多个变量的原子性

9. 锁升级
    - Java中的锁升级分为四个阶段：无锁 -> 偏向锁 -> 轻量级锁 -> 重量级锁
    - 锁升级的条件：
        - 偏向锁升级为轻量级锁：当另一个线程尝试获取偏向锁时
        - 轻量级锁升级为重量级锁：当多个线程同时竞争轻量级锁时
