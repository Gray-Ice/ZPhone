## ZPhone

In development, not ready for use.
开发中，还不能用。

## TODO List

| 任务 | 优先级 | 目前实现状态 |
|:--:| :---: | :---: |
| 内网设备扫描图形化展示 | 高 | √ |
| Provider改变UI状态 | 中 | X |
| 开启Dart服务端 | 中 | X |
| 更改内网发现服务器方式为ARP或广播 | 中 | X |
| Dart客户端全局共享 | 高 | X |


## 预实现功能细节
 -[ ] Dart客户端。要求: 全局共享一个Channel，用于向Dart服务端发送数据。开启App自动连接上一次连接的Dart服务端（如果还能连上的话）。