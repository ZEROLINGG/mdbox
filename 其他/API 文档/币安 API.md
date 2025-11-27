下面在前一版文档的基础上，把币安 API 体系里之前没有展开的部分补齐，使整体更接近一份「完整开发参考」。为避免重复，前面已经讲过的内容（现货基础行情 / 下单 / 合约基础等）不再逐条重写，只补充新模块或遗漏的高频接口。

> 所有路径与参数以官方文档为准，这里以主站为例：  
> - 现货 & 钱包：`https://api.binance.com`  
> - USDT 合约：`https://fapi.binance.com`  
> - COIN-M 合约：`https://dapi.binance.com`  
> - 期权：`https://eapi.binance.com`  
> - WebSocket：现货 `wss://stream.binance.com:9443`，USDT 合约 `wss://fstream.binance.com`，COIN-M 合约 `wss://dstream.binance.com`，期权 `wss://eapi.binance.com/stream`

---

## 12. 现货 REST 交易/账户接口补充（/api + /sapi）

### 12.1 测试单 `/api/v3/order/test`

- 方法：`POST`
- 安全：SIGNED
- 功能：验证参数合法性、签名、权限等，不会真正下单，也不会计入成交/委托。
- 参数：与 `/api/v3/order` 完全一致。
- 返回：`{}` 或错误码。

适合部署前、回测环境或策略切换时做干跑（dry run）检查。

---

### 12.2 OCO（One-Cancels-the-Other）订单

#### 12.2.1 下 OCO 单 `/api/v3/order/oco`

- 方法：`POST`
- 安全：SIGNED

核心参数（精简）：

| 参数               | 必填 | 说明                                                |
|--------------------|------|-----------------------------------------------------|
| symbol             | 是   | 交易对                                              |
| side               | 是   | `BUY` / `SELL`                                     |
| quantity           | 是   | 总数量                                              |
| price              | 是   | 限价腿价格（止盈腿）                               |
| stopPrice          | 是   | 止损触发价                                          |
| stopLimitPrice     | 否   | 止损限价（若 type=STOP_LOSS_LIMIT）                 |
| stopLimitTimeInForce | 否 | 止损限价腿 `GTC` 等                                |
| listClientOrderId  | 否   | OCO 订单组 ID                                       |
| limitClientOrderId | 否   | 限价腿 clientOrderId                               |
| stopClientOrderId  | 否   | 止损腿 clientOrderId                               |

- 返回：包含一个 “订单列表对象”，内含两条实际订单（限价+止损），以及该列表的状态。

#### 12.2.2 查询/撤销 OCO

- 查询单个：`GET /api/v3/orderList`
- 查询所有：`GET /api/v3/allOrderList`
- 当前未触发列表：`GET /api/v3/openOrderList`
- 撤销 OCO：`DELETE /api/v3/orderList`

---

### 12.3 历史成交记录 `/api/v3/myTrades`（现货）

- 方法：`GET`
- 安全：SIGNED
- 参数：

| 参数      | 必填 | 说明                       |
|-----------|------|----------------------------|
| symbol    | 是   |                            |
| startTime | 否   | 毫秒                       |
| endTime   | 否   | 毫秒                       |
| fromId    | 否   | 起始成交 ID               |
| limit     | 否   | 默认 500，最大 1000        |

用于对账和回溯成交明细。

---

### 12.4 交易手续费查询 `/sapi/v1/asset/tradeFee`

- 方法：`GET`
- 安全：SIGNED
- 功能：查询每个 symbol 当前实际生效的 maker/taker 手续费（考虑 VIP 等级、BNB 折扣）。
- 参数：
  - `symbol`：可选，单个 symbol；不传则返回所有。

---

### 12.5 账户快照 `/sapi/v1/accountSnapshot`

- 方法：`GET`
- 安全：SIGNED
- 功能：获取日级资产快照，可选类型：`SPOT` / `MARGIN` / `FUTURES`。
- 常用参数：
  - `type`：必填
  - `startTime`, `endTime`, `limit`

适合做日终对账、净值曲线计算。

---

### 12.6 系统状态 `/sapi/v1/system/status`

- 方法：`GET`
- 安全：PUBLIC
- 返回系统是否在维护、部分功能受限等；偶尔在全站维护时查询。

---

### 12.7 充提与钱包信息（简要）

常用钱包类接口路径前缀：`/sapi/v1/capital/...`

- 币种及网络信息：`GET /sapi/v1/capital/config/getall`
  - 资产是否可充提、最小提币数量、网络（ERC20、TRC20 等）
- 提币：`POST /sapi/v1/capital/withdraw/apply`（务必在安全环境调用）
- 充币记录：`GET /sapi/v1/capital/deposit/hisrec`
- 提币记录：`GET /sapi/v1/capital/withdraw/history`

这些接口均为 SIGNED，参数与安全性要求较高，生产上通常集中管理，不直接暴露给策略程序。

---

## 13. 杠杆（Margin）交易 REST（/sapi）

币安杠杆分为：

- **全仓 Cross Margin**
- **逐仓 Isolated Margin**

### 13.1 公共与账户信息

- 全部支持杠杆的交易对：`GET /sapi/v1/margin/allPairs`
- 全局杠杆配置：`GET /sapi/v1/margin/allAssets`
- 杠杆价格指数：`GET /sapi/v1/margin/priceIndex?symbol=BTCUSDT`

#### 13.1.1 全仓账户信息 `/sapi/v1/margin/account`

- 方法：`GET`
- 安全：SIGNED
- 返回：
  - 各资产的 free / locked / borrowed / interest
  - 总资产价值、总负债、净资产
  - 强平风险率等

#### 13.1.2 逐仓账户信息 `/sapi/v1/margin/isolated/account`

- 方法：`GET`
- 安全：SIGNED
- 参数：
  - `symbols`：如 `"BTCUSDT,ETHUSDT"`

返回每个逐仓对的：

- base / quote free、borrowed、interest
- 杠杆倍数、强平价等。

---

### 13.2 杠杆资金划转

#### 13.2.1 全仓现货 ↔ 杠杆 `/sapi/v1/margin/transfer`

- 方法：`POST`
- 安全：SIGNED

| 参数     | 说明                                  |
|----------|---------------------------------------|
| asset    | 币种                                  |
| amount   | 金额                                  |
| type     | 1: 现货 → 杠杆，2: 杠杆 → 现货        |

#### 13.2.2 逐仓 ↔ 现货 `/sapi/v1/margin/isolated/transfer`

- 方法：`POST`
- 参数新增：
  - `symbol`：交易对，如 `BTCUSDT`
  - `transFrom` / `transTo`：`SPOT` / `ISOLATED_MARGIN`

---

### 13.3 借币与还币

#### 13.3.1 借币 `/sapi/v1/margin/loan`

- 方法：`POST`
- 参数：

| 参数   | 说明        |
|--------|-------------|
| asset  | 币种        |
| amount | 借币数量    |
| isIsolated | 可选，true 表示逐仓 |
| symbol | 逐仓时必填 |

#### 13.3.2 还币 `/sapi/v1/margin/repay`

- 方法：`POST`
- 参数与 loan 类似。

可配合：

- 可借最大额度：`GET /sapi/v1/margin/maxBorrowable`
- 可转出最大额度：`GET /sapi/v1/margin/maxTransferable`

---

### 13.4 杠杆下单接口（与现货几乎相同）

路径从 `/api` 换成 `/sapi/v1/margin/...`：

- 下单：`POST /sapi/v1/margin/order`
- 撤单：`DELETE /sapi/v1/margin/order`
- 查询单：`GET /sapi/v1/margin/order`
- 未结订单：`GET /sapi/v1/margin/openOrders`
- 历史订单：`GET /sapi/v1/margin/allOrders`
- 历史成交：`GET /sapi/v1/margin/myTrades`

与现货下单主要区别：

- 需指定 `sideEffectType` 表示是否「借币开仓 / 还币平仓」等，例如：
  - `NO_SIDE_EFFECT`
  - `MARGIN_BUY`（借 quote 买入）
  - `AUTO_REPAY`（成交后用多余资产自动还款）

示例（全仓，市价借 USDT 买入 BTC）：

```bash
symbol=BTCUSDT
side=BUY
type=MARKET
quantity=0.001
sideEffectType=MARGIN_BUY
timestamp=...
signature=...
```

---

### 13.5 杠杆 User Data Stream（WS）

- 全仓 listenKey：
  - 创建：`POST /sapi/v1/userDataStream`
  - 保活：`PUT /sapi/v1/userDataStream`
- 逐仓 listenKey：
  - 创建：`POST /sapi/v1/userDataStream/isolated?symbol=BTCUSDT`
  - 保活：`PUT /sapi/v1/userDataStream/isolated?symbol=BTCUSDT`

WS URL 与现货相同：`wss://stream.binance.com:9443/ws/<listenKey>`

事件内容会在现货事件基础上增加杠杆字段，如：

- 是否来自 margin
- 利息计提变动
- 强平预警等

---

## 14. Wallet / 资金相关 REST（/sapi）

这一部分功能很多，这里只按大类概述常见接口。

### 14.1 资产与余额视图

- `GET /sapi/v1/capital/config/getall`：列出所有资产及其可用网络、最小取款等。
- `GET /sapi/v1/asset/getUserAsset`：查询钱包资产（spot 钱包整体汇总），不同于 `/api/v3/account` 的交易视图。

---

### 14.2 资金账户 / Funding Wallet

币安引入“资金账户”（Funding），用于 P2P、卡券等，不推荐策略用户高频操作，但需要知道存在：

- 划转：`POST /sapi/v1/asset/transfer`
  - `type`（SPOT ↔ FUNDING 等）
- 查询资金账户余额：`GET /sapi/v1/asset/getFundingAsset`

---

### 14.3 手续费、VIP 等级

- 交易手续费（按 symbol）：`GET /sapi/v1/asset/tradeFee`（前面已提）
- 资产手续费/佣金等更详细信息：部分在 `/sapi/v1/account` 或 VIP 专用 API 中提供（需特殊权限）。

---

## 15. 理财/Earn、Staking、杠杆代币等概览（/sapi）

这部分接口通常不在高频交易策略中使用，但对“资金整体管理+理财复利”很重要，这里只做结构性说明。

### 15.1 活期/定期理财（Savings / Flexible Saving）

典型接口（路径前缀 `/sapi/v1/lending`）：

- 活期产品列表：`GET /sapi/v1/lending/daily/product/list`
- 申购活期：`POST /sapi/v1/lending/daily/purchase`
- 赎回活期：`POST /sapi/v1/lending/daily/redeem`
- 固定理财产品列表：`GET /sapi/v1/lending/project/list`
- 申购/赎回固定：`POST /sapi/v1/lending/customizedFixed/purchase` 等

参数核心包括：

- `productId` / `projectId`
- `amount`
- `lot`（有的固定理财按份）

---

### 15.2 Staking / 简单赚币

路径前缀 `/sapi/v1/staking`：

- `GET /sapi/v1/staking/productList`
- `POST /sapi/v1/staking/purchase`
- `POST /sapi/v1/staking/redeem`
- `GET /sapi/v1/staking/position`

用于 BNB/ETH 等 POS 币种质押挖矿收益。

---

### 15.3 杠杆代币（BLVT）

路径前缀 `/sapi/v1/blvt`：

- `GET /sapi/v1/blvt/tokenInfo`：代币信息（如 BTCUP/BTCDOWN）
- `POST /sapi/v1/blvt/subscribe` / `redeem`：申购/赎回

WS 上还有 BLVT NAV K 线流，示例格式：`btcusdt@nav_Kline_1m`（具体以官方为准），提供杠杆代币净值的时间序列。

---

### 15.4 AMM & BSwap（流动性池）

路径前缀 `/sapi/v1/bswap`：

- `GET /sapi/v1/bswap/pools`：池子列表
- `GET /sapi/v1/bswap/liquidity`：我的流动性
- `POST /sapi/v1/bswap/liquidityAdd` / `liquidityRemove`：添加/移除 LP
- `POST /sapi/v1/bswap/swap`：池内兑换

---

## 16. USDT 合约 REST 进阶（/fapi）

在前文基础上补充更多高频接口与参数。

### 16.1 调整杠杆倍数 `/fapi/v1/leverage`

- 方法：`POST`
- 安全：SIGNED
- 参数：

| 参数   | 说明                  |
|--------|-----------------------|
| symbol | BTCUSDT 等            |
| leverage | 杠杆倍数（整数）   |

返回调整后的实际杠杆及最大可用名义。

---

### 16.2 调整保证金模式 `/fapi/v1/marginType`

- 方法：`POST`
- 参数：

| 参数       | 说明                         |
|------------|------------------------------|
| symbol     |                              |
| marginType | `ISOLATED` 或 `CROSSED`     |

注意：已有持仓时，部分方向/模式可能不允许切换。

---

### 16.3 对冲模式 / 单向持仓模式 `/fapi/v1/positionSide/dual`

- 设置模式：
  - `POST /fapi/v1/positionSide/dual`
  - 参数：`dualSidePosition=true/false`
    - `true`：对冲模式（LONG/SHORT 分开记）
    - `false`：单向模式（只有一个 `BOTH` 仓位）

- 查询模式：
  - `GET /fapi/v1/positionSide/dual`

---

### 16.4 合约账户与持仓

- 账户信息（含资产余额、钱包余额、保证金、PNL 等）：
  - `GET /fapi/v2/account`
- 持仓风险信息：
  - `GET /fapi/v2/positionRisk`
  - 建议用于展示持仓视图和计算强平风险。

---

### 16.5 合约订单接口补充

与现货类似，多了批量接口：

- 批量下单：`POST /fapi/v1/batchOrders`
  - `batchOrders`：JSON 数组字符串，每个元素是单独订单参数对象
- 批量撤单：`DELETE /fapi/v1/batchOrders`
- 强平订单等特殊接口详见官方文档。

---

### 16.6 收益记录 `/fapi/v1/income`

- 方法：`GET`
- 用于查询：
  - 资金费（funding）
  - 交易手续费
  - 强平损益
  - 保证金转入/转出 等

常用参数：

| 参数      | 说明                          |
|-----------|-------------------------------|
| symbol    | 可选                          |
| incomeType| `FUNDING_FEE` / `REALIZED_PNL` 等 |
| startTime | 毫秒                          |
| endTime   | 毫秒                          |
| limit     | 条数                           |

非常重要的对账数据源。

---

### 16.7 USDT 合约 WebSocket 补充流

前文已提：

- 成交流 `<symbol>@trade` / `<symbol>@aggTrade`
- K 线 `<symbol>@kline_1m`
- 标记价格/资金费 `<symbol>@markPrice` / `!markPrice@arr`
- 深度 `<symbol>@depth@100ms`
- 强平订单 `!forceOrder@arr` / `<symbol>@forceOrder`
- User Data Stream（`ORDER_TRADE_UPDATE`、`ACCOUNT_UPDATE`）

再补充一个常用流：

#### 16.7.1 合约最优买卖一档 `<symbol>@bookTicker`

- URL：`wss://fstream.binance.com/ws/btcusdt@bookTicker`
- 消息字段与现货 bookTicker 非常相似：

```json
{
  "u": 400900217,
  "s": "BTCUSDT",
  "b": "30000.10",
  "B": "0.5",
  "a": "30000.20",
  "A": "0.4"
}
```

可用于撮合时的报价参考或基础做市策略。

---

## 17. COIN-M 合约 REST & WS（/dapi, wss://dstream）

COIN-M（币本位）合约与 USDT-M 类似，只是保证金与计价单位基于币种（BTC、ETH 等），接口前缀不同。

### 17.1 基本信息与行情

REST 基础 URL：`https://dapi.binance.com`

- 交易规则：`GET /dapi/v1/exchangeInfo`
- 深度：`GET /dapi/v1/depth`
- K 线：`GET /dapi/v1/klines`
- ticker：`/dapi/v1/ticker/price`、`/ticker/bookTicker` 等

字段设计几乎与 `/fapi` 对应，只是合约大小与单位不同，需特别留意：

- 名义价值：可能以 USD 表示，但保证金以 BTC 等结算
- 合约乘数（contractSize）不同

---

### 17.2 COIN-M 账户与下单

- 下单：`POST /dapi/v1/order`
- 撤单：`DELETE /dapi/v1/order`
- 查询订单：`GET /dapi/v1/order`
- 当前委托：`GET /dapi/v1/openOrders`
- 历史订单：`GET /dapi/v1/allOrders`
- 账户信息：`GET /dapi/v1/account` 或 `/dapi/v2/account`
- 持仓信息：`GET /dapi/v1/positionRisk`

参数与 USDT-M 高度一致（`symbol`, `side`, `positionSide`, `type`, `quantity`, `price`, `timeInForce` 等），只是在使用上要注意：

- 数量单位（合约张数 vs 币）在不同品种定义略有差别，务必从 `exchangeInfo` 中读取 `contractSize`。

---

### 17.3 COIN-M WebSocket

- 单流：`wss://dstream.binance.com/ws/<streamName>`
- 组合流：`wss://dstream.binance.com/stream?streams=...`

常见流与 USDT-M 对应：

- `<symbol>@trade` / `<symbol>@aggTrade`
- `<symbol>@kline_1m`
- `<symbol>@depth@100ms`
- `<symbol>@bookTicker`
- `<symbol>@markPrice`
- `!markPrice@arr`
- 强平流：`!forceOrder@arr`

User Data Stream：

- 创建 listenKey：`POST /dapi/v1/listenKey`
- WS：`wss://dstream.binance.com/ws/<listenKey>`
- 事件类型与 USDT-M 几乎相同（`ORDER_TRADE_UPDATE`, `ACCOUNT_UPDATE`, `MARGIN_CALL` 等）。

---

## 18. 期权（Options，/eapi）简要

币安欧式期权 API 较为专业，这里只做结构性说明，主要用于：

- 做期权做市或对冲
- 构建波动率曲线与希腊值计算

### 18.1 REST 概览（/eapi/v1）

基础 URL：`https://eapi.binance.com`

高频接口（名称可能会有版本变化，以下为常见类型）：

- 交易规则：`GET /eapi/v1/exchangeInfo`
- 行情：
  - `GET /eapi/v1/depth`：盘口
  - `GET /eapi/v1/trades`：成交
  - `GET /eapi/v1/ticker`：24h 行情
  - `GET /eapi/v1/klines`：K 线
- 下单与账户：
  - `POST /eapi/v1/order`
  - `DELETE /eapi/v1/order`
  - `GET /eapi/v1/openOrders` / `/allOrders`
  - `GET /eapi/v1/position`
  - `GET /eapi/v1/account`

参数设计与现货/期货类似，但 symbol 命名体现到期日、执行价与看涨看跌，如：

- `BTC-240628-50000-C`（2024-06-28 到期、行权价 50000、看涨）

实际项目中建议直接读取 `/exchangeInfo` 获取可交易合约列表及其含义。

---

### 18.2 期权 WebSocket

基础 WS：`wss://eapi.binance.com/stream?streams=...`（实际前缀以文档为准）

常见流类型：

- `<symbol>@trade`：期权成交
- `<symbol>@depth`：盘口
- `<symbol>@ticker`：24h ticker
- `<symbol>@kline_1m`：K 线
- User Data Stream：通过 `/eapi/v1/listenKey` 创建，再连接 WS 监听订单和账户更新。

期权对延迟和数据一致性要求比现货/合约更高，实战建议：

- 不要用 REST 轮询下单状态，必须使用 User Data Stream。
- 做市时本地维护完整订单簿（depth + snapshot），并对隐含波动率等做缓存。

---

## 19. WebSocket 细节补充

### 19.1 ws 与 stream 两种模式

- **单流**：`/ws/<streamName>`
  - 一条连接只订阅一个流
- **组合流**：`/stream?streams=<stream1>/<stream2>/...`
  - 一条连接可订阅多个流
  - 消息格式外层套一层：

```json
{
  "stream": "btcusdt@trade",
  "data": { ... 实际事件 ... }
}
```

---

### 19.2 ping/pong 与心跳

- 币安 WS 通常会由服务器主动发 ping/pong 或仅作为 TCP 长连接保持机制，客户端一般不需要主动发 ping 帧（具体由 WebSocket 库处理）。
- 推荐在客户端实现**应用层心跳**：
  - 例如记录最后一条行情收到时间，如果超过 X 秒没有新消息，主动断开并重连。
  - 重连后需要：
    - 重新订阅所有流
    - 对于深度和 User Data Stream，严格按官方步骤做「快照 + 增量回放」。

---

### 19.3 User Data Stream 分类一览

| 类型        | 创建 REST 路径                         | WS URL 前缀                        |
|-------------|----------------------------------------|------------------------------------|
| 现货 Spot   | `POST /api/v3/userDataStream`         | `wss://stream.binance.com:9443/ws` |
| 全仓 Margin | `POST /sapi/v1/userDataStream`        | 同上                               |
| 逐仓 Margin | `POST /sapi/v1/userDataStream/isolated`| 同上                               |
| USDT-M 合约 | `POST /fapi/v1/listenKey`             | `wss://fstream.binance.com/ws`     |
| COIN-M 合约 | `POST /dapi/v1/listenKey`             | `wss://dstream.binance.com/ws`     |
| 期权        | `POST /eapi/v1/listenKey`（以文档为准）| `wss://eapi.binance.com/stream`    |

所有 User Data Stream 都要：

- **30–60 分钟内周期性保活**（PUT 同一路径）
- 用完及时 DELETE 释放。

---

## 20. 速率限制（Rate Limit）补充

### 20.1 权重与 HTTP 响应头

币安在响应头中返回当前使用情况（根据接口略有不同），常见如：

- `X-MBX-USED-WEIGHT-1M`：当前 IP 或账号 1 分钟内使用的总权重
- `X-MBX-ORDER-COUNT-1M`：当前账号 1 分钟内下单次数

每个接口在官方文档中有 `weight` 值，例如：

- `GET /api/v3/depth?limit=100`：weight=1
- `GET /api/v3/depth?limit=5000`：weight=50（举例）

**建议**：

- 在客户端中读取这些 header，根据剩余额度动态限速。
- 出现 429 时，立即暂停一段时间（指数退避），不要立刻重试。

---

### 20.2 不同维度的限制

典型限制维度：

1. **IP 维度 weight 限制**（公共接口为主）
2. **账号维度 weight 限制**（交易与账户接口）
3. **下单速率限制**（每秒/每分钟订单数）
4. **User Data Stream 限制**（同时存活 listenKey 数量、创建次数）

高频策略开发时务必：

- 设计本地限流模块（token bucket）
- 对下单逻辑集中管理（所有策略经由统一的「交易路由」下单）

---

## 21. 安全与工程实践建议

### 21.1 Key 管理

- API Key 按功能拆分：
  - 行情只读 Key（不开启交易权限）
  - 交易 Key（不开启提币权限）
  - 提币 Key（仅在极少数自动化出入金系统中使用）
- 必须使用 **IP 白名单**。
- 秘钥（secret）绝不写死在代码仓库中：
  - 环境变量
  - 配置中心 / 密钥管理系统

---

### 21.2 容错与重试

- 所有 SIGNED 请求要处理：
  - `-1021 Timestamp`：时间差问题，自动同步服务器时间/放宽 recvWindow。
  - `-2010`, `-2011` 等下单相关错误：记录日志、根据业务逻辑决定是否重试。
- 对 5xx 错误：
  - 指数退避（例如 1s, 2s, 4s, 8s…），避免「雪崩式」重试风暴。
- 对 WS 断线：
  - 自动重连
  - 重建订阅
  - 深度流/用户流按「快照 + 增量」规范恢复。

---

### 21.3 本地状态与对账

无论现货还是合约，推荐：

1. **本地维护订单与成交状态**：
   - 收到 REST 下单回包 → 写本地状态
   - 收到 User Data Stream 的 `executionReport` / `ORDER_TRADE_UPDATE` → 更新本地
2. 每隔一段时间（例如每 5–10 分钟）：
   - 用 REST 的 `openOrders` / `allOrders` / `myTrades` 做对账：
     - 检查是否有漏掉的订单状态变更
     - 校验持仓/余额与本地记录是否一致

---
