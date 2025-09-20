import 'dart:io';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:xinyutest/config/constants.dart';
import '../../Global/calibration_values.dart';
import '../../Global/dio_client.dart';
import '../../components/AppTool.dart';
import '../../components/default_border_button.dart';
import '../../components/default_button.dart';
import '../../components/reviewed_button.dart';
import '../../config/size_config.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:xinyutest/screens/audiometry/get_subject.dart';
import '../home/home_screen.dart';

const _asset = 'Calibration-Noise-25dB.wav';

/// 声场校准页
class CalibrationScreen extends StatefulWidget {
  /// 模式
  final int MicSource;
  CalibrationScreen({Key? key, required this.MicSource}) : super(key: key);
  @override
  CalibrationScreenState createState() => CalibrationScreenState();
}

class CalibrationScreenState extends State<CalibrationScreen> {
  TextEditingController micCalibrationValue = TextEditingController();
  var dio = DioClient.dio;
  AudioPlayer? audioPlayer;
  AudioCache? player;
  double initVolume = 1.0;
  // 需要达到的声压级
  final double dBNeed = 90;
  // 可以接受的误差范围
  final double tolerance = 5;
  //音量增减的单位数值
  final double unit = 0.05;

  String? resultData;
  String? micData;
  String curState = "审核结果：未知";
  Color color = kPrimaryColor;
  String text = "审核";

  @override
  void initState() {
    super.initState();
    micCalibrationValue.text = widget.MicSource.toString();
    audioPlayer = AudioPlayer();
    player = AudioCache(prefix: 'asset/');
    VolumeController().setVolume(initVolume, showSystemUI: false);
    audioPlayer!.setVolume(initVolume);
  }

  @override
  void dispose() {
    // player?.clearAll();
    audioPlayer?.release();
    delRecorderAudio();
    super.dispose();
  }

  /// 保存校准结果
  void SaveResult() async {
    try {
      var recordAudio = File(CalibrationValue.recordPath);
      print(CalibrationValue.recordPath);
      print(await recordAudio.exists());
      var formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(recordAudio.path),
        "testingDevice": CalibrationValue.testingDevice,
        "testedDevice": CalibrationValue.testedDevice,
        "createTime": CalibrationValue.testTime.substring(0, 10),
        "playVolume": CalibrationValue.calibrationVolume,
        "microphoneCalibrationValue": CalibrationValue.micCalibrationDB,
        "speakerCalibrationValue": CalibrationValue.calibrationDB,
      });

      // if (await recordAudio.exists()) {
      //   var requestData = {
      //     "testingDevice": CalibrationValue.testingDevice,
      //     "testedDevice": CalibrationValue.testedDevice,
      //     "createTime": CalibrationValue.testTime.substring(0, 10),
      //     "playVolume": CalibrationValue.calibrationVolume,
      //     "microphoneCalibrationValue": CalibrationValue.micCalibrationDB,
      //     "speakerCalibrationValue": CalibrationValue.calibrationDB,
      //     "audio": recordAudio

      var response = await dio
          .post(DioClient.baseurl + '/api/devicecalibration', data: formData);
      var res = response.data;
      print(res);
      var status = res["status"] as int;
      if (status == 0) {
        setState(() {
          text = "合格";
          curState = "审核结果：合格";
          color = Colors.green;
          AppTool().showDefineAlert(context, '提示', '审核成功');
        });
      } else {
        var error = res["error"];
        setState(() {
          /// 警告，提示对话框
          AppTool().showDefineAlert(context, "警告", error);
        });
      }
      // } else {
      //   AppTool().showDefineAlert(context, "提示", "未找到录音文件");
      // }
    } catch (err) {
      setState(() {
        text = '审核';
        curState = '校准记录保存失败！';

        /// 警告，提示对话框
        AppTool().showDefineAlert(context, "警告", '请检查网络连接');
      });
      return;
    }
  }

  //录音删除
  delRecorderAudio() {
    if (CalibrationValue.recordPath != '') {
      var dir = Directory(CalibrationValue.recordPath);
      dir.deleteSync(recursive: true);
    }
  }

  void play() {
    print("开始播放音乐");
    audioPlayer?.play(AssetSource(_asset));
    // player?.play(_asset);
  }

  void stop() {
    print("停止播放");
    audioPlayer?.stop();
  }

  void increase() {
    if (initVolume >= 1) {
      AppTool().showDefineAlert(context, "警告", "已经是最大音量");
    } else {
      initVolume = initVolume + unit;
      VolumeController().setVolume(initVolume, showSystemUI: false);
      audioPlayer?.setVolume(initVolume);
    }
  }

  void decrease() {
    if (initVolume <= 0) {
      AppTool().showDefineAlert(context, "警告", "已经是最小音量");
    } else {
      initVolume = initVolume - unit;
      VolumeController().setVolume(initVolume, showSystemUI: false);
      audioPlayer?.setVolume(initVolume);
    }
  }

  int compare(double d) {
    int flag = 0;
    if (d >= dBNeed - tolerance && d <= dBNeed + tolerance) {
      return flag;
    }
    //增大音量
    else if (d < dBNeed - 5) {
      increase();
      flag = 1;
    }
    //减小音量
    else {
      decrease();
      flag = -1;
    }
    return flag;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(
          '声场校准',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        //backgroundColor: kPrimaryColor,
        centerTitle: true,
        foregroundColor: Colors.white,
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
                  SizedBox(height: SizeConfig.screenHeight * 0.01),
                  const Text(
                    '操作步骤提示：',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "1. 使用声级计测量当前环境，将声级计结果数值填写进下方文本框中。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      buildMicDataField(),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      const Text(
                        "2. 将终端的音量设置成最大。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.01),
                      const Text(
                        "3. 在参考点位置摆放声级计，点击下方“播放”按钮播放校准音频。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.01),
                      DefaultButton(
                        text: "播放",
                        press: () {
                          play();
                        },
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.01),
                      const Text(
                        "4. 将声级计结果数值填写进下方文本框。",
                        textAlign: TextAlign.start,
                        style: TextStyle(color: Colors.black87, height: 2.0),
                      ),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      buildResultDataField(),
                      SizedBox(height: SizeConfig.screenHeight * 0.02),
                      ReviewedButton(
                        color: color,
                        text: text,
                        press: () {
                          stop();
                          double curVolume = double.parse(resultData!);
                          int flag = compare(curVolume);
                          if (flag == 0) {
                            // 保存记录信息
                            CalibrationValue.calibrationVolume = initVolume;
                            CalibrationValue.calibrationDB =
                                int.parse(resultData!);
                            DateTime time = DateTime.now();
                            CalibrationValue.testTime = time.toString();
                            CalibrationValue.newCalibrationFinished = true;
                            SaveResult();
                          } else if (flag == 1) {
                            color = kPrimaryColor;
                            text = "审核";
                            curState = "审核结果：当前音量过小，已经增大音量";
                          } else {
                            color = kPrimaryColor;
                            text = "审核";
                            curState = "审核结果：当前音量过大，已经减小音量";
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.01),
                  Text(
                    curState,
                    textAlign: TextAlign.start,
                    style: const TextStyle(color: Colors.black87, height: 2.0),
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.01),
                  DefaultButton(
                    text: '言语测听',
                    press: () {
                      stop();
                      if (CalibrationValue.newCalibrationFinished) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => GetSubjectPage()));
                      }
                    },
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.01),

                  /// 返回按钮
                  DefaultBorderButton(
                    text: "返回上一级页面",
                    press: () {
                      stop();
                      Navigator.pushNamed(context, HomeScreen.routeName);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextFormField buildMicDataField() {
    return TextFormField(
      controller: micCalibrationValue,
      keyboardType: TextInputType.number,
      onSaved: (newValue) => micData = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          micData = value;
          CalibrationValue.micCalibrationDB = int.parse(micData!);
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "环境测量值",
        hintText: "输入声级计的测量值",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }

  TextFormField buildResultDataField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      onSaved: (newValue) => resultData = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          resultData = value;
        }
        return;
      },
      validator: (value) {
        if (value!.isEmpty) {
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "终端测量值",
        hintText: "输入声级计的测量值",
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
    );
  }
}
