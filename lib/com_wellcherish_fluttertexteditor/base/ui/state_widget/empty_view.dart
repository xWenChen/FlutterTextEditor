import 'package:flutter/material.dart';
import 'package:flutter_text_editor/com_wellcherish_fluttertexteditor/base/ui/state_widget/state_view.dart';

import '../../../resource/strings.dart';
import '../../constants/material3/app_size.dart';

/// 空状态视图
class EmptyView extends StatelessWidget {
  const EmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return StateView(
      size: AppSize.stateCardSizeL,
      // 对应 R.drawable.ic_no_file
      icon: Image(
        width: AppSize.stateCardSizeM,
        height: AppSize.stateCardSizeM,
        image: AssetImage("assets/images/ic_no_file.png"),
      ),
      // 对应 R.string.empty_page_tips
      text: Strings.noData,
    );
  }
}