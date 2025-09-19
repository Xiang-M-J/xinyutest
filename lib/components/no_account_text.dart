import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../config/size_config.dart';
import '../screens/sign_up/sign_up_screen.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "还没有账号? ",
          style: TextStyle(fontSize: getProportionateScreenWidth(16)),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, SignUpScreen.routeName),
          child: Text(
            "注册",
            style: TextStyle(
                fontSize: getProportionateScreenWidth(16),
                color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}