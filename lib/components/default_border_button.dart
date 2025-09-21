import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../config/size_config.dart';

class DefaultBorderButton extends StatelessWidget {
  const DefaultBorderButton({
    Key? key,
    this.text,
    this.press,
  }) : super(key: key);
  final String? text;
  final Function? press;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: double.infinity,
      width: getProportionateScreenWidth(160),
      height: getProportionateScreenHeight(56),
      child: TextButton(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(width: 1.0, color: kPrimaryColor),
          ),
          foregroundColor: kPrimaryColor,
          backgroundColor: Colors.white,
        ),
        onPressed: press as void Function()?,
        child: Text(
          text!,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
            color: kPrimaryColor,
          ),
        ),
      ),
    );
  }
}
