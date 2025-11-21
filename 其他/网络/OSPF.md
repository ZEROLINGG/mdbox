# OSPF（开放最短路径优先）完全详解


## 一、OSPF基础概念

### 1.1 OSPF概述

```
OSPF (Open Shortest Path First) 开放最短路径优先
- RFC 2328 (OSPFv2 for IPv4)
- RFC 5340 (OSPFv3 for IPv6)

核心特点：
✓ 链路状态路由协议
✓ 无类路由协议（支持VLSM和CIDR）
✓ 使用SPF（Dijkstra）算法
✓ 管理距离：110
✓ 度量值：Cost（基于带宽）
✓ 支持等价负载均衡
✓ 快速收敛
✓ 层次化设计（区域）
✓ 组播更新（224.0.0.5 和 224.0.0.6）
✓ 支持认证
```

### 1.2 OSPF vs 其他路由协议

```
协议对比：
┌──────────┬────────┬──────┬────────┬────────────┐
│ 特性     │ OSPF   │ RIP  │ EIGRP  │ IS-IS      │
├──────────┼────────┼──────┼────────┼────────────┤
│ 类型     │ 链路态 │ 距离 │ 高级DV │ 链路状态   │
│ 算法     │ SPF    │ BF   │ DUAL   │ SPF        │
│ 度量     │ Cost   │ 跳数 │ 组合   │ Cost       │
│ 收敛     │ 快     │ 慢   │ 很快   │ 快         │
│ 扩展性   │ 大型   │ 小型 │ 中大型 │ 超大型     │
│ 标准     │ 开放   │ 开放 │ 思科   │ 开放       │
│ 管理距离 │ 110    │ 120  │ 90     │ 115        │
└──────────┴────────┴──────┴────────┴────────────┘
```

### 1.3 OSPF术语表

```bash
Router ID (RID)        # 路由器标识，32位，类似IP地址
ABR                    # Area Border Router 区域边界路由器
ASBR                   # AS Boundary Router 自治系统边界路由器
IR                     # Internal Router 内部路由器
Backbone Router        # 骨干路由器（Area 0）
DR                     # Designated Router 指定路由器
BDR                    # Backup Designated Router 备份指定路由器
DROTHER               # 非DR/BDR路由器
LSA                    # Link State Advertisement 链路状态通告
LSDB                   # Link State Database 链路状态数据库
SPF Tree              # 最短路径树
Cost                   # 开销/代价（度量值）
Area                   # 区域
Adjacency             # 邻接关系
Neighbor              # 邻居关系
Stub Area             # 末节区域
Totally Stub          # 完全末节区域
NSSA                  # Not-So-Stubby Area 非完全末节区域
Virtual Link          # 虚链路
```

---

## 二、OSPF工作原理

### 2.1 OSPF工作流程

```
OSPF建立邻居和同步数据库的完整过程：

第一步：发现邻居
├─ 发送Hello报文（组播224.0.0.5）
├─ 接收Hello报文
└─ 建立邻居关系

第二步：建立邻接
├─ 选举DR/BDR（多路访问网络）
├─ 建立邻接关系
└─ 开始LSA交换

第三步：交换链路信息
├─ 发送DD报文（Database Description）
├─ 比对LSDB
└─ 确定需要的LSA

第四步：请求详细信息
├─ 发送LSR（Link State Request）
└─ 请求缺失的LSA

第五步：同步数据库
├─ 发送LSU（Link State Update）
├─ 回复LSAck确认
└─ LSDB同步完成

第六步：计算路由
├─ 运行SPF算法
├─ 构建最短路径树
└─ 生成路由表
```

### 2.2 OSPF邻居状态机

```
OSPF邻居状态转换：

Down（关闭）
  ↓ 接收Hello
Init（初始化）
  ↓ 在Hello中看到自己的Router ID
2-Way（双向）
  ↓ 开始交换DD报文
ExStart（准备交换）
  ↓ 确定主从关系
Exchange（交换）
  ↓ 交换DD报文完成
Loading（加载）
  ↓ LSR/LSU交换完成
Full（完全）
  ↓ LSDB同步完成
```

### 2.3 Cost计算

```bash
# OSPF Cost计算公式
Cost = 参考带宽 / 接口带宽

# 华为默认参考带宽：100 Mbps
# 接口Cost值：
┌──────────────┬─────────────┬────────┐
│ 接口类型     │ 带宽        │ Cost   │
├──────────────┼─────────────┼────────┤
│ Ethernet     │ 10 Mbps     │ 10     │
│ FastEthernet │ 100 Mbps    │ 1      │
│ GE           │ 1000 Mbps   │ 1      │
│ 10GE         │ 10 Gbps     │ 1      │
│ Serial       │ 64 Kbps     │ 1562   │
│ Loopback     │ -           │ 0      │
└──────────────┴─────────────┴────────┘

# 问题：GE和10GE的Cost都是1
# 解决：修改参考带宽

# 查看当前Cost
<Huawei>display ospf interface GigabitEthernet 0/0/0

# 路由Cost = 沿途所有接口Cost之和
```

---

## 三、OSPF报文类型

### 3.1 OSPF五种报文

```
1. Hello报文
   功能：发现和维护邻居关系
   发送：周期性发送（默认10秒/30秒）
   目的：224.0.0.5（AllSPFRouters）
   
2. DD报文 (Database Description)
   功能：描述LSDB摘要信息
   内容：LSA的头部信息（不含详细内容）
   用途：同步数据库的第一步
   
3. LSR报文 (Link State Request)
   功能：请求完整的LSA
   发送：收到DD后，请求缺失的LSA
   
4. LSU报文 (Link State Update)
   功能：发送完整的LSA
   内容：携带一个或多个LSA
   用途：泛洪LSA
   
5. LSAck报文 (Link State Acknowledgment)
   功能：确认收到LSU
   保证：可靠传输
```

### 3.2 Hello报文详解

```bash
Hello报文字段：
┌────────────────────┬──────────────────────────────┐
│ 字段               │ 说明                         │
├────────────────────┼──────────────────────────────┤
│ Router ID          │ 发送者的路由器ID             │
│ Area ID            │ 区域ID                       │
│ Network Mask       │ 接口网络掩码                 │
│ Hello Interval     │ Hello间隔（默认10秒）        │
│ Router Dead        │ 失效时间（默认40秒）         │
│ Router Priority    │ 优先级（DR选举）             │
│ DR                 │ 指定路由器IP                 │
│ BDR                │ 备份指定路由器IP             │
│ Neighbor List      │ 邻居列表                     │
│ Options            │ 可选能力                     │
│ Authentication     │ 认证信息                     │
└────────────────────┴──────────────────────────────┘

# Hello报文必须匹配的参数（否则无法建立邻居）：
✓ Area ID          # 必须相同
✓ 认证类型和密码    # 必须相同
✓ Hello间隔        # 必须相同
✓ Dead间隔         # 必须相同
✓ 网络掩码         # 必须相同（P2P除外）
✓ Stub标志         # 必须相同
✓ MTU              # 建议相同（否则可能卡在ExStart）
```

### 3.3 LSA老化机制

```
LSA老化时间轴：

0秒 ─────────→ 1800秒 ────→ 3600秒
生成           刷新          老化

详细说明：
- LSAge字段：当前LSA的年龄（秒）
- MaxAge：3600秒
- LSRefreshTime：1800秒
- 每条LSA每隔30分钟刷新一次
- 达到MaxAge后，LSA被删除
- InfTransDelay：传输延迟（默认1秒）

LSA刷新机制：
1. 路由器每30分钟重新生成自己的LSA
2. 序列号+1
3. LSAge重置为0
4. 重新泛洪

LSA删除机制：
1. LSAge达到3600秒
2. 设置LSAge = MaxAge
3. 从LSDB中删除
4. 重新运行SPF
```

---

## 四、OSPF邻居与邻接关系

### 4.1 邻居建立条件

```bash
# 必须满足的条件：
1. 双向通信（能收到对方Hello）
2. 接口同一子网（P2P除外）
3. 区域ID相同
4. 认证参数相同
5. Hello/Dead间隔相同
6. 网络掩码相同
7. Stub标志相同
8. 外部路由能力一致

# 检查命令：
<Huawei>display ospf peer
<Huawei>display ospf peer brief
<Huawei>display ospf interface

# 查看详细邻居信息：
<Huawei>display ospf peer verbose

# 输出示例：
 OSPF Process 1 with Router ID 1.1.1.1
         Neighbors 
 
 Area 0.0.0.0 interface 192.168.1.1(GigabitEthernet0/0/0)'s neighbors
 Router ID: 2.2.2.2        Address: 192.168.1.2
   State: Full  Mode:Nbr is Master  Priority: 1
   DR: 192.168.1.1  BDR: 192.168.1.2  MTU: 1500    
   Dead timer due in 36  sec 
   Neighbor is up for 01:23:45     
   Authentication Sequence: [ 0 ] 
   Neighbor state change count: 6
```

### 4.2 DR/BDR选举

```
DR/BDR选举（仅在多路访问网络）：

选举条件：
1. 接口优先级最高的成为DR（0-255，默认1）
2. 优先级相同，Router ID大的成为DR
3. 优先级为0不参与选举（永远是DROTHER）
4. BDR是优先级第二高的
5. DR/BDR选举是非抢占的

选举过程：
第一步：Wait Timer（40秒或Dead Interval）
├─ 等待期间监听网络
└─ 查看是否已有DR/BDR

第二步：如果没有DR
├─ 优先选举BDR
└─ 将BDR提升为DR

第三步：选举新的BDR
└─ 从剩余路由器中选举

网络中的角色：
┌─────────┬──────────────────────────────┐
│ 角色    │ 说明                         │
├─────────┼──────────────────────────────┤
│ DR      │ 与所有路由器建立邻接关系     │
│ BDR     │ 与所有路由器建立邻接关系     │
│ DROTHER │ 只与DR/BDR建立邻接关系       │
└─────────┴──────────────────────────────┘

邻接关系：
DROTHER ←→ DR    (Full)
DROTHER ←→ BDR   (Full)
DROTHER ←→ DROTHER (2-Way)  # 只是邻居，不交换LSA
```

### 4.3 配置DR/BDR优先级

```bash
# 修改接口优先级
[Huawei]interface GigabitEthernet 0/0/0
[Huawei-GigabitEthernet0/0/0]ospf dr-priority 100

# 优先级说明：
# 0   = 永远不会成为DR/BDR
# 1   = 默认值
# 255 = 最高优先级

# 实例：强制某台路由器成为DR
[Huawei-R1]interface GigabitEthernet 0/0/0
[Huawei-R1-GigabitEthernet0/0/0]ospf dr-priority 255

[Huawei-R2]interface GigabitEthernet 0/0/0
[Huawei-R2-GigabitEthernet0/0/0]ospf dr-priority 200

[Huawei-R3]interface GigabitEthernet 0/0/0
[Huawei-R3-GigabitEthernet0/0/0]ospf dr-priority 1

# 查看DR/BDR
<Huawei>display ospf peer
<Huawei>display ospf interface GigabitEthernet 0/0/0

# 重新选举DR（需要重启OSPF或接口）
[Huawei]ospf 1
[Huawei-ospf-1]reset ospf process
# 或
[Huawei]interface GigabitEthernet 0/0/0
[Huawei-GigabitEthernet0/0/0]shutdown
[Huawei-GigabitEthernet0/0/0]undo shutdown

# 注意：DR/BDR是非抢占的！
# 即使新加入优先级更高的路由器，也不会立即成为DR
# 除非当前DR失效
```

---

## 五、OSPF网络类型

### 5.1 四种网络类型

```
OSPF支持的网络类型：

1. Broadcast（广播型）
   ├─ 特点：多路访问、支持广播
   ├─ 示例：以太网、FDDI
   ├─ Hello间隔：10秒
   ├─ Dead间隔：40秒
   ├─ 选举DR/BDR：是
   ├─ 组播地址：224.0.0.5（所有路由器）
   │           224.0.0.6（DR/BDR）
   └─ 邻居发现：自动

2. P2P（点对点）
   ├─ 特点：仅两个设备
   ├─ 示例：PPP、HDLC串行链路
   ├─ Hello间隔：10秒
   ├─ Dead间隔：40秒
   ├─ 选举DR/BDR：否
   ├─ 组播地址：224.0.0.5
   └─ 邻居发现：自动

3. NBMA（非广播多路访问）
   ├─ 特点：多路访问、不支持广播
   ├─ 示例：Frame Relay、ATM
   ├─ Hello间隔：30秒
   ├─ Dead间隔：120秒
   ├─ 选举DR/BDR：是
   ├─ 邻居发现：手动配置
   └─ 使用单播发送Hello

4. P2MP（点对多点）
   ├─ 特点：特殊的NBMA处理方式
   ├─ 示例：部分连接的Frame Relay
   ├─ Hello间隔：30秒
   ├─ Dead间隔：120秒
   ├─ 选举DR/BDR：否
   ├─ 组播地址：224.0.0.5
   └─ 邻居发现：自动
```

### 5.2 网络类型配置

```bash
# 查看当前网络类型
<Huawei>display ospf interface GigabitEthernet 0/0/0

# 修改网络类型
[Huawei]interface GigabitEthernet 0/0/0
[Huawei-GigabitEthernet0/0/0]ospf network-type broadcast   # 广播型
[Huawei-GigabitEthernet0/0/0]ospf network-type p2p         # 点对点
[Huawei-GigabitEthernet0/0/0]ospf network-type nbma        # NBMA
[Huawei-GigabitEthernet0/0/0]ospf network-type p2mp        # 点对多点

# 修改Hello和Dead定时器
[Huawei-GigabitEthernet0/0/0]ospf timer hello 5
[Huawei-GigabitEthernet0/0/0]ospf timer dead 20

# NBMA配置邻居（必须手动）
[Huawei]ospf 1
[Huawei-ospf-1]peer 192.168.1.2                           # 邻居IP

# P2MP配置
[Huawei]interface Serial 1/0/0
[Huawei-Serial1/0/0]ip address 10.1.1.1 30
[Huawei-Serial1/0/0]ospf network-type p2mp
[Huawei-Serial1/0/0]ospf timer hello 10
[Huawei-Serial1/0/0]ospf timer dead 40

# 网络类型选择建议：
# 以太网接口：默认broadcast，根据需要改为p2p
# 串行接口：默认p2p，保持默认
# Frame Relay：根据拓扑选择p2mp或nbma
# GRE隧道：p2p
```

### 5.3 网络类型对比

```
网络类型特性对比：
┌──────────┬─────────┬──────┬──────┬───────────┐
│ 网络类型 │ Hello   │ Dead │ DR   │ 邻居发现  │
├──────────┼─────────┼──────┼──────┼───────────┤
│Broadcast │ 10秒    │ 40秒 │ 是   │ 自动      │
│P2P       │ 10秒    │ 40秒 │ 否   │ 自动      │
│NBMA      │ 30秒    │120秒 │ 是   │ 手动      │
│P2MP      │ 30秒    │120秒 │ 否   │ 自动      │
└──────────┴─────────┴──────┴──────┴───────────┘

LSA中下一跳：
┌──────────┬────────────────────────────┐
│ 网络类型 │ 下一跳                     │
├──────────┼────────────────────────────┤
│Broadcast │ 宣告路由器的接口IP         │
│P2P       │ 对端路由器IP               │
│NBMA      │ 宣告路由器的接口IP         │
│P2MP      │ 对端路由器IP               │
└──────────┴────────────────────────────┘
```

---

## 六、OSPF区域设计

### 6.1 区域概念

```
OSPF层次化设计 - 区域（Area）

为什么需要区域？
1. 减少LSA泛洪范围
2. 缩小LSDB大小
3. 降低SPF计算频率
4. 提高网络可扩展性
5. 隔离网络故障

区域设计原则：
┌────────────────────────────────────────┐
│          Area 0 (骨干区域)              │
│    ┌──────┐  ┌──────┐  ┌──────┐       │
│    │ ABR  │──│ ABR  │──│ ABR  │       │
│    └──┬───┘  └───┬──┘  └───┬──┘       │
└───────┼──────────┼─────────┼──────────┘
        │          │         │
   ┌────┴───┐ ┌───┴────┐ ┌──┴─────┐
   │ Area 1 │ │ Area 2 │ │ Area 3 │
   │        │ │        │ │        │
   └────────┘ └────────┘ └────────┘

核心规则：
✓ 所有区域必须连接到Area 0（骨干区域）
✓ Area 0必须连续，不能分割
✓ 区域间通信必须经过Area 0
✓ 如果区域无法物理连接到Area 0，使用虚链路
```

### 6.2 路由器角色

```bash
OSPF路由器类型：

1. Internal Router（内部路由器）
   ├─ 所有接口属于同一区域
   ├─ 只有该区域的LSDB
   └─ 不传递区域间路由

2. ABR (Area Border Router) 区域边界路由器
   ├─ 连接两个或多个区域
   ├─ 至少一个接口在Area 0
   ├─ 为每个区域维护独立LSDB
   ├─ 产生Type 3 LSA（区域间路由）
   └─ 执行区域间路由汇总

3. Backbone Router（骨干路由器）
   ├─ 至少一个接口在Area 0
   └─ 可以是ABR或Internal Router

4. ASBR (AS Boundary Router) 自治系统边界路由器
   ├─ 连接到外部AS
   ├─ 引入外部路由到OSPF
   ├─ 产生Type 5 LSA（外部路由）
   └─ 可以是任何区域的路由器

# 查看路由器角色
<Huawei>display ospf brief
<Huawei>display ospf abr-asbr

# 输出示例：
 OSPF Process 1 with Router ID 1.1.1.1
         OSPF Protocol Information
 
 Router Type: ABR                    # 这是ABR
 Route Calculation Timer: 5s
 LSA Originate Interval: 5s
 SPF Scheduled Count: 12
 SPF Calculation Count: 10
```

### 6.3 区域类型

```
OSPF区域类型：

1. 标准区域（Normal Area）
   ├─ 接受所有类型LSA
   ├─ 完整的路由信息
   └─ LSDB最大

2. 骨干区域（Backbone Area - Area 0）
   ├─ 所有区域的中心
   ├─ 传递区域间路由
   └─ 必须存在且连续

3. 末节区域（Stub Area）
   ├─ 不接受Type 5 LSA（外部路由）
   ├─ ABR注入默认路由
   ├─ 不能包含ASBR
   ├─ 不能是Area 0
   └─ 所有路由器必须配置stub标志

4. 完全末节区域（Totally Stub Area）
   ├─ 不接受Type 3、4、5 LSA
   ├─ 只有默认路由和区域内路由
   ├─ ABR注入默认路由
   └─ 华为特有（仅ABR配置）

5. NSSA（Not-So-Stubby Area）
   ├─ 类似Stub，但允许引入外部路由
   ├─ 使用Type 7 LSA替代Type 5
   ├─ ABR将Type 7转换为Type 5
   └─ 可以包含ASBR

6. Totally NSSA
   ├─ 结合Totally Stub和NSSA特性
   ├─ 不接受Type 3、4、5 LSA
   ├─ 接受Type 7 LSA
   └─ 华为特有
```

### 6.4 区域配置

```bash
# 标准区域配置
[Huawei]ospf 1 router-id 1.1.1.1
[Huawei-ospf-1]area 0
[Huawei-ospf-1-area-0.0.0.0]network 192.168.1.0 0.0.0.255

[Huawei-ospf-1]area 1
[Huawei-ospf-1-area-0.0.0.1]network 10.1.0.0 0.0.255.255

# Stub区域配置（所有区域内路由器都要配置）
[Huawei-R1-ospf-1]area 1
[Huawei-R1-ospf-1-area-0.0.0.1]stub              # 末节区域

[Huawei-R2-ospf-1]area 1
[Huawei-R2-ospf-1-area-0.0.0.1]stub              # 所有路由器都配

# Totally Stub配置（仅在ABR配置）
[Huawei-ABR-ospf-1]area 1
[Huawei-ABR-ospf-1-area-0.0.0.1]stub no-summary  # 完全末节

# NSSA配置
[Huawei-R1-ospf-1]area 2
[Huawei-R1-ospf-1-area-0.0.0.2]nssa              # NSSA区域

# Totally NSSA配置（仅ABR）
[Huawei-ABR-ospf-1]area 2
[Huawei-ABR-ospf-1-area-0.0.0.2]nssa no-summary  # 完全NSSA

# NSSA默认路由配置
[Huawei-ABR-ospf-1-area-0.0.0.2]nssa default-route-advertise

# NSSA Type 7转Type 5
[Huawei-ABR-ospf-1-area-0.0.0.2]nssa translate always
# 或
[Huawei-ABR-ospf-1-area-0.0.0.2]nssa translate never

# 查看区域信息
<Huawei>display ospf brief
<Huawei>display ospf lsdb
<Huawei>display ospf routing
```

---

## 七、OSPF LSA详解

### 7.1 LSA类型概览

```
OSPF LSA类型（7种常见LSA）：

Type 1 - Router LSA（路由器LSA）
├─ 范围：区域内泛洪
├─ 产生：所有路由器
├─ 内容：路由器接口、邻居、Cost
└─ LS ID：产生路由器的Router ID

Type 2 - Network LSA（网络LSA）
├─ 范围：区域内泛洪
├─ 产生：DR
├─ 内容：多路访问网络上的路由器列表
└─ LS ID：DR的接口IP地址

Type 3 - Network Summary LSA（网络汇总LSA）
├─ 范围：区域间传递
├─ 产生：ABR
├─ 内容：区域间路由信息
└─ LS ID：目标网络地址

Type 4 - ASBR Summary LSA（ASBR汇总LSA）
├─ 范围：区域间传递
├─ 产生：ABR
├─ 内容：如何到达ASBR
└─ LS ID：ASBR的Router ID

Type 5 - AS External LSA（AS外部LSA）
├─ 范围：整个AS（Stub除外）
├─ 产生：ASBR
├─ 内容：外部路由信息
└─ LS ID：外部网络地址

Type 7 - NSSA External LSA（NSSA外部LSA）
├─ 范围：NSSA区域内
├─ 产生：NSSA区域的ASBR
├─ 内容：NSSA外部路由
└─ LS ID：外部网络地址
（ABR将Type 7转换为Type 5）

Type 8-11 - 特殊用途（不常用）
```

### 7.2 Type 1 LSA详解

```bash
# Type 1 - Router LSA

特点：
- 每个路由器都会产生
- 描述路由器的链路状态
- 只在本区域内泛洪
- LS ID = Router ID

包含信息：
1. 路由器所有链路的信息
2. 链路类型（P2P、Transit、Stub、Virtual）
3. 链路Cost
4. 邻居Router ID
5. 路由器角色标志（ABR、ASBR）

# 查看Type 1 LSA
<Huawei>display ospf lsdb router

# 输出示例：
 OSPF Process 1 with Router ID 1.1.1.1
         Link State Database 
 
                 Area: 0.0.0.0
 Type      LinkState ID    AdvRouter       Age  Len   Sequence   Metric
 Router    1.1.1.1         1.1.1.1         245  48    80000003   1
 Router    2.2.2.2         2.2.2.2         223  48    80000002   1

# 详细查看
<Huawei>display ospf lsdb router 1.1.1.1

# Type 1 LSA中的链路类型：
1. Point-to-Point（P2P链路）
   - 连接到另一台路由器
   - Link ID = 邻居Router ID
   - Link Data = 本地接口IP

2. Transit Network（传输网络）
   - 连接到多路访问网络（有DR）
   - Link ID = DR的接口IP
   - Link Data = 本地接口IP

3. Stub Network（末节网络）
   - 没有邻居的网络
   - Link ID = 网络地址
   - Link Data = 网络掩码

4. Virtual Link（虚链路）
   - 虚拟点对点链路
```

### 7.3 Type 2 LSA详解

```bash
# Type 2 - Network LSA

特点：
- 仅DR产生
- 描述多路访问网络
- 只在本区域内泛洪
- LS ID = DR的接口IP

包含信息：
1. 网络掩码
2. 连接到该网络的所有路由器（包括DR自己）

# 查看Type 2 LSA
<Huawei>display ospf lsdb network

# 输出示例：
 Type      LinkState ID    AdvRouter       Age  Len   Sequence   Metric
 Network   192.168.1.1     1.1.1.1         342  32    80000001   0

# 详细查看
<Huawei>display ospf lsdb network 192.168.1.1

# Network LSA示例：
# 网络192.168.1.0/24，DR是R1(192.168.1.1)
# 连接的路由器：R1、R2、R3
# Network LSA会列出：
# - Network Mask: 255.255.255.0
# - Attached Router: 1.1.1.1 (R1)
# - Attached Router: 2.2.2.2 (R2)
# - Attached Router: 3.3.3.3 (R3)

# 注意：
# - P2P网络不产生Type 2 LSA
# - 只有Broadcast和NBMA网络产生
```

### 7.4 Type 3 LSA详解

```bash
# Type 3 - Network Summary LSA

特点：
- ABR产生
- 传递区域间路由
- 不跨Area 0传递（必须经过Area 0）
- LS ID = 目标网络地址

包含信息：
1. 目标网络地址
2. 网络掩码
3. Metric（到目标网络的开销）

# 查看Type 3 LSA
<Huawei>display ospf lsdb summary

# 输出示例：
 Type      LinkState ID    AdvRouter       Age  Len   Sequence   Metric
 Sum-Net   10.1.0.0        1.1.1.1         567  28    80000001   2
 Sum-Net   10.2.0.0        1.1.1.1         567  28    80000001   2

# 详细查看
<Huawei>display ospf lsdb summary 10.1.0.0

# Type 3 LSA传递过程：
# Area 1的路由 → ABR产生Type 3 → Area 0
# Area 0收到 → 其他ABR产生新Type 3 → Area 2

# ABR对Type 3的处理：
1. 计算到目标网络的Metric
2. 产生新的Type 3 LSA
3. 新LSA的AdvRouter是ABR自己
4. Metric = 原Metric + ABR到Area 0的Cost

# 防止路由环路：
# ABR不会将从非骨干区域收到的Type 3转发到其他非骨干区域
# 必须经过Area 0
```

### 7.5 Type 5 LSA详解

```bash
# Type 5 - AS External LSA

特点：
- ASBR产生
- 描述外部路由（重分发进OSPF的路由）
- 在整个AS内泛洪（Stub/Totally Stub除外）
- LS ID = 外部网络地址

包含信息：
1. 外部网络地址和掩码
2. Metric类型（E1或E2）
3. Metric值
4. Forwarding Address（转发地址）
5. External Route Tag

# 查看Type 5 LSA
<Huawei>display ospf lsdb ase

# 输出示例：
 Type      LinkState ID    AdvRouter       Age  Len   Sequence   Metric
 External  0.0.0.0         3.3.3.3         892  36    80000001   1
 External  172.16.0.0      3.3.3.3         892  36    80000001   20

# E1 vs E2路由：
┌──────┬────────────────────────────────────┐
│ 类型 │ Metric计算                         │
├──────┼────────────────────────────────────┤
│ E1   │ 外部Metric + OSPF内部Metric       │
│      │ (累加)                             │
│      │ 路由表显示：O_ASE (Type 1)         │
├──────┼────────────────────────────────────┤
│ E2   │ 仅考虑外部Metric                   │
│      │ (默认类型，不累加内部Cost)         │
│      │ 路由表显示：O_ASE (Type 2)         │
└──────┴────────────────────────────────────┘

# 配置外部路由类型
[Huawei-ospf-1]import-route static type 1        # E1类型
[Huawei-ospf-1]import-route static type 2        # E2类型（默认）
[Huawei-ospf-1]import-route static cost 100      # 指定Metric

# 转发地址（Forwarding Address）
# 非0.0.0.0时，流量直接发往该地址，而不是ASBR
# 条件：
# 1. ASBR的外部接口启用了OSPF
# 2. 外部接口网络类型不是P2P
# 3. 外部接口不是被动接口

# External Route Tag
# 32位值，可用于路由策略
[Huawei-ospf-1]import-route static tag 100
```

### 7.6 LSA查看命令

```bash
# 查看所有LSA
<Huawei>display ospf lsdb

# 按类型查看
<Huawei>display ospf lsdb router               # Type 1
<Huawei>display ospf lsdb network              # Type 2
<Huawei>display ospf lsdb summary              # Type 3
<Huawei>display ospf lsdb asbr                 # Type 4
<Huawei>display ospf lsdb ase                  # Type 5
<Huawei>display ospf lsdb nssa                 # Type 7

# 查看特定区域
<Huawei>display ospf lsdb area 1

# 查看特定LSA详情
<Huawei>display ospf lsdb router 1.1.1.1
<Huawei>display ospf lsdb network 192.168.1.1
<Huawei>display ospf lsdb summary 10.1.0.0

# 统计信息
<Huawei>display ospf lsdb statistics

# 输出示例：
 OSPF Process 1 with Router ID 1.1.1.1
         Link State Database Statistics
 
                 Area: 0.0.0.0
 Type      Count    Delete   Maxage
 Router    3        0        0
 Network   1        0        0
 Sum-Net   5        0        0
 Sum-Asbr  1        0        0
 External  2        0        0
 Nssa      0        0        0

# 清除LSDB（慎用！）
<Huawei>reset ospf process
```

---

## 八、OSPF路由计算

### 8.1 SPF算法

```
SPF (Shortest Path First) - Dijkstra算法

计算过程：

第一步：初始化
├─ 以本路由器为根
├─ Cost = 0
└─ 将自己放入SPF树

第二步：检查Type 1和Type 2 LSA
├─ 计算到每个邻居的Cost
├─ 选择Cost最小的邻居
└─ 将其加入SPF树

第三步：迭代计算
├─ 检查新加入节点的LSA
├─ 计算到其邻居的Cost
├─ 选择全局最小Cost
└─ 重复直到所有节点处理完

第四步：计算区域间路由
├─ 处理Type 3 LSA
├─ 计算到ABR的Cost
└─ 加上Type 3中的Metric

第五步：计算外部路由
├─ 处理Type 5 LSA
├─ 计算到ASBR的Cost
└─ E1累加Cost，E2不累加

SPF树示例：
                R1 (Root)
               /  |  \
           Cost1 Cost2 Cost3
             /    |     \
            R2    R3     R4
           / \          / \
         R5  R6        R7  R8
```

### 8.2 路由选择规则

```bash
OSPF路由优先级（从高到低）：

1. 区域内路由 (Intra-Area)
   ├─ O标记
   ├─ 来自Type 1和Type 2 LSA
   └─ 优先级最高

2. 区域间路由 (Inter-Area)
   ├─ O_IA标记
   ├─ 来自Type 3 LSA
   └─ 优先级中等

3. 外部路由E1 (External Type 1)
   ├─ O_ASE标记
   ├─ 来自Type 5 LSA
   ├─ Metric = 外部Cost + 内部Cost
   └─ 优先于E2

4. 外部路由E2 (External Type 2)
   ├─ O_ASE标记
   ├─ 来自Type 5 LSA
   ├─ Metric = 仅外部Cost
   └─ 优先级最低

# 查看路由表
<Huawei>display ip routing-table protocol ospf

# 输出示例：
Route Flags: R - relay, D - download to fib
Routing Tables: Public
         Destinations : 20       Routes : 20

Destination/Mask    Proto   Pre  Cost      Flags NextHop     Interface
10.1.0.0/24        OSPF    10   2         D   192.168.1.2  GE0/0/0  # Intra
10.2.0.0/24        O_IA    10   3         D   192.168.1.2  GE0/0/0  # Inter
172.16.0.0/16      O_ASE   150  20        D   192.168.1.3  GE0/0/0  # External
0.0.0.0/0          O_ASE   150  1         D   192.168.1.3  GE0/0/0  # Default

# 路由类型标识：
O      = OSPF区域内路由
O_IA   = OSPF区域间路由  
O_ASE  = OSPF外部路由
O_NSSA = OSPF NSSA外部路由

# Preference（管理距离）：
OSPF Internal: 10
OSPF External: 150
```

### 8.3 等价负载均衡

```bash
# OSPF支持等价路径负载均衡

# 默认最多4条等价路径
[Huawei-ospf-1]maximum load-balancing 4

# 修改为8条
[Huawei-ospf-1]maximum load-balancing 8

# 查看等价路由
<Huawei>display ip routing-table 10.1.0.0 verbose

# 输出示例：
Route Flags: R - relay, D - download to fib
Routing Table : Public
Summary Count : 1

Destination/Mask    Proto   Pre  Cost      Flags NextHop     Interface
10.1.0.0/24        OSPF    10   2         D   192.168.1.2  GE0/0/0
                                          D   192.168.2.2  GE0/0/1
                                          D   192.168.3.2  GE0/0/2

# 负载均衡算法：
# 基于源IP和目的IP的哈希值
# 同一数据流始终走同一路径

# 注意：
# 1. 必须Cost完全相同
# 2. 必须到达相同的目标
# 3. 下一跳可以不同
```

---

## 九、OSPF基础配置

### 9.1 单区域OSPF配置

```bash
# ========== 拓扑 ==========
#    R1 ---------- R2 ---------- R3
# .1/24  192.168.1.0/24  .2/24 .2/24  192.168.2.0/24  .3/24
#  G0/0/0              G0/0/0  G0/0/1             G0/0/0
#  Loop0: 1.1.1.1/32         Loop0: 2.2.2.2/32        Loop0: 3.3.3.3/32

# ========== R1配置 ==========
[Huawei]sysname R1
[R1]interface LoopBack 0
[R1-LoopBack0]ip address 1.1.1.1 32

[R1]interface GigabitEthernet 0/0/0
[R1-GigabitEthernet0/0/0]ip address 192.168.1.1 24
[R1-GigabitEthernet0/0/0]undo shutdown

# 启用OSPF
[R1]ospf 1 router-id 1.1.1.1
[R1-ospf-1]area 0
[R1-ospf-1-area-0.0.0.0]network 192.168.1.0 0.0.0.255
[R1-ospf-1-area-0.0.0.0]network 1.1.1.1 0.0.0.0

# ========== R2配置 ==========
[Huawei]sysname R2
[R2]interface LoopBack 0
[R2-LoopBack0]ip address 2.2.2.2 32

[R2]interface GigabitEthernet 0/0/0
[R2-GigabitEthernet0/0/0]ip address 192.168.1.2 24

[R2]interface GigabitEthernet 0/0/1
[R2-GigabitEthernet0/0/1]ip address 192.168.2.2 24

[R2]ospf 1 router-id 2.2.2.2
[R2-ospf-1]area 0
[R2-ospf-1-area-0.0.0.0]network 192.168.1.0 0.0.0.255
[R2-ospf-1-area-0.0.0.0]network 192.168.2.0 0.0.0.255
[R2-ospf-1-area-0.0.0.0]network 2.2.2.2 0.0.0.0

# ========== R3配置 ==========
[Huawei]sysname R3
[R3]interface LoopBack 0
[R3-LoopBack0]ip address 3.3.3.3 32

[R3]interface GigabitEthernet 0/0/0
[R3-GigabitEthernet0/0/0]ip address 192.168.2.3 24

[R3]ospf 1 router-id 3.3.3.3
[R3-ospf-1]area 0
[R3-ospf-1-area-0.0.0.0]network 192.168.2.0 0.0.0.255
[R3-ospf-1-area-0.0.0.0]network 3.3.3.3 0.0.0.0

# ========== 验证 ==========
# 检查邻居
<R1>display ospf peer brief

 OSPF Process 1 with Router ID 1.1.1.1
         Peer Statistic Information
 ----------------------------------------------------------------------------
 Area Id          Interface                        Neighbor id      State    
 0.0.0.0          GigabitEthernet0/0/0             2.2.2.2          Full        
 ----------------------------------------------------------------------------

# 检查路由
<R1>display ip routing-table protocol ospf

# 应该看到：
# 2.2.2.2/32 via 192.168.1.2
# 3.3.3.3/32 via 192.168.1.2
# 192.168.2.0/24 via 192.168.1.2

# 测试连通性
<R1>ping 3.3.3.3
```

### 9.2 多区域OSPF配置

```bash
# ========== 拓扑 ==========
#           Area 1                Area 0               Area 2
#    ┌────────────────┐    ┌─────────────────┐    ┌──────────────┐
#    │   R1 ─── R2   │────│  R3 (ABR)       │────│  R4 ─── R5   │
#    │  (IR)   (IR)  │    │                 │    │ (IR)   (IR)  │
#    └────────────────┘    └─────────────────┘    └──────────────┘
#   10.1.0.0/24                                     10.2.0.0/24
#   172.16.1.0/24     192.168.1.0/24          192.168.2.0/24  172.16.2.0/24

# ========== R1配置（Area 1内部路由器）==========
[R1]interface GigabitEthernet 0/0/0
[R1-GigabitEthernet0/0/0]ip address 10.1.1.1 24

[R1]interface GigabitEthernet 0/0/1
[R1-GigabitEthernet0/0/1]ip address 172.16.1.1 24

[R1]ospf 1 router-id 1.1.1.1
[R1-ospf-1]area 1
[R1-ospf-1-area-0.0.0.1]network 10.1.1.0 0.0.0.255
[R1-ospf-1-area-0.0.0.1]network 172.16.1.0 0.0.0.255

# ========== R2配置（Area 1内部路由器）==========
[R2]interface GigabitEthernet 0/0/0
[R2-GigabitEthernet0/0/0]ip address 10.1.1.2 24

[R2]interface GigabitEthernet 0/0/1
[R2-GigabitEthernet0/0/1]ip address 192.168.1.1 24

[R2]ospf 1 router-id 2.2.2.2
[R2-ospf-1]area 1
[R2-ospf-1-area-0.0.0.1]network 10.1.1.0 0.0.0.255
[R2-ospf-1]area 0
[R2-ospf-1-area-0.0.0.0]network 192.168.1.0 0.0.0.255

# R2是ABR（连接Area 0和Area 1）

# ========== R3配置（骨干路由器）==========
[R3]interface GigabitEthernet 0/0/0
[R3-GigabitEthernet0/0/0]ip address 192.168.1.2 24

[R3]interface GigabitEthernet 0/0/1
[R3-GigabitEthernet0/0/1]ip address 192.168.2.1 24

[R3]ospf 1 router-id 3.3.3.3
[R3-ospf-1]area 0
[R3-ospf-1-area-0.0.0.0]network 192.168.1.0 0.0.0.255
[R3-ospf-1-area-0.0.0.0]network 192.168.2.0 0.0.0.255

# ========== R4配置（Area 2 ABR）==========
[R4]interface GigabitEthernet 0/0/0
[R4-GigabitEthernet0/0/0]ip address 192.168.2.2 24

[R4]interface GigabitEthernet 0/0/1
[R4-GigabitEthernet0/0/1]ip address 10.2.1.1 24

[R4]ospf 1 router-id 4.4.4.4
[R4-ospf-1]area 0
[R4-ospf-1-area-0.0.0.0]network 192.168.2.0 0.0.0.255
[R4-ospf-1]area 2
[R4-ospf-1-area-0.0.0.2]network 10.2.1.0 0.0.0.255

# ========== R5配置（Area 2内部路由器）==========
[R5]interface GigabitEthernet 0/0/0
[R5-GigabitEthernet0/0/0]ip address 10.2.1.2 24

[R5]interface GigabitEthernet 0/0/1
[R5-GigabitEthernet0/0/1]ip address 172.16.2.1 24

[R5]ospf 1 router-id 5.5.5.5
[R5-ospf-1]area 2
[R5-ospf-1-area-0.0.0.2]network 10.2.1.0 0.0.0.255
[R5-ospf-1-area-0.0.0.2]network 172.16.2.0 0.0.0.255

# ========== 验证 ==========
# 在R1查看路由
<R1>display ip routing-table protocol ospf

# 应该看到：
# O      10.1.1.0/24         # 区域内
# O_IA   192.168.1.0/24      # 区域间（经ABR）
# O_IA   192.168.2.0/24      # 区域间
# O_IA   10.2.1.0/24         # 区域间
# O_IA   172.16.2.0/24       # 区域间

# 查看R2的ABR状态
<R2>display ospf brief
# Router Type: ABR

# 查看LSDB
<R2>display ospf lsdb
# 应该看到两个区域的LSDB

<R1>display ospf lsdb
# 只看到Area 1的LSDB
```

### 9.3 接口方式启用OSPF

```bash
# 方法一：在OSPF进程下使用network（推荐大规模网络）
[Huawei]ospf 1 router-id 1.1.1.1
[Huawei-ospf-1]area 0
[Huawei-ospf-1-area-0.0.0.0]network 192.168.1.0 0.0.0.255

# 方法二：在接口下启用OSPF（推荐小规模或精确控制）
[Huawei]ospf 1 router-id 1.1.1.1
[Huawei]interface GigabitEthernet 0/0/0
[Huawei-GigabitEthernet0/0/0]ospf enable 1 area 0

# 方法二的优点：
# 1. 更精确，不会误宣告其他接口
# 2. 配置清晰，易于理解
# 3. 便于接口级别的OSPF调优

# 实际应用示例：
[Huawei]ospf 1 router-id 1.1.1.1

# 内网接口启用OSPF
[Huawei]interface GigabitEthernet 0/0/0
[Huawei-GigabitEthernet0/0/0]ip address 192.168.1.1 24
[Huawei-GigabitEthernet0/0/0]ospf enable 1 area 0
[Huawei-GigabitEthernet0/0/0]ospf cost 10

# Loopback启用OSPF
[Huawei]interface LoopBack 0
[Huawei-LoopBack0]ip address 1.1.1.1 32
[Huawei-LoopBack0]ospf enable 1 area 0

# 外网接口不启用OSPF
[Huawei]interface GigabitEthernet 0/0/1
[Huawei-GigabitEthernet0/0/1]ip address 202.1.1.2 30
# 不配置ospf enable
```

---

## 十、OSPF高级配置

### 10.1 Router ID配置

```bash
# Router ID选举规则（优先级从高到低）：
# 1. 手动配置的Router ID
# 2. 最大Loopback接口IP
# 3. 最大物理接口IP

# 方法一：手动指定（推荐）
[Huawei]ospf 1 router-id 1.1.1.1

# 方法二：使用Loopback（推荐生产环境）
[Huawei]interface LoopBack 0
[Huawei-LoopBack0]ip address 1.1.1.1 32
[Huawei]ospf 1
# Router ID自动选择1.1.1.1

# 查看Router ID
<Huawei>display ospf brief
<Huawei>display ospf peer

# 修改Router ID
[Huawei]ospf 1
[Huawei-ospf-1]router-id 2.2.2.2
# Warning: The router-id is different from the one being used.
# The new router-id will be used after reset.

# 重启OSPF进程使生效
[Huawei-ospf-1]reset ospf process
# Reset OSPF process? [Y/N]:y

# 注意事项：
# 1. Router ID必须全网唯一
# 2. 建议使用Loopback接口IP作为Router ID
# 3. Loopback接口永远不会down
# 4. 修改Router ID会中断OSPF邻居关系
```

### 10.2 Cost调优

```bash
# 修改参考带宽（推荐在所有路由器统一配置）
[Huawei]ospf 1
[Huawei-ospf-1]bandwidth-reference 10000        # 10Gbps参考带宽

# 结果：
# 10M   = Cost 1000
# 100M  = Cost 100
# 1G    = Cost 10
# 10G   = Cost 1

# 方法一：修改接口Cost（优先级最高）
[Huawei]interface GigabitEthernet 0/0/0
[Huawei-GigabitEthernet0/0/0]ospf cost 50

# 方法二：修改接口带宽（影响Cost计算）
[Huawei-GigabitEthernet0/0/0]bandwidth-reference 10000

# 查看接口Cost
<Huawei>display ospf interface GigabitEthernet 0/0/0

# 输出示例：
 Interface: 192.168.1.1 (GigabitEthernet0/0/0)
 Cost: 1   State: DR   Type: Broadcast   MTU: 1500

# 实际应用：流量工程
# 场景：两条链路，希望流量走链路1
#
#        链路1 (1Gbps)
#    R1 ================= R2
#        链路2 (1Gbps)
#
# 默认两条链路Cost相同，会负载均衡
# 调整Cost使流量走链路1：

[R1]interface GigabitEthernet 0/0/0              # 链路1
[R1-GigabitEthernet0/0/0]ospf cost 10

[R1]interface GigabitEthernet 0/0/1              # 链路2
[R1-GigabitEthernet0/0/1]ospf cost 20            # 更高Cost，备份链路

# R2也做同样配置
[R2]interface GigabitEthernet 0/0/0
[R2-GigabitEthernet0/0/0]ospf cost 10

[R2]interface GigabitEthernet 0/0/1
[R2-GigabitEthernet0/0/1]ospf cost 20
```

### 10.3 被动接口

```bash
# 被动接口：接口宣告网络到OSPF，但不发送Hello报文

# 场景：
# 1. 用户接入网络（不需要建立OSPF邻居）
# 2. 管理网络
# 3. 防止不必要的OSPF流量

# 配置被动接口
[Huawei]ospf 1
[Huawei-ospf-1]silent-interface GigabitEthernet 0/0/2
[Huawei-ospf-1]silent-interface Vlanif 10

# 或在接口下配置
[Huawei]interface GigabitEthernet 0/0/2
[Huawei-GigabitEthernet0/0/2]ospf enable 1 area 0
[Huawei-GigabitEthernet0/0/2]ospf silent-interface

# 配置所有接口为被动（然后单独激活需要的）
[Huawei-ospf-1]silent-interface all
[Huawei-ospf-1]undo silent-interface GigabitEthernet 0/0/0
[Huawei-ospf-1]undo silent-interface GigabitEthernet 0/0/1

# 查看被动接口
<Huawei>display ospf interface

# 完整配置示例：
[Huawei]ospf 1 router-id 1.1.1.1
# 激活OSPF的接口
[Huawei]interface GigabitEthernet 0/0/0
[Huawei-GigabitEthernet0/0/0]ospf enable 1 area 0  # 建立邻居

# 宣告但不建立邻居的接口
[Huawei]interface GigabitEthernet 0/0/1
[Huawei-GigabitEthernet0/0/1]ospf enable 1 area 0
[Huawei-GigabitEthernet0/0/1]ospf silent-interface  # 被动接口

# 结果：
# - G0/0/0的网络会通过OSPF宣告
# - G0/0/1的网络也会通过OSPF宣告
# - 但G0/0/1不会发送Hello，不会建立邻居
```

### 10.4 默认路由发布

```bash
# 场景：边界路由器向内网发布默认路由

# 方法一：始终发布（推荐）
[Huawei-ospf-1]default-route-advertise always

# 方法二：有默认路由时才发布
[Huawei-ospf-1]default-route-advertise

# 指定Cost和类型
[Huawei-ospf-1]default-route-advertise always cost 10 type 1
[Huawei-ospf-1]default-route-advertise always cost 20 type 2  # 默认

# 配合路由策略
[Huawei]route-policy DEFAULT permit node 10
[Huawei-route-policy]apply cost 100
[Huawei-route-policy]apply tag 100

[Huawei-ospf-1]default-route-advertise route-policy DEFAULT

# 完整示例：企业网关
# R1是企业出口路由器

# R1配置：
[R1]interface GigabitEthernet 0/0/0
[R1-GigabitEthernet0/0/0]ip address 192.168.1.1 24  # 内网
[R1-GigabitEthernet0/0/0]ospf enable 1 area 0

[R1]interface GigabitEthernet 0/0/1
[R1-GigabitEthernet0/0/1]ip address 202.1.1.2 30   # 外网（ISP）

# 配置默认路由指向ISP
[R1]ip route-static 0.0.0.0 0 202.1.1.1

# 在OSPF中发布默认路由
[R1]ospf 1
[R1-ospf-1]default-route-advertise always cost 1 type 1

# 内网路由器收到默认路由
<R2>display ip routing-table protocol ospf
# 0.0.0.0/0   O_ASE  150  1   192.168.1.1

# NSSA区域默认路由
[ABR-ospf-1]area 1
[ABR-ospf-1-area-0.0.0.1]nssa default-route-advertise
```

### 10.5 路由过滤

```bash
# OSPF路由过滤（入站/出站）

# 创建ACL
[Huawei]acl 2000
[Huawei-acl-basic-2000]rule deny source 10.1.0.0 0.0.255.255
[Huawei-acl-basic-2000]rule permit source any

# 应用过滤（入站）
[Huawei]ospf 1
[Huawei-ospf-1]filter-policy 2000 import         # 过滤接收的路由

# 应用过滤（出站）- ABR/ASBR
[Huawei-ospf-1]filter-policy 2000 export         # 过滤发布的路由

# 使用IP前缀列表（更精确）
[Huawei]ip ip-prefix DENY-10 deny 10.0.0.0 8 greater-equal 24 less-equal 32
[Huawei]ip ip-prefix DENY-10 permit 0.0.0.0 0 less-equal 32

[Huawei-ospf-1]filter-policy ip-prefix DENY-10 import

# ABR过滤Type 3 LSA
[Huawei-ospf-1]area 1
[Huawei-ospf-1-area-0.0.0.1]filter 2000 import   # 过滤进入该区域的Type 3
[Huawei-ospf-1-area-0.0.0.1]filter 2000 export   # 过滤从该区域出去的Type 3

# 实际案例：
# 场景：Area 1不希望学习到Area 2的10.2.0.0/16网段

# ABR配置：
[ABR]acl 2001
[ABR-acl-basic-2001]rule deny source 10.2.0.0 0.0.255.255
[ABR-acl-basic-2001]rule permit source any

[ABR]ospf 1
[ABR-ospf-1]area 1
[ABR-ospf-1-area-0.0.0.1]filter 2001 import      # Area 1不接收10.2.0.0/16

# 验证：
<R1-in-Area1>display ip routing-table | include 10.2
# 不应该有10.2.x.x的路由
```

### 10.6 路由引入

```bash
# 将其他协议路由引入OSPF

# 引入静态路由
[Huawei-ospf-1]import-route static

# 引入直连路由
[Huawei-ospf-1]import-route direct

# 引入RIP
[Huawei-ospf-1]import-route rip 1

# 指定Cost和类型
[Huawei-ospf-1]import-route static cost 100 type 1
[Huawei-ospf-1]import-route static cost 50 type 2   # 默认type 2

# 使用路由策略精确控制
[Huawei]route-policy STATIC-TO-OSPF permit node 10
[Huawei-route-policy]if-match ip-prefix ALLOW-LIST
[Huawei-route-policy]apply cost 20
[Huawei-route-policy]apply tag 100

[Huawei]route-policy STATIC-TO-OSPF deny node 20
# 拒绝其他路由

[Huawei-ospf-1]import-route static route-policy STATIC-TO-OSPF

# 完整示例：双协议环境
# R1运行OSPF和RIP，需要相互引入

[R1]ospf 1 router-id 1.1.1.1
[R1-ospf-1]area 0
[R1-ospf-1-area-0.0.0.0]network 192.168.1.0 0.0.0.255

[R1]rip 1
[R1-rip-1]version 2
[R1-rip-1]network 10.0.0.0

# OSPF引入RIP（注意：会成为ASBR）
[R1]route-policy RIP-TO-OSPF permit node 10
[R1-route-policy]if-match tag 10
[R1-route-policy]apply cost 50

[R1-ospf-1]import-route rip 1 route-policy RIP-TO-OSPF

# RIP引入OSPF
[R1]route-policy OSPF-TO-RIP permit node 10
[R1-route-policy]apply cost 5

[R1-rip-1]import-route ospf 1 route-policy OSPF-TO-RIP

# 设置Tag防止路由环路
[R1-route-policy]apply tag 100

# 验证
<R1>display ospf brief
# Router Type: ASBR  （成为ASBR）

<R1>display ospf lsdb ase
# 应该看到引入的RIP路由（Type 5 LSA）
```

---
