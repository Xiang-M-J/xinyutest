import 'package:flutter/material.dart';
import 'package:xinyutest/components/text_field_container.dart';

class RoundedDateField extends StatelessWidget {
  final String label;
  final String hintText;
  final String text;
  final Function() ontap;
  final ValueChanged<String> onChanged;
  const RoundedDateField({
    Key? key,
    required this.label,
    required this.hintText,
    required this.ontap,
    required this.onChanged,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
      child: TextField(
        onChanged: onChanged,
        onTap: ontap,
        //cursorColor: kPrimaryColor,
        keyboardType: const TextInputType.numberWithOptions(signed: true),
        controller: TextEditingController.fromValue(TextEditingValue(
            text: text,
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream, offset: text.length)))),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
