import 'dart:convert';
import 'dart:core';

import 'data_sync_service.dart';
import 'device_status.dart';
import 'device_type.dart';

/// 表示 Wi-Fi Direct (P2P) 设备的状态和配置信息
class DataSyncWifiP2pDevice {
  static const String _tag = 'DataSyncWifiP2pDevice';

  String deviceName;
  String deviceAddress;
  DeviceStatus deviceStatus;
  DeviceType primaryDeviceType;
  DeviceType secondaryDeviceType;
  String ipAddress;
  /// wfdInfo (Wi-Fi Display 信息)
  String wfdInfo;

  // ------------ 新增：从 Android 传递过来的方法返回值与高级字段 -------------
  bool isGroupOwner;
  bool isServiceDiscoveryCapable;
  bool wpsDisplaySupported;
  bool wpsKeypadSupported;
  bool wpsPbcSupported;
  bool isOpportunisticBootstrappingMethodSupported;
  bool isPassphraseDisplayBootstrappingMethodSupported;
  bool isPassphraseKeypadBootstrappingMethodSupported;
  bool isPinCodeDisplayBootstrappingMethodSupported;
  bool isPinCodeKeypadBootstrappingMethodSupported;
  String vendorElements;

  String? _primaryDeviceTypeText = '';
  String? _secondaryDeviceTypeText = '';

  /// 默认构造函数
  DataSyncWifiP2pDevice({
    this.deviceName = '',
    this.deviceAddress = '',
    this.deviceStatus = DeviceStatus.unavailable,
    this.primaryDeviceType = DeviceType.unknown,
    this.secondaryDeviceType = DeviceType.unknown,
    this.ipAddress = '',
    this.wfdInfo = '',
    this.isGroupOwner = false,
    this.isServiceDiscoveryCapable = false,
    this.wpsDisplaySupported = false,
    this.wpsKeypadSupported = false,
    this.wpsPbcSupported = false,
    this.isOpportunisticBootstrappingMethodSupported = false,
    this.isPassphraseDisplayBootstrappingMethodSupported = false,
    this.isPassphraseKeypadBootstrappingMethodSupported = false,
    this.isPinCodeDisplayBootstrappingMethodSupported = false,
    this.isPinCodeKeypadBootstrappingMethodSupported = false,
    this.vendorElements = '',
  });

  /// 拷贝构造函数
  factory DataSyncWifiP2pDevice.copyFrom(DataSyncWifiP2pDevice source) {
    return DataSyncWifiP2pDevice(
      deviceName: source.deviceName,
      deviceAddress: source.deviceAddress,
      deviceStatus: source.deviceStatus,
      primaryDeviceType: source.primaryDeviceType,
      secondaryDeviceType: source.secondaryDeviceType,
      ipAddress: source.ipAddress,
      wfdInfo: source.wfdInfo,
      isGroupOwner: source.isGroupOwner,
      isServiceDiscoveryCapable: source.isServiceDiscoveryCapable,
      wpsDisplaySupported: source.wpsDisplaySupported,
      wpsKeypadSupported: source.wpsKeypadSupported,
      wpsPbcSupported: source.wpsPbcSupported,
      isOpportunisticBootstrappingMethodSupported: source.isOpportunisticBootstrappingMethodSupported,
      isPassphraseDisplayBootstrappingMethodSupported: source.isPassphraseDisplayBootstrappingMethodSupported,
      isPassphraseKeypadBootstrappingMethodSupported: source.isPassphraseKeypadBootstrappingMethodSupported,
      isPinCodeDisplayBootstrappingMethodSupported: source.isPinCodeDisplayBootstrappingMethodSupported,
      isPinCodeKeypadBootstrappingMethodSupported: source.isPinCodeKeypadBootstrappingMethodSupported,
      vendorElements: source.vendorElements,
    );
  }

  // 1. 从 Map 实例化的标准构造函数
  factory DataSyncWifiP2pDevice.fromMap(Map<String, dynamic> map) {
    return DataSyncWifiP2pDevice(
      deviceName: map['deviceName'] as String? ?? '',
      deviceAddress: map['deviceAddress'] as String? ?? '',
      deviceStatus: DeviceStatus.fromStatus(map['deviceStatus'] as int?),
      primaryDeviceType: DeviceType.fromPrimaryDeviceType(map['primaryDeviceType'] as String?),
      secondaryDeviceType: DeviceType.fromPrimaryDeviceType(map['secondaryDeviceType'] as String?),
      ipAddress: map['ipAddress'] as String? ?? '',
      wfdInfo: map['wfdInfo'] as String? ?? '',
      isGroupOwner: map['isGroupOwner'] as bool? ?? false,
      isServiceDiscoveryCapable: map['isServiceDiscoveryCapable'] as bool? ?? false,
      wpsDisplaySupported: map['wpsDisplaySupported'] as bool? ?? false,
      wpsKeypadSupported: map['wpsKeypadSupported'] as bool? ?? false,
      wpsPbcSupported: map['wpsPbcSupported'] as bool? ?? false,
      isOpportunisticBootstrappingMethodSupported: map['isOpportunisticBootstrappingMethodSupported'] as bool? ?? false,
      isPassphraseDisplayBootstrappingMethodSupported: map['isPassphraseDisplayBootstrappingMethodSupported'] as bool? ?? false,
      isPassphraseKeypadBootstrappingMethodSupported: map['isPassphraseKeypadBootstrappingMethodSupported'] as bool? ?? false,
      isPinCodeDisplayBootstrappingMethodSupported: map['isPinCodeDisplayBootstrappingMethodSupported'] as bool? ?? false,
      isPinCodeKeypadBootstrappingMethodSupported: map['isPinCodeKeypadBootstrappingMethodSupported'] as bool? ?? false,
      vendorElements: map['vendorElements'] as String? ?? '',
    ).._primaryDeviceTypeText = map['primaryDeviceType'] as String?
     .._secondaryDeviceTypeText = map['secondaryDeviceType'] as String?;
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
      'deviceStatus': deviceStatus.status,
      'primaryDeviceType': primaryDeviceType.typeCode,
      'secondaryDeviceType': secondaryDeviceType.typeCode,
      'ipAddress': ipAddress,
      'wfdInfo': wfdInfo,
      'isGroupOwner': isGroupOwner,
      'isServiceDiscoveryCapable': isServiceDiscoveryCapable,
      'wpsDisplaySupported': wpsDisplaySupported,
      'wpsKeypadSupported': wpsKeypadSupported,
      'wpsPbcSupported': wpsPbcSupported,
      'isOpportunisticBootstrappingMethodSupported': isOpportunisticBootstrappingMethodSupported,
      'isPassphraseDisplayBootstrappingMethodSupported': isPassphraseDisplayBootstrappingMethodSupported,
      'isPassphraseKeypadBootstrappingMethodSupported': isPassphraseKeypadBootstrappingMethodSupported,
      'isPinCodeDisplayBootstrappingMethodSupported': isPinCodeDisplayBootstrappingMethodSupported,
      'isPinCodeKeypadBootstrappingMethodSupported': isPinCodeKeypadBootstrappingMethodSupported,
      'vendorElements': vendorElements,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DataSyncWifiP2pDevice &&
              runtimeType == other.runtimeType &&
              deviceName == other.deviceName &&
              deviceAddress == other.deviceAddress &&
              deviceStatus == other.deviceStatus &&
              primaryDeviceType == other.primaryDeviceType &&
              secondaryDeviceType == other.secondaryDeviceType &&
              ipAddress == other.ipAddress &&
              wfdInfo == other.wfdInfo &&
              isGroupOwner == other.isGroupOwner &&
              isServiceDiscoveryCapable == other.isServiceDiscoveryCapable &&
              wpsDisplaySupported == other.wpsDisplaySupported &&
              wpsKeypadSupported == other.wpsKeypadSupported &&
              wpsPbcSupported == other.wpsPbcSupported &&
              isOpportunisticBootstrappingMethodSupported == other.isOpportunisticBootstrappingMethodSupported &&
              isPassphraseDisplayBootstrappingMethodSupported == other.isPassphraseDisplayBootstrappingMethodSupported &&
              isPassphraseKeypadBootstrappingMethodSupported == other.isPassphraseKeypadBootstrappingMethodSupported &&
              isPinCodeDisplayBootstrappingMethodSupported == other.isPinCodeDisplayBootstrappingMethodSupported &&
              isPinCodeKeypadBootstrappingMethodSupported == other.isPinCodeKeypadBootstrappingMethodSupported &&
              vendorElements == other.vendorElements;

  @override
  int get hashCode => Object.hashAll([
    deviceName,
    deviceAddress,
    deviceStatus,
    primaryDeviceType,
    secondaryDeviceType,
    ipAddress,
    wfdInfo,
    isGroupOwner,
    isServiceDiscoveryCapable,
    wpsDisplaySupported,
    wpsKeypadSupported,
    wpsPbcSupported,
    isOpportunisticBootstrappingMethodSupported,
    isPassphraseDisplayBootstrappingMethodSupported,
    isPassphraseKeypadBootstrappingMethodSupported,
    isPinCodeDisplayBootstrappingMethodSupported,
    isPinCodeKeypadBootstrappingMethodSupported,
    vendorElements,
  ]);

  String get deviceStatusDesc {
    return deviceStatus.desc;
  }

  String getSimpleDesc({bool showAddress = true}) {
    final buffer = StringBuffer();
    buffer.writeln('设备名称: ${deviceName.isEmpty ? "未知" : deviceName}');
    if (showAddress) {
      buffer.writeln('MAC 地址: $deviceAddress');
      buffer.writeln('IP 地址: ${ipAddress.isEmpty ? "未分配/无" : ipAddress}');
    }
    buffer.writeln('设备类型: $_primaryDeviceTypeText ${primaryDeviceType.label}');
    buffer.writeln('当前连接状态: ${deviceStatus.desc}');
    buffer.writeln('是否为组长(GO Group Owner): ${isGroupOwner ? "是" : "否(设备为GC/设备未连接)"}');
    buffer.writeln('服务发现 (Service Discovery): ${isServiceDiscoveryCapable ? "支持" : "不支持"}');

    return buffer.toString();
  }

  /// 以中文格式化展示该设备的所有属性细节   Wi-Fi P2P 设备信息 (中文)
  String getDetailDesc({bool showAddress = true}) {
    final buffer = StringBuffer();
    buffer.writeln('【基本信息】');
    buffer.writeln('  设备名称: ${deviceName.isEmpty ? "未知" : deviceName}');
    if (showAddress) {
      buffer.writeln('  MAC 地址: $deviceAddress');
      buffer.writeln('  IP 地址: ${ipAddress.isEmpty ? "未分配/无" : ipAddress}');
    }

    buffer.writeln('\n【设备分类】');
    buffer.writeln('  主设备类型: $primaryDeviceType ${primaryDeviceType.label}');
    buffer.writeln('  次设备类型: $secondaryDeviceType ${secondaryDeviceType.label}');

    buffer.writeln('\n【网络状态与角色】');
    buffer.writeln('  当前连接状态: ${deviceStatus.desc}');
    buffer.writeln('  是否为组长 (GO): ${isGroupOwner ? "是" : "否 (GC / 未连接)"}');
    buffer.writeln('  服务发现 (Service Discovery): ${isServiceDiscoveryCapable ? "支持" : "不支持"}');

    buffer.writeln('\n【WPS 配对支持能力】');
    buffer.writeln('  一键按键配对 (PBC): ${wpsPbcSupported ? "支持" : "不支持"}');
    buffer.writeln('  显示 PIN 码 (Display): ${wpsDisplaySupported ? "支持" : "不支持"}');
    buffer.writeln('  键盘输入 PIN 码 (Keypad): ${wpsKeypadSupported ? "支持" : "不支持"}');

    buffer.writeln('\n【R2/R3 引导配对方式 (Bootstrapping)】');
    buffer.writeln('  静默无感配对 (Opportunistic): ${isOpportunisticBootstrappingMethodSupported ? "支持" : "不支持"}');
    buffer.writeln('  显示文本密码 (Passphrase Display): ${isPassphraseDisplayBootstrappingMethodSupported ? "支持" : "不支持"}');
    buffer.writeln('  输入文本密码 (Passphrase Keypad): ${isPassphraseKeypadBootstrappingMethodSupported ? "支持" : "不支持"}');
    buffer.writeln('  显示数字 PIN 码 (PIN Display): ${isPinCodeDisplayBootstrappingMethodSupported ? "支持" : "不支持"}');
    buffer.writeln('  输入数字 PIN 码 (PIN Keypad): ${isPinCodeKeypadBootstrappingMethodSupported ? "支持" : "不支持"}');

    if (wfdInfo.isNotEmpty) {
      buffer.writeln('\n【投屏扩展信息】');
      buffer.writeln('  Wi-Fi Display (WFD): $wfdInfo');
    }

    if (vendorElements.isNotEmpty) {
      buffer.writeln('\n【厂商自定义元素】');
      buffer.writeln('  Vendor Elements: $vendorElements');
    }

    return buffer.toString();
  }
}