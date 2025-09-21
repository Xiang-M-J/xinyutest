import 'dart:async';
// ignore: unused_import
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:xinyutest/Global/calibration_values.dart';
import 'package:xinyutest/components/AppTool.dart';
import '../../components/ArcProgressBar.dart';
import '../../components/default_border_button.dart';
import '../../components/default_button.dart';
import '../../config/size_config.dart';
import '../../config/styles.dart';
import '../home/home_screen.dart';
import 'calibration_screen.dart';
import 'dart:math';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:xinyutest/Global/dio_client.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:xinyutest/Global/calibration_values.dart';

/// 环境噪声评估页--声场校准使用
class NoiseMeterPage extends StatefulWidget {
  /// 模式
  final int Mode;
  NoiseMeterPage({Key? key, this.Mode = 0}) : super(key: key);
  @override
  NoiseMeterPageState createState() => NoiseMeterPageState();
}

class NoiseMeterPageState extends State<NoiseMeterPage> {
  Timer? _timer;
  int curentTimer = 6000;
  var dio = DioClient.dio;
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  NoiseMeter? _noiseMeter;
  List<double> _meanDecibel = []; //麦克风采集分贝值
  double _dynamicDecibel = 0; //分贝表盘动态显示值
  double _aveDecibel = 0;
  String _resultText = '此处显示环境评估结果';
  bool _isContinue = false;
  String tempAudioPath = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _noiseMeter = NoiseMeter();
    _recorder.closeRecorder();
    _recorder.openRecorder();
  }

  // 上传录音
  // Future<void> _sceneLabel(File audio) async {
  //   print("录音上传中");

  //   setState(() {});

  //   // 上传录音
  //   try {
  //     var formData = FormData.fromMap({
  //       'send': await MultipartFile.fromFile(audio.path),
  //     });
  //     var requestData={"envAudio":formData};
  //     var response = await dio
  //         .post(DioClient.baseurl+'/api/audio/'+,
  //             data: formData)
  //         .timeout(const Duration(seconds: 10));
  //     var res = response.data;
  //     var status = res["status"] as int;
  //     if (status == 0) {
  //       _upLoadSuccess = true;
  //     }
  //   } on TimeoutException catch (e) {
  //     setState(() {
  //       AppTool().showDefineAlert(context, '提示', '语音上传失败');
  //     });
  //   }
  // }

  ///噪声计采集环境音频幅度
  void onData(NoiseReading noiseReading) {
    setState(() {
      if (!_isRecording) {
        _isRecording = true;
      }

      if (noiseReading.meanDecibel >= 0 && noiseReading.meanDecibel <= 120) {
        //修正只针对一台设备
        if (noiseReading.meanDecibel <= 46) {
          _dynamicDecibel = noiseReading.meanDecibel + 5.105;
        } else if (noiseReading.meanDecibel > 46 &&
            noiseReading.meanDecibel <= 60) {
          _dynamicDecibel = noiseReading.meanDecibel - 3.098;
        } else if (noiseReading.meanDecibel > 60 &&
            noiseReading.meanDecibel <= 85) {
          _dynamicDecibel = noiseReading.meanDecibel - 4.437;
        } else {
          _dynamicDecibel = noiseReading.meanDecibel;
        }
        _meanDecibel.add(noiseReading.meanDecibel);
      }
      // print(noiseReading.toString());
    });

    // if (noiseReading.meanDecibel >= 0 && noiseReading.meanDecibel <= 120) {
    //   _meanDecibel.add(noiseReading.meanDecibel);
    // }
    // print(noiseReading.toString());
  }

  void onError(PlatformException e) {
    print(e.toString());
    _isRecording = false;
  }

  void startCollect() async {
    print('success');
    try {
      if (_meanDecibel.isNotEmpty) {
        _meanDecibel.clear();
      }

      ///开始录音
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        AppTool().showDefineAlert(context, "提示", "未给予录音权限");
        return;
      }
      setState(() {
        // scenceButton = '录音中（大约5秒）';
      });

      var tempDirPath = (await getTemporaryDirectory()).path;
      tempAudioPath = "$tempDirPath/${DateTime.now().millisecondsSinceEpoch}calibrationAudio.wav";
      _recorder.startRecorder(
          codec: Codec.pcm16WAV,
          toFile: tempAudioPath,
          numChannels: 1,
          sampleRate: 16000);

      ///计时
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
        curentTimer -= 100;

        if (curentTimer <= 0) {
          stopCollect();
          await _recorder.stopRecorder();
          var recordFile = File(tempAudioPath);
          if (await recordFile.exists()) {
            // await _sceneLabel(recordFile);
            CalibrationValue.recordPath = tempAudioPath;
          } else {
            AppTool().showDefineAlert(context, "提示", "声音录制失败");
          }
          _timer?.cancel();
        }
      });
      _aveDecibel = 0;
      _isContinue = false;
      _resultText = '正在评估中...';
      _noiseSubscription = _noiseMeter?.noise.listen(onData);
    } catch (err) {
      //print(err);
      AppTool().showDefineAlert(context, '警告', '环境评估出错！');
    }
  }

//录音删除
  delRecorder() {
    if (tempAudioPath != '') {
      var dir = Directory(tempAudioPath);
      dir.deleteSync(recursive: true);
    }
  }

  double sum(List<double> source) {
    double result = 0;
    source.sort();
    int length = source.length - 10;
    for (int i = 0; i < length; i++) {
      num temp = pow(10, source[i] * 0.05);
      result += temp;
    }
    return result;
  }

  void stopCollect() async {
    try {
      // ignore: unnecessary_null_comparison
      if (_noiseSubscription != null) {
        _noiseSubscription?.cancel();
        //_noiseSubscription = null;
      }
      setState(() {
        _isRecording = false;
        curentTimer = 6000;
        double _ave = sum(_meanDecibel) / (_meanDecibel.length - 10);
        if (_ave < 200) {
          _aveDecibel = 20 * (log(_ave * 1.8) / log(10));
        } else if (_ave <= 1000 && _ave >= 200) {
          _aveDecibel = 20 * (log(_ave * 0.7) / log(10));
        } else if (_ave > 1000 && _ave <= 17700) {
          _aveDecibel = 20 * (log(_ave * 0.6) / log(10));
        } else if (_ave > 17700) {
          _aveDecibel = 20 * (log(_ave) / log(10));
        }
        _dynamicDecibel = _aveDecibel;

        if (_aveDecibel <= 0) {
          _aveDecibel = 0.01;
          _resultText = '请检查设备麦克风是否正常！';
        }
        if (_aveDecibel >= 120) {
          _aveDecibel = 119.9;
          _resultText = '请检查设备麦克风是否正常！';
        }
        if (_aveDecibel <= 50) {
          _resultText =
              '当前环境评估结果：合格\n${_aveDecibel.toString().substring(0, 4)} dB';
          _isContinue = true;
          CalibrationValue.micCalibrationDB = _aveDecibel.round();
        } else {
          _resultText = '场所噪声偏高，请到安静场所测试。\n${_aveDecibel.toString().substring(0, 4)} dB';
          _isContinue = false;
        }
      });
    } catch (err) {
      print('stopCollectRecorder error: $err');
      AppTool().showDefineAlert(context, '警告', '环境评估出错！');
    }
  }

  List<Widget> getContent() => <Widget>[
        Container(
            margin: const EdgeInsets.all(25),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
                    style: const TextStyle(fontSize: 25, color: Colors.blue)),
              )
            ])),
      ];
  @override
  void dispose() {
    // TODO: implement dispose
    _timer?.cancel();
    _recorder.closeRecorder();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          title: const Text(
            '环境评估',
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
            child: ListView(children: <Widget>[
          SizedBox(
            height: size.height,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, left: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const Column(children: [
                    Text('提示： 请在安静环境下开始环境评估，点击下方按钮开始评估，5秒自动结束。',
                        style: TextStyle(color: Colors.black87, fontSize: 16))
                  ]),
                  //const Spacer(),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 10.0,
                    ),
                    //padding: const EdgeInsets.all(10.0),
                    //height: 0.08*size.height,
                    width: 0.5 * size.width,
                    // ignore: deprecated_member_use
                    //修改！！！！
                    child: OutlinedButton(
                        onPressed: () {
                          if (_isRecording) {
                            stopCollect();
                          } else {
                            startCollect();
                          }
                        },
                        style: ButtonStyle(
                            shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0))),
                            backgroundColor: WidgetStateProperty.all(
                                _isRecording ? Colors.red : Colors.green),
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20.0,
                            )),
                            textStyle: WidgetStateProperty.all(
                                const TextStyle(color: Colors.white))),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _isRecording
                                  ? const Icon(
                                      Icons.stop,
                                      color: Colors.white,
                                    )
                                  : const Icon(Icons.mic, color: Colors.white),
                              _isRecording
                                  ? Text(
                                      '倒计时：${curentTimer ~/ 1000}',
                                      style: Styles
                                          .buttonTextStyle, //修改了buttontextstyle的字体颜色
                                    )
                                  : const Text(
                                      '开始评估',
                                      style: Styles.buttonTextStyle,
                                    )
                            ])),
                  ),
                  //const Spacer(),
                  ArcProgressBar(
                    width: SizeConfig.screenWidth * 0.8,
                    height: SizeConfig.screenHeight * 0.35,
                    min: 0,
                    max: 120,
                    progress: _dynamicDecibel,
                  ),

                  Text(_resultText,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 16)),
                  SizedBox(height: size.height * 0.015),
                  SizedBox(
                      width: size.width * 0.8,
                      child: Column(
                        children: [
                          DefaultButton(
                            text: "进入下一步",
                            press: () {
                              if (_isContinue) {
                                /// 路由跳转
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => CalibrationScreen(
                                          MicSource: _aveDecibel.round(),
                                        )));
                              } else {
                                delRecorder();
                              }
                            },
                          ),

                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          // / 中止按钮

                          DefaultBorderButton(
                            text: "返回上一级页面",
                            press: () {
                              /// 路由跳转
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => const HomeScreen()));
                            },
                          ),
                        ],
                      ))
                ],
              ),
            ),
            // CustomScrollView(
            //   physics: const ClampingScrollPhysics(),
            //   slivers: <Widget>[
            //     _buildCheckNoise(size),
            //   ],
            // ),
          )
        ])));
  }
}
