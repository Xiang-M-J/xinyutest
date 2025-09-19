import 'package:flutter/material.dart';
import 'package:xinyutest/screens/home/home_screen.dart';
import '../../../components/default_button.dart';
import '../../../config/size_config.dart';

class LoginSuccessScreen extends StatelessWidget {
  bool textValue;
  LoginSuccessScreen({super.key, required this.textValue});
  static String routeName = "/login_success";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: SizedBox(),
          title: Text("Login Success"),
        ),
        //原Body部分
        body: SafeArea(
            child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: getProportionateScreenWidth(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: SizeConfig.screenHeight * 0.04),
                      Image.asset(
                        "assets/images/success.png",
                        height: SizeConfig.screenHeight * 0.4, //40%
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.08),
                      Text(
                        textValue ? '保存成功' : "注册成功",
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(30),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: SizeConfig.screenWidth * 0.6,
                        child: DefaultButton(
                          text: "进入主页",
                          press: () {
                            Navigator.pushNamed(context, HomeScreen.routeName);
                          },
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ))));
  }
}
