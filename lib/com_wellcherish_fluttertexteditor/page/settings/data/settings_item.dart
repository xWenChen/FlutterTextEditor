
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/settings/data/settings_type.dart';

class SettingsItem {
  SettingsType type;
  String name;
  String desc;
  String pageRouteName;
  IconData iconData;

  SettingsItem({
    this.type = SettingsType.unknown,
    this.name = '',
    this.desc = '',
    this.pageRouteName = '',
    this.iconData = Icons.question_mark_rounded,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SettingsItem && runtimeType == other.runtimeType &&
              type == other.type &&
              name == other.name &&
              desc == other.desc &&
              pageRouteName == other.pageRouteName;

  @override
  int get hashCode => Object.hash(type, name, desc, pageRouteName);

  @override
  String toString() {
    return '''{
      "type": $type,
      "name": $name,
      "desc": $desc,
      "pageRouteName": $pageRouteName,
    }''';
  }
}