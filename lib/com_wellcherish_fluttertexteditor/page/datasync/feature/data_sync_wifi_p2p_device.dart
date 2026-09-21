import 'dart:convert';
import 'dart:core';

import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/data_sync_service.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/device_status.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/datasync/feature/device_type.dart';

/// 表示 Wi-Fi Direct (P2P) 设备的状态和配置信息
class DataSyncWifiP2pDevice {
  static const String _tag = 'DataSyncWifiP2pDevice';

  String deviceName;
  String deviceAddress;
  String detailDesc;
  DeviceStatus deviceStatus;
  DeviceType deviceType;

  /// 默认构造函数
  DataSyncWifiP2pDevice({
    this.deviceName = '',
    this.deviceAddress = '',
    this.detailDesc = '',
    this.deviceStatus = DeviceStatus.unavailable,
    this.deviceType = DeviceType.unknown,
  });

  /// 拷贝构造函数
  factory DataSyncWifiP2pDevice.copyFrom(DataSyncWifiP2pDevice source) {
    return DataSyncWifiP2pDevice(
      deviceName: source.deviceName,
      deviceAddress: source.deviceAddress,
      detailDesc: source.detailDesc,
      deviceStatus: source.deviceStatus,
      deviceType: source.deviceType,
    );
  }

  // 1. 从 Map 实例化的标准构造函数
  factory DataSyncWifiP2pDevice.fromMap(Map<String, dynamic> map) {
    return DataSyncWifiP2pDevice(
      // 兼容 JSON 字段名 name/deviceName 以及 addr/deviceAddress
      deviceName: map['deviceName'] as String? ?? '',
      deviceAddress: map['deviceAddress'] as String? ?? '',
      detailDesc: map['detailDesc'] as String? ?? '',
      deviceStatus: DeviceStatus.fromStatus(map['deviceStatus'] as int?),
      deviceType: DeviceType.fromPrimaryDeviceType(map['deviceType'] as String?),
    );
  }

  // 2. 从 JSON 字符串实例化的构造函数（解析 JSON 后调用 fromMap）
  factory DataSyncWifiP2pDevice.fromJsonString(String jsonString) {
    if (jsonString.isEmpty) {
      return DataSyncWifiP2pDevice(deviceName: '', deviceAddress: '');
    }
    final Map<String, dynamic> map = jsonDecode(jsonString) as Map<String, dynamic>;
    return DataSyncWifiP2pDevice.fromMap(map);
  }

  /// 转换为 Map (可用于序列化或平台通道通信)
  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'deviceAddress': deviceAddress,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DataSyncWifiP2pDevice && runtimeType == other.runtimeType &&
              deviceName == other.deviceName &&
              deviceAddress == other.deviceAddress &&
              detailDesc == other.detailDesc &&
              deviceStatus == other.deviceStatus &&
              deviceType == other.deviceType;

  @override
  int get hashCode => Object.hash(deviceName, deviceAddress, detailDesc, deviceStatus, deviceType);

  /// 涉及到更多的信息和细节，需要由平台侧提供。
  Future<String?> getDetails() async {
    return await DataSyncService().getDetails(deviceAddress);
  }

  String get deviceStatusDesc {
    return deviceStatus.desc;
  }
}