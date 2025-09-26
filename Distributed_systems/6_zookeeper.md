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

### zookeeper guarrantees
1. linearable writes  
linearizable writes mean that all write operations appear to be instantaneous and are seen by all clients in the exact same, globally consistent order.  
By default, Zookeeper's reads are not linearizable. A client can read from any server in the ensemble, including a follower.

2. FIFO client order


#### The Write Process in Zookeeper

In a distributed system, linearizable writes mean that all write operations appear to be instantaneous and are seen by all clients in the exact same, globally consistent order. Zookeeper achieves this by funneling all write requests through a single leader node.

Leader-based Writes: All write operations (e.g., creating a znode, setting data) must be sent to the leader of the Zookeeper ensemble. The leader is the only node that can accept and order writes.

Total Ordering: The leader receives writes from various clients and puts them in a strict, global order. This ensures that every server in the cluster applies the same writes in the same sequence.

Quorum Acknowledgment: The leader broadcasts the write request to all of its followers. The write is considered committed and is acknowledged back to the client only after a quorum (a majority) of followers have successfully applied the change to their local in-memory database and persisted it to a write-ahead log.

Sequential ID: Zookeeper assigns a unique, monotonically increasing transaction ID (zxid) to every committed write. This zxid provides a definitive, global ordering of all state changes, which clients can use to reason about the state of the system.

### how to make sure the client always read the newest data
**Probelm**: writes are linearizable, but its reads are not.

The sync() command ensures a client doesn't accidentally read stale data. When a client issues a sync() request, the Zookeeper server it's connected to will not respond until it has applied all the changes that were committed before the sync() request was received.


## More about ZooKeeper
Essential things that ZooKeeper do: 
- `test-and-set`
- master election
- config information

### Key APIs:
| API Method | Category	| Description |
| -- | -- | -- |
| create(path, data, acl, createMode) |	Create | Creates a new znode at a specific path. The createMode defines the znode's behavior (e.g., persistent, ephemeral, sequential). |
| getData(path, watch, stat) |	Read |	Retrieves the data stored in a znode and its metadata (Stat). The watch flag can be set to be notified of future data |changes. |
| getChildren(path, watch) |	Read |	Returns the list of names of the znode's children. The watch flag can be set to be notified of changes to the children list |(creation/deletion of a child). |
| exists(path, watch) |	Read |	Checks if a znode exists. The watch flag can be set to be notified if the znode is created, deleted, or its data is changed.
| setData(path, data, version)	| Update |	Writes new data to a znode. The version parameter is used for conditional updates (optimistic locking) to prevent race |conditions. |
| delete(path, version) |	Delete |	Deletes the znode. The version parameter ensures you delete the specific version of the znode you expect. |
| multi(operations)	| Transaction |	Executes multiple ZooKeeper operations (create, set, delete) as a single, atomic transaction, ensuring all succeed or all fail. |
| close()	| Session |	Closes the client connection and ends the session. This action automatically deletes all ephemeral znodes created by this client. |