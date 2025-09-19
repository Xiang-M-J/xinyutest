import 'package:flutter/material.dart';
import '../../../components/socal_card.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';
import 'sign_up_form.dart';

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
                Text("注册账号", style: headingStyle),
                const Text(
                  "完成你的详细信息",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                SignUpForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
