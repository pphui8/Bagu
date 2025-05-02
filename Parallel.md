- [Parallel (Java)](#parallel--java-)
- [Java`s Thread Model](#java-s-thread-model)
  * [State of Thread](#state-of-thread)
  * [Key Methods of Thread Class](#key-methods-of-thread-class)
- [Lock](#lock)
  * [Lock Types in Java Objects (Storaged in Object Header, 2 bits)](#lock-types-in-java-objects--storaged-in-object-header--2-bits-)
  * [Synchronized](#synchronized)
- [Types of Locks](#types-of-locks)
  * [CAS Algorithm (Low level, no lock coding)](#cas-algorithm--low-level--no-lock-coding-)
  * [JUC (Java Util Concurrent, high-level abstraction of CAS, No lock coding)](#juc--java-util-concurrent--high-level-abstraction-of-cas--no-lock-coding-)
    + [AQS (AbstractQueuedSynchronizer)](#aqs--abstractqueuedsynchronizer-)
    + [CountDownLatch](#countdownlatch)
    + [CyclicBarrier](#cyclicbarrier)
    + [Semaphore](#semaphore)

## Parallel (Java)

Material: [Bilibili](https://www.bilibili.com/video/BV1V4411p7EF)


Process, Thread:
- Process: A `program` in execution, with its *own memory space*.
- Thread: `A lightweight process`, sharing the same memory space with other threads in the same process.
- Threads are managed by the OS, while processes are managed by the kernel.
- Threads within the same process can communicate more easily than processes, as they share the same memory space.


## Java`s Thread Model
The connection between `JVM` and `OS`, `JVM` utilizes the OS's thread model.

```Java Threads : OS Threads```

1. ```1:1``` Thread Model
- Java uses the `1:1` thread model, where each Java thread maps to a native OS thread.
- Simple and easy to implement.
- `1;1` would lead the OS to change the thread state (between user and kernel mode) frequently, which is inefficient. 
- There is limitations on the number of threads that can be created, as each thread requires its own stack space.

2. ```N:1``` Thread Model
- In this model, multiple Java threads are mapped to a single native OS thread.
- When one of the threads is blocked, the entire process is blocked.

3. ```N:N``` Thread Model
- In this model, multiple Java threads are mapped to multiple native OS threads.
- Complex and requires more resources.



### State of Thread
1. New: Created but not yet started.
2. Runnable: Ready to run or currently running.
3. Blocked: Waiting for a resource or event.
4. Executing: Actively running.
6. Terminated (Deard): Finished execution.

### Key Methods of Thread Class
1. `start()`: Starts the thread, invoking the `run()` method.
2. `run()`: Contains the code to be executed by the thread.
3. `sleep(long millis)`: Pauses the thread for a specified duration.
4. `join()`: Waits for the thread to finish execution.
5. `setPriority(int priority)`: Sets the thread's priority.
6. `yield()`: **Suggests** the thread scheduler to pause the current thread and allow others to run.
6. `interrupt()`: Interrupts the thread, setting its interrupt flag. (Not Recommended for stopping threads.)
7. `isAlive()`: Checks if the thread is still running.


## Lock
A `lock` is a synchronization mechanism that allows only one thread to access a resource at a time.

In Java, every object has an implicit lock associated with it. When a thread enters a synchronized block or method, it acquires the lock for that object. Other threads trying to enter the same synchronized block or method will be blocked until the lock is released.

### Lock Types in Java Objects (Storaged in Object Header, 2 bits)
1. **No Lock**: No lock is held. No competition for this resource.
2. **Biased Lock**: A thread has acquired the lock, and no other threads are waiting for it. 
   - The lock is biased towards the thread that acquired it, allowing it to enter the synchronized block without acquiring the lock again.
   - If another thread tries to acquire the lock, it will be upgraded to a lightweight lock.
3. **Lightweight Lock**: A thread has acquired the lock, and other threads are waiting for it.
4. **Heavyweight Lock**: A thread has acquired the lock, and other threads are waiting for it. The lock is upgraded to a heavyweight lock.

### Synchronized
`synchronized` is a keyword in Java that allows you to create synchronized blocks or methods.  
Too many `synchronized blocks` can lead to performance issues, as they can cause contention between threads.


```Java
synchronized (this) {
    // Synchronized block
}
```

After compiling, the `synchronized` keyword is replaced with `monitorenter` and `monitorexit` bytecode instructions.

```bash
Monitorenter
// Synchronized block code
Monitorexit
```

## Types of Locks
1. **Pessimistic Lock**: Assumes that conflicts will occur and locks the resource before accessing it.
   - Example: `synchronized` keyword in Java.
2. **Optimistic Lock (Not a Lock)**: Assumes that other threads will not update the resource and only checks for conflicts before committing changes.  
If a thread detects a conflict, it will retry the operation. (CAS Algorithm, Sefl-spinning)
    - Example: `java.util.concurrent` package in Java. (CAS Algorithm)
3. **Reentrant Lock（可重入锁）**: Based on AQS, a thread can acquire the same lock multiple times without blocking itself.  
Key: If thread A has acquired a lock, it can acquire the same lock again without blocking itself. Use `State` to record the number of times the lock has been acquired, when release the lock, it will decrease the count.  
   - Example: `ReentrantLock` class in Java.

### CAS Algorithm (Low level, no lock coding)
CAS (Compare and Swap) is an *atomic* operation that compares the current value of a variable with a given value and, if they are equal, updates the variable to a new value.  
If a thread detects a conflict, it will retry the operation. (Self-spinning)

```Java
import java.util.concurrent.atomic.AtomicInteger;
public class CASExample {
    // Atomic variable
    // Implemented using CAS algorithm
    // Low level implementation
    private AtomicInteger atomicInt = new AtomicInteger(0);

    public void increment() {
        int currentValue;
        int newValue;
        do {
            currentValue = atomicInt.get();
            newValue = currentValue + 1;
        } while (!atomicInt.compareAndSet(currentValue, newValue));
    }
}
```


### JUC (Java Util Concurrent, high-level abstraction of CAS, No lock coding)
The `java.util.concurrent` package provides a set of classes and interfaces for concurrent programming in Java.


#### AQS (AbstractQueuedSynchronizer)
AQS is a framework for implementing blocking locks and related synchronization constructs.  
The Queue is a FIFO queue that stores threads waiting for a lock.


#### CountDownLatch
CountDownLatch is a synchronization aid that allows one or more threads to wait until a set of operations being performed in other threads completes.

```Java
import java.util.concurrent.CountDownLatch;
public class CountDownLatchExample {
    public static void main(String[] args) throws InterruptedException {
        CountDownLatch latch = new CountDownLatch(3);

        // Create 3 threads
        for (int i = 0; i < 3; i++) {
            new Thread(() -> {
                System.out.println("Thread " + Thread.currentThread().getName() + " is doing work.");
                latch.countDown(); // Decrease the countm=, indicating that the thread has completed its work
            }).start();
        }

        latch.await(); // Wait for the count to reach 0
        System.out.println("All threads have completed their work.");
    }
}
```
#### CyclicBarrier
CyclicBarrier is a synchronization aid that allows a set of threads to all wait for each other to reach a common barrier point.

```Java
import java.util.concurrent.CyclicBarrier;
public class CyclicBarrierExample {
    public static void main(String[] args) throws InterruptedException {
        CyclicBarrier barrier = new CyclicBarrier(3, () -> System.out.println("All threads have reached the barrier."));

        // Create 3 threads
        for (int i = 0; i < 3; i++) {
            new Thread(() -> {
                System.out.println("Thread " + Thread.currentThread().getName() + " is doing work.");
                try {
                    barrier.await(); // Wait at the barrier
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }).start();
        }
    }
}
```
#### Semaphore
Semaphore is a counting semaphore that allows a certain number of threads to access a resource concurrently.

```Java
import java.util.concurrent.Semaphore;
public class SemaphoreExample {
    public static void main(String[] args) {
        Semaphore semaphore = new Semaphore(2); // Allow 2 threads to access the resource

        // Create 5 threads
        for (int i = 0; i < 5; i++) {
            new Thread(() -> {
                try {
                    semaphore.acquire();
                    System.out.println("Thread " + Thread.currentThread().getName() + " is accessing the resource.");
                    Thread.sleep(1000); // Simulate work
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    semaphore.release();
                    System.out.println("Thread " + Thread.currentThread().getName() + " has released the resource.");
                }
            }).start();
        }
    }
}
```