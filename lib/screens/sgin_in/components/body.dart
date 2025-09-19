import 'package:flutter/material.dart';
import 'package:xinyutest/screens/sgin_in/components/sign_form.dart';

import '../../../components/no_account_text.dart';
import '../../../components/socal_card.dart';
import '../../../config/size_config.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                Text(
                  "心语", //登录页标题
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: getProportionateScreenWidth(28),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "使用手机号码和密码登录",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.08),
                SignForm(), //登录控件
                SizedBox(height: getProportionateScreenHeight(20)),
                const NoAccountText(), //用户注册
              ],
            ),
          ),
        ),
      ),
    );
  }
}
