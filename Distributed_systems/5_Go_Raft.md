## Go

#### 1. Thread
```go
func main() {
	var wg sync.WaitGroup
	for i := 0; i < 5; i++ {
		wg.Add(1)
		go func(i int) {
			defer wg.Done()
			fmt.Println(i)
		}(i)
	}
	wg.Wait()
}
```


#### execute among a specific period
```go
var done bool
var mu sync.Mutex

func main() {
	time.Sleep(time.Second)
	fmt.Println("start")
	go periodic()
	time.Sleep(5 * time.Second) // do until 5 seconds
	mu.Lock()
	done = true
	mu.Unlock()
}

func periodic() {
	for {
		fmt.Println("tick")
		time.Sleep(time.Second)
		mu.Lock()
		if done {
			mu.Unlock()
			return
		}
		mu.Unlock()
	}
}
```

#### Conditional lock
```go
func main() {
	var count int
	var finished int
	var mu sync.Mutex
	cond := sync.NewCond(&mu)

	for i := 0; i < 10; i++ {
		go func() {
			vote := requestVote()
			mu.Lock()
			if vote {
				count++
			}
			finished++
			cond.Signal()
			mu.Unlock()
		}()
	}

	/*
		// busy waiting example
		for {
			mu.Lock()
			if count >= 5 || finished >= 10 {
				mu.Unlock()
				break
			}
			mu.Unlock()
		}

	*/

	// auto unlock when condition is met
	// avoiding busy wait
	mu.Lock()
	for count < 5 && finished < 10 {
		cond.Wait()
	}
	if count >= 5 {
		fmt.Println("Received majority votes")
	} else {
		fmt.Println("lost")
	}
	mu.Unlock()
}

func requestVote() bool {
	return rand.Intn(2) == 0
}
```

## Raft
Raft 是一种 分布式共识算法（consensus algorithm）
- 核心作用：让多个节点（服务器）在不可靠的网络环境中，就某个值或日志序列达成一致（共识）。

