# SQL (mysql based)

Reference:
- [Video](https://www.bilibili.com/video/BV1ge4y117cM)

### Optimization Direction
1. Transition between *Memory* and *Storage* is time consuming (Height of the Tree)
2. Time consuming of reading single and continuous elements are almost the same (B+ Tree)


## 1. Index (索引)
A `sorted` list of data that can be used to quickly find.

- Sorted Binary Tree
- Red-Black Tree
- B Tree & B+ Tree
- Hash Table

---
#### Sorted Binary Tree
Left child < Parent < Right child

**Why not use it?**  
If every node has only one child, the tree will become a linked list. The time complexity of searching will be O(n) `(Node 3)`.
```mermaid
graph TD
    A[1] --> B[2]
    B --> C[3]
```


---
#### Red-Black Tree
Or Self-Balancing Binary Tree. A refined version of the sorted binary tree.

- The height of the tree is always O(logn).
- The tree is balanced, so the time complexity of searching is O(logn).

**Why not use it?**
- (Extreme case) The height of the tree trends to be high, searching a leaf node will take O(logn) time `(Node 5, 7)`.

```mermaid
graph TD
    A[2] --> B[1]
    A --> C[4]
    C --> D[3]
    C --> E[6]
    E --> F[5]
    E --> G[7]
```

---
#### B Tree & B+ Tree
Multi-way balanced search trees.

- Reduce tree height by storing more nodes in one leaf.
- Efficient for database indexing and file systems.

![Image](./Images/B%20Tree.png)

Update:
![Image](./Images/B%20Tree%20update.png)

#### B+ Tree
Difference:
1. Only leaf nodes storage value (Address of target value)
2. Leaves are connected with each other, last leaf can quickly locate next leaf.

Why B+ then:
1. The Tree could be *Wider*
2. Enable range search (from x to y)


## Mysql Storage Engine 
| MyISAM | InnoDB |
| - | - |
| Old | New |
| Non-clustered | Clustered |

### Clustered & Non-clustered (聚集索引与非聚集索引)
**Non-clustered**: Data is non-continouly storaged (sparse)
**Clustered**:
