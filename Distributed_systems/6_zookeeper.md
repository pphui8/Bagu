## ZooKeeper
ZooKeeper is a centralized service for maintaining configuration information, naming, providing distributed synchronization, and providing group services.

｜ **集群协作**
- 配置管理
- 分布式锁
- 集群管理


### Linearize ability
线性化是并发系统（如分布式数据库）的正确性条件。 它确保每个操作在其开始和结束之间的某个时间点瞬间发生。 这给人一种错觉，即所有操作都在单个共享对象上按顺序执行，即使它们可能同时在多个节点上运行。

线性化点是一个操作的效果对所有其他操作可见的特定时刻。 此点必须发生在操作的调用（开始时）和响应（完成时）之间。
- 对于写入操作：线性化点是新值可供后续读取并可见的时刻。
- 对于读取操作：线性化点是读取检索值的时刻。该值必须是在此点之前已线性化的最近写入的值。

**Implementaion**
服务器会暂时记住read请求的返回结果，如果同样的请求再次出现则返回储存的结果。


### Why ZooKeeper
The key difference between Raft and Zookeeper is their purpose and level of abstraction. Raft is a consensus algorithm, while Zookeeper is a distributed coordination service that uses a consensus protocol (Zab, a variation of Paxos) to achieve its goals.