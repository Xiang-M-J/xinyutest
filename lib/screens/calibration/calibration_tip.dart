import 'package:flutter/material.dart';
import '../../components/default_button.dart';
import '../../config/constants.dart';
import '../../config/size_config.dart';
import 'noisemeter.dart';

/// 声场校准提示页
class CalibrationTipScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calibration Tip"),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20)),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text("提示", style: headingStyle),
                  const Text(
                    "声场校准操作步骤提示说明",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.05),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "1. 音响放置于参考点正前方1米远，并与被试坐姿双耳同高。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      const Text(
                        "2. 将终端的音量设置成最大。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      const Text(
                        "3.在参考点位置摆放声级计，读取长时等效A计权声压级。（若LAeq >= 50dB A，则提示目前声场的背景噪声过高，暂缓施测。）",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      const Text(
                        "4. 将该数值填写进下方文本框中。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      const Text(
                        "5.系统会显示“再次审核”，声级计再次读取LAeq，直至该数值接近于90dB A。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.1),
                      DefaultButton(
                        text: "我知道了",
                        press: () {
                          /// 路由跳转
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => NoiseMeterPage()));
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
