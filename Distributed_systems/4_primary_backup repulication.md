# Primary backup repucation

Two types of replication:
1. state transfer: the primary sends its entire state to the backup (state, heavy)
2. replicated state machine: the primary and backup process the same requests (operation)

### VMware Fault tolerance
- Primary VM runs on one ESXi host.
- Secondary VM runs on a different ESXi host.
- vLockstep records all non-deterministic events (CPU instructions, network packets, disk I/O) and replays them on the - secondary.
- If the primary host fails, the secondary becomes primary instantly.

If the secondary stops receiving that stream (or the primary stops getting ACKs) for ~1 s, it concludes the primary is gone.


#### Non-deterministic events
**Core**: record every non-deterministic event on the primary, ship it to the secondary, and replay it there at the exact instruction boundary so that both VMs remain in bit-for-bit identical state.

### Package from primary to secondary loss
**Core**: the primary keeps sending the same package until it receives an ACK from the secondary. 

Output rule: primary machine are allowed to make any output and do not wait for secondary received and replied ACK.

What actually happens:  
- Primary executes the instruction that generates the output (NIC TX, - disk write, etc.).
- Hypervisor copies the data into the FT log entry, tags it with the - current virtual cycle, and immediately transmits the real packet / DMA - to the real device.
- The log entry is sent asynchronously to the secondary over the - FT-logging link.
- Secondary receives the entry, replays the same output into its shadow - devices, but the emulated devices suppress the real action (they just - update internal state).
- Secondary ACKs the log entry so the primary knows the secondary is - still in sync; the ACK is purely for liveness, not a gate for the - output.
