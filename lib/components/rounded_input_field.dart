import 'package:flutter/material.dart';
import 'package:xinyutest/components/text_field_container.dart';
import '../config/constants.dart';

class RoundedInputField extends StatelessWidget {
  final String label;
  final String hintText;
  final Function() ontap;
  final String text;
  final ValueChanged<String> onChanged;

  const RoundedInputField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.ontap,
    required this.onChanged,
    this.text = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //文本输入容器TextFieldContainer
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        //cursorColor: kPrimaryColor,
        onTap: ontap,
        controller: TextEditingController.fromValue(TextEditingValue(
            text: text,
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream, offset: text.length)))),
        decoration: InputDecoration(
          labelText: label, //提示信息
          hintText: hintText, //隐藏提示文本，选中输入框时浮现
          border: InputBorder.none,
        ),
      ),
    );
  }
}
