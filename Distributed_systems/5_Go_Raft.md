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

### 节点状态
1. Follower
   - **被动**状态，响应来自 Leader 或 Candidate 的请求
   - 如果在一定时间内没有收到 Leader 的心跳或选举请求，会转换为 Candidate 状态
2. Candidate
   - **主动**状态，发起选举，向其他节点请求投票
   - 如果获得多数节点的投票，转换为 Leader 状态
   - 如果在选举过程中收到来自 Leader 的心跳，转换为 Follower 状
3. Leader
   - 负责处理客户端请求，复制日志到 Follower 节点
   - 定期发送心跳（AppendEntries RPC）以维持其领导地位

### 选举过程
1. 节点启动时，初始状态为 Follower
2. 如果 Follower 在选举超时时间内没有收到 Leader 的心跳，它会转换为 Candidate 状态，增加自己的任期号，并向其他节点发送请求投票的消息
3. 其他节点收到请求后，**如果该请求的任期号大于自己的任期号**，并且还没有投过票，就会投票给该 Candidate
4. 如果 Candidate 获得了多数节点的投票，它就会转换为 Leader 状态，开始处理客户端请求
5. Leader **定期发送心跳消息**（AppendEntries RPC）给 Follower，以维持其领导地位
6. 如果在选举过程中，Candidate 收到来自其他节点的心跳消息，且该消息的任期号大于自己的任期号，它会转换回 Follower 状态

### 投票分裂
- 投票分裂：当多个节点同时成为 Candidate 并发起选举时，可能会导致没有任何一个节点获得多数票，从而无法选出 Leader。这种情况称为投票分裂（split vote）。

Term计数：
- 每个节点维护一个任期号（term），每次选举开始时，Candidate 会增加自己的任期号
- 节点在投票时，会记录它投票的任期号，确保每个节点在同一任期内只能投票给一个 Candidate

### 日志复制
1. 客户端向 Leader 发送请求，Leader 将请求作为新的日志条目追加到自己的日志中
2. Leader 将新的日志条目复制到所有 Follower 节点
3. Follower 收到日志条目后，将其追加到自己的日志中，并向 Leader 发送确认消息
4. 一旦 Leader **收到多数 Follower 的确认**，它就会将该日志条目标记为已提交（committed），并将其应用到状态机
5. Leader 向所有 Follower 发送已提交的日志条目，确保所有节点的状态机保持一致

### 不一致修复
- 如果 Follower 的日志与 Leader 不一致，Leader 会通过 AppendEntries RPC 发送缺失的日志条目，确保 Follower 的日志与自己的日志保持一致

Leader 节点的强一致性算法。

Key：主机发送最后一个next index检查最后发送的信息是否一致，不一致则继续向前发送，直到一致。

### 安全性
- 因为 Raft 是 leader 节点的强一致性算法，所以从节点不会投票给日志不如自己新的节点。
选举时，如果一个节点的日志比另一个节点的日志新，那么它不会投票给那个节点。这样可以确保只有日志最新的节点才能成为 Leader，从而保证日志的一致性。

