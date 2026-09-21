import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../base/extension/build_context_extension.dart';

/// [ 扫描发现 ]
///      │
///      ▼
///  AVAILABLE (可用) ──(发起 connect())──► INVITED (邀请/协商中)
///                                              │
///                        ┌─────────────────────┴─────────────────────┐
///                        ▼                                           ▼
///              CONNECTED (已连接)                               FAILED (失败)
///                        │                                           │
///              (断开连接 / 离开群组)                                 │
///                        └─────────────────────┬─────────────────────┘
///                                              ▼
///                                      AVAILABLE / UNAVAILABLE
enum DeviceStatus {
  /// CONNECTED (数值: 0)
  /// 含义： 已连接。
  /// 状态说明： P2P 协商成功，Wi-Fi Direct 组群（Group）已成功建立，该设备已成为组内成员（作为 GO 组长或 Client 客户端）。
  /// 验证与下一步： 处于此状态并不代表 TCP/UDP 套接字已连通，成功连接后需调用 requestConnectionInfo() 来获取组长的 IP 地址（Group Owner IP），进而建立 Socket 进行数据传输。
  connected(
    status: 0,
    desc: "设备已连接",
  ),
  /// INVITED (数值: 1)
  /// 含义： 已邀请 / 连接协商中。
  /// 状态说明： 已经向该设备发送了 P2P 连接请求（或收到了对方发来的连接请求），目前双方正在进行 Group Owner (GO) 协商（GO Negotiation）或在等待用户在界面上确认同意连接（弹出 PIN 码或确认弹窗）。
  /// 典型场景： 调用 connect() 之后、正式建立连接之前的过渡状态。
  invited(
    status: 1,
    desc: "设备连接中",
  ),
  /// FAILED (数值: 2)
  /// 含义： 连接失败。
  /// 状态说明： 之前的连接尝试（GO 协商、PIN 码校验、超时等）出现异常而终止，未能成功建立 P2P 群组。
  /// 典型场景： 对方拒绝了连接邀请、连接超时、或者 GO 协商失败。此时设备无法直接传输数据，通常需要重新扫描或重新发起连接。
  failed(
    status: 2,
    desc: "设备连接失败",
  ),
  /// AVAILABLE (数值: 3)
  /// 含义： 可用/可连接。
  /// 状态说明： 该设备已被当前的 P2P 扫描（Discovery）搜索到，处于广播状态且没有加入其他 P2P 群组（或作为独立设备可接受邀请）。
  /// 典型场景： 刚执行完 discoverPeers()，被发现的对端设备绝大多数处于此状态，此时可以对其调用 connect() 发起连接请求。
  available(
    status: 3,
    desc: "设备可用",
  ),
  /// UNAVAILABLE (数值: 4)
  /// 含义： 不可用。
  /// 状态说明： 该设备已被系统感知，但目前无法进行 P2P 连接。
  /// 典型场景：
  ///    设备的 Wi-Fi 或 Wi-Fi Direct 功能被关闭。
  ///    该设备已经加入了另一个不支持多连接的 P2P 群组。
  ///    设备超出了信号覆盖范围，但其缓存尚未被彻底清除。
  unavailable(
    status: 4,
    desc: "设备不可用",
  );

  final int status;
  final String desc;

  const DeviceStatus({required this.status, required this.desc});

  /// 根据状态码解析枚举类型
  static DeviceStatus fromStatus(int? status) {
    if (status == null) {
      return DeviceStatus.unavailable;
    }
    return DeviceStatus.values.firstWhere(
          (element) => element.status == status,
      orElse: () => DeviceStatus.unavailable,
    );
  }

  Color parseDeviceColor(BuildContext context) {
    switch(this) {
      case DeviceStatus.connected:
        return context.colorScheme.primary; // 深绿色
      case DeviceStatus.invited:
        return context.colorScheme.primaryFixed; // 绿色
      case DeviceStatus.available:
        return context.colorScheme.tertiary; // 蓝色
      case DeviceStatus.failed:
        return context.colorScheme.error; // 红色
      case DeviceStatus.unavailable:
        return context.colorScheme.secondaryFixedDim; // 灰色
    }
  }
}