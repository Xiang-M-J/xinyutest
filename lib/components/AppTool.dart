import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'CenterTipsAlterWidget.dart';

class AppTool {
  ///只有一个确定按钮的弹窗
  showDefineAlert(BuildContext context, String title, String hintText) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ShowDefineAlertWidget(title, hintText); //弹窗提示
        });
  }
}
