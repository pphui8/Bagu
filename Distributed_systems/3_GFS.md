# Google File Systems

Why big storage hard:
Performance -> sharding  
Faults -> tolerance (1,000 nodes, always some failures)  
Tolerance -> replication (multiple copies)   
Replication -> inconsistency     
Consistency -> **Low performance**   

**Key questions:**
1. how to distribute file to multiple servers, how to expend storage automatically,
2. how to find specific chunk
3. how to recover from failure
4. how to ensure data consistency


## Bad Replication Design
Assume we have server `s1`, `s2`

- Write: every write should be sent to both `s1` and `s2`
- Read: any read can be served by either `s1` or `s2`

**Problem**  
If `s1` and `s2` all send `write 1` and `write 2` at the same time, then `s1` may receive `write 1` first and `s2` may receive `write 2` first. - **inconsistency**


### GFS
GFS 是一个面向追加写（append-only）、大文件、顺序访问、高吞吐而设计的中心化元数据 + 分块冗余的分布式文件系统；它把“单 Master 瓶颈”“组件失效是常态”“大文件顺序写”这三个假设写进了架构基因。
  
- 单 Master（逻辑）  
全局仅一个活跃 Master 进程，负责所有元数据（namespace、文件→chunk 映射、副本位置、租约）。通过**快照 + 操作日志（Changelog）**秒级 failover 到影子节点，保证高可用。
→ 简化设计、全局调度高效，但把“元数据能放进内存”作为硬性上限（后演进到 Colossus 才彻底拆成 sharded meta）。
- 64 MB 大块（Chunk）  
文件被切成 64 MB 的 chunk，每个 chunk 全局唯一 64 bit 句柄。大粒度减少元数据量、降低客户端‐Master 交互次数，也契合 MapReduce 顺序批处理模式。
- 三副本 + 机架感知  
每个 chunk 默认 3 副本，Master 在放置时“跨机架 ≥2”以避免电源域/交换机单点失效；副本数可文件级下调到 2 或上调至 5。后台持续扫描、re-replicate、re-balance。

### GFS Gneneral Structure
- One master (map from file name to address)
- Chunk services (actual data)

#### Main tables:
1. file name -> array of chunk handles
2. chunk handle -> array of chunk servers

to make sure data security when master fails:  

3. Log, checkpoint -> dist (permanent storage)
(prevent failure, enable recovery)

#### Read
文件名 -> 文件包含的所有chunk名 -> chunk位置 -> read chunk from chunk server correspondingly.

Permanent stroage: map<file name, chunk names>, 
Temperary storage: chunk address 

#### Write (no update)
Only all copies are done then its written.
**key**: master will first assign order to chunks. (Primary to secondary)
1. find to-to-date chunk servers
2. pick primary and secondary
3. increase version
4. write data (to chunk servers)

### Possible issue:
1. 