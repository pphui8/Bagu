## Amazon Aurora
Better performance and availability with MySQL and PostgreSQL compatibility.
Availability across multiple AZs, automated backups, and replication for read scalability.

`Core key`: update only log records, not data pages.

### Quorum-based 6-way replication across 3 AZs
```
         AZ1          AZ2          AZ3
      --------     --------     --------
     | Node A |   | Node C |   | Node E |
      --------     --------     --------
          |            |            |
          |            |            |
      --------     --------     --------
     | Node B |   | Node D |   | Node F |
      --------     --------     --------
```

- 6 copies of data: 3 primary (A, C, E) + 3 secondary (B, D, F)
- Quorum for write: 4 out of 6 nodes must acknowledge the write (e.g., A, B, C, D)
- Quorum for read: 3 out of 6 nodes must respond (e.g., A, C, E)
- Automatic failover: if a primary node fails, its secondary takes over (e.g., if A fails, B becomes primary)
- Synchronous replication within AZs, asynchronous replication across AZs for lower latency

### Log-structured storage engine
- Instead of updating data pages in place, Aurora appends log records to a storage volume.
- This reduces write amplification and improves performance.
- Data pages are reconstructed from log records during reads, allowing for efficient recovery and consistency.