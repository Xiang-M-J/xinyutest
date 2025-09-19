import 'package:flutter/material.dart';
import 'package:xinyutest/screens/splash/components/splash_content.dart';

import '../../../components/default_button.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';
import '../../sgin_in/sign_in_screen.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {"text": " ", "image": "assets/images/fengmian.png"}
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: PageView.builder(
                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: splashData.length,
                itemBuilder: (context, index) => SplashContent(
                  image: splashData[index]["image"],
                  text: splashData[index]['text'],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20)),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: List.generate(
                    //     splashData.length,
                    //     (index) => buildDot(index: index),
                    //   ),
                    // ),
                    const Spacer(flex: 3),
                    DefaultButton(
                      text: "进入",
                      press: () {
                        Navigator.pushNamed(context, SignInScreen.routeName);
                      },
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

//利用动画效果容器生成悬浮导航
  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kAnimationDuration, //动画变化持续时间
      margin: const EdgeInsets.only(right: 5),
      height: currentPage == index ? 9 : 6,
      width: currentPage == index ? 9 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(currentPage == index ? 4.5 : 3),
      ),
    );
  }
}
