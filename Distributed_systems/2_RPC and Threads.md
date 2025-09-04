# RPC and Threads

## Challenges of Threads
1. shared memory（lock）
2. Coordination
    - Threads don`t know other`s status
    = 需要显式的同步机制（如条件变量、信号量等）来协调线程之间的工作。
    - tools
        - channel
        - sync.Cond （条件变量，满足条件时唤醒）
        = wait group
        - Dead lock

| 需求           | WaitGroup | Channel | sync.Cond          |
| ------------ | --------- | ------- | ------------------ |
| 等一组任务结束      | ✅         | ❌       | 可模拟                |
| 等待缓冲区非满/非空   | ❌         | ✅       | ✅                  |
| 等待任意业务条件     | ❌         | 需额外封装   | ✅                  |
| 多次唤醒         | ❌         | ✅       | ✅                  |
| 唤醒全部 vs 唤醒一个 | 无         | 只能广播    | Signal / Broadcast |

**Use Case**:
```go
type fetchState struct {
    mu      sync.RWMutex    // 多读少写锁
    fetched map[string]bool
}

// ... thread body, when fetched a list of urls
var done sync.WaitGroup
for _, url := range urls {
    done.Add(1)
    go func(url string) {
        defer done.Done()
        // fetch url
    }(url)
}
```


