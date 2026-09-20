import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/base_view_model.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/arch/mutable_state.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/settings/data/settings_item.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/page/settings/data/settings_type.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/resource/strings.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/router/route_constants.dart';

class SettingsViewModel extends BaseViewModel {
  static final _tag = "SettingsViewModel";

  bool canPop = true;

  MutableState<List<SettingsItem>> dataList = MutableState(<SettingsItem>[
    SettingsItem(
      type: SettingsType.dataSync,
      name: Strings.dataSyncTitle,
      desc: Strings.dataSyncDesc,
      pageRouteName: RouteConstants.dataSync,
      iconData: Icons.phonelink_rounded
    ),
    SettingsItem(
      type: SettingsType.about,
      name: Strings.aboutTitle,
      pageRouteName: RouteConstants.settings,
      iconData: Icons.info_outline_rounded
    ),
    SettingsItem(
        type: SettingsType.colors,
        name: Strings.colorsTitle,
        pageRouteName: RouteConstants.colorSchemaExample,
        iconData: Icons.color_lens_outlined
    ),
  ]);

  void tryUpdate() {
    notifyListeners();
  }
}