import 'package:flutter/material.dart';

/// Wi-Fi P2P 设备大类枚举 (依据 Wi-Fi Alliance 规范)
enum DeviceType {
  computer(
    typeCode: 1,
    label: '电脑/笔记本',
    icon: Icons.laptop_rounded,
  ),
  inputDevice(
    typeCode: 2,
    label: '输入设备(键盘/鼠标/手柄)',
    icon: Icons.keyboard_rounded,
  ),
  printer(
    typeCode: 3,
    label: '打印机/扫描仪',
    icon: Icons.print_rounded,
  ),
  camera(
    typeCode: 4,
    label: '数码相机/摄像机',
    icon: Icons.photo_camera_rounded,
  ),
  storage(
    typeCode: 5,
    label: '存储设备/NAS',
    icon: Icons.dns_rounded,
  ),
  networkInfrastructure(
    typeCode: 6,
    label: '路由器/网络设备',
    icon: Icons.router_rounded,
  ),
  display(
    typeCode: 7,
    label: '显示器/智能电视/投影仪',
    icon: Icons.tv_rounded,
  ),
  multimedia(
    typeCode: 8,
    label: '多媒体设备/机顶盒/音响',
    icon: Icons.speaker_group_rounded,
  ),
  gaming(
    typeCode: 9,
    label: '游戏主机/掌机',
    icon: Icons.sports_esports_rounded,
  ),
  phone(
    typeCode: 10,
    label: '智能手机',
    icon: Icons.phone_android_rounded,
  ),
  audio(
    typeCode: 11,
    label: '音频设备(耳机/麦克风)',
    icon: Icons.headset_rounded,
  ),
  tablet(
    typeCode: 12,
    label: '平板电脑',
    icon: Icons.tablet_android_rounded,
  ),
  unknown(
    typeCode: -1,
    label: '未知设备',
    icon: Icons.devices_other_rounded,
  );

  /// Wi-Fi P2P 标准主类型代码 (Category ID)
  final int typeCode;

  /// 设备类型的中文名称
  final String label;

  /// 设备对应的 IconData 图标
  final IconData icon;

  const DeviceType({
    required this.typeCode,
    required this.label,
    required this.icon,
  });
  /// 根据整型代码获取对应的枚举类型
  static DeviceType fromCode(int code) {
    return DeviceType.values.firstWhere(
          (element) => element.typeCode == code,
      orElse: () => DeviceType.unknown,
    );
  }

  /// 直接解析 Android 返回的 `primaryDeviceType` 字符串
  /// 例如输入: "10-0050F204-5" 或 "1-0050F204-1"
  /// 主类型代码-OUI/协议代码-次类型代码
  /// 输出: WfdDeviceCategory.phone 或 WfdDeviceCategory.computer
  static DeviceType fromPrimaryDeviceType(String? primaryDeviceType) {
    if (primaryDeviceType == null || primaryDeviceType.isEmpty) {
      return DeviceType.unknown;
    }

    try {
      // 提取第一个短横线前面的 Category ID 数字
      final firstPart = primaryDeviceType.split('-').first;
      final code = int.parse(firstPart);
      return fromCode(code);
    } catch (_) {
      return DeviceType.unknown;
    }
  }
}