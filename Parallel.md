## Parallel (Java)

Material: [Bilibili](https://www.bilibili.com/video/BV1V4411p7EF)


Process, Thread:
- Process: A `program` in execution, with its own memory space.
- Thread: A lightweight process, sharing the same memory space with other threads in the same process.
- Threads are managed by the OS, while processes are managed by the kernel.
- Threads within the same process can communicate more easily than processes, as they share the same memory space.


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