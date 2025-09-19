import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xinyutest/screens/audiometry/setting_audio.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../Global/calibration_values.dart';
import '../../Global/dio_client.dart';
import '../../Global/exercise.dart';
import '../../Global/test_record.dart';
import '../../components/AppTool.dart';
import '../../components/default_border_button.dart';
import '../../components/default_button.dart';
import '../../config/constants.dart';
import '../../config/size_config.dart';
import '../../config/styles.dart';
import 'components/ny_header.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// 中文语句识别率测试页
class AudiometryExercisePage extends StatefulWidget {
  /// 模式 0:第一次执行练习表  1：第二次执行练习表
  final int Mode;
  AudiometryExercisePage({Key? key, this.Mode = 0}) : super(key: key);
  @override
  AudiometryExercisePageState createState() => AudiometryExercisePageState();
}

class AudiometryExercisePageState extends State<AudiometryExercisePage> {
  final controller = ScrollController();
  double offset = 0;
  var dio = DioClient.dio;
  AudioPlayer? audioPlayer;
  AudioCache? player;
  String returnText = "中止";

  /// 音频文件路径（不包含音频文件名）
  final String _path = "assets/";

  /// 音频文件名称
  String _wavName = "1.wav";

  ///用于提示目前进度文本
  String tipText = '开始';

  ///录音
  FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  ///录音音频路径
  String recordAudioPath = '';

  /// 播放音频的音量
  double _playVolume = 1;

  /// 本句中的关键词个数
  int _keywordNumber = 0;

  /// 已播放的关键词总数
  int _sumNumber = 0;

  /// 正确识别的关键词个数
  int _rightNumber = 0;

  /// 正确率（百分比）
  double _accuracy = 0;

  /// 正确率百分比字符
  String _strAccuracy = "0 %";

  /// 正在播放的语句索引
  int _playIndex = 0;

  /// 该表需要播放的音频总数
  int _playSumNumber = 10;

  /// 数据库资源
  var responseData;

  /// 关键词信息
  var keyWords;

  /// Checkbox状态记录
  var checkList;

  /// 用于乱序播放句子
  List _playIndexList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  ///存储语句测试详情
  late List _result;

  ///全部音频路径，用于删除
  List delAudioPath = List.empty(growable: true);

  ///存储全部测试音频
  late List audioList;

  ///存储每句完成后的总词数
  late List<int> _sumNumberList;

  ///存储每句完成后的总的对的词数
  late List<int> _rightNumberList;

  void getSource() async {
    try {
      var response = await dio.get(
        DioClient.baseurl + '/api/speechtable/' + TestRecord.tableId.toString(),
      );
      var res = response.data;
      var status = res["status"] as int;
      if (status == 0) {
        var data = res["data"];
        responseData = data["resources"];
        _playSumNumber = data["resourceNumber"];

        if (_playSumNumber != _playIndexList.length) {
          _playIndexList.clear();
          for (int i = 0; i < _playSumNumber; i++) {
            _playIndexList.add(i);
          }
        }
        _playIndexList.removeAt(0);
        _playIndexList.shuffle();
        _playIndexList.insert(0, 0);
      } else {
        var error = res["error"];
        setState(() {
          /// 警告，提示对话框
          AppTool().showDefineAlert(context, "警告", error);
        });
      }
    } catch (e) {
      setState(() {
        /// 警告，提示对话框
        AppTool().showDefineAlert(context, "错误", '请检查网络连接！');
      });
      return;
    }
  }

  /// 言语测听流程
  void AutoProcess() {
    try {
      setState(() {
        if (_playIndex < _playSumNumber) {
          _keywordNumber =
              responseData[_playIndexList[_playIndex]]["keywordNumber"];
          var tempk = responseData[_playIndexList[_playIndex]]
              ["keywords"]; // 更新用于生成界面关键词组件的列表
          keyWords = tempk;
          for (int i = 0;
              i < responseData[_playIndexList[_playIndex]]["keywordNumber"];
              i++) {
            var t = tempk[i];
            t["check"] = false;
            keyWords[i] = t;
          }
          _wavName =
              responseData[_playIndexList[_playIndex]]["name"]; // 更新用于播放的音频名称
          ///录音
          record(_wavName);
          // 播放音频
          play();
          print('finish');
          _playIndex++;
          if (_playIndex == _playSumNumber)
            tipText = "结束";
          else
            tipText = "下一句";
        } else {
          TestRecord.accuracy = _strAccuracy;
          // SaveResult();
          TestRecord.result = _result;
          // 所有流程已结束，显示并记录结果
          AppTool().showDefineAlert(context, "提示", '测试结束！正确率：$_strAccuracy');
          setState(() {
            returnText = "继续";
          });
        }
      });
    } catch (e) {
      setState(() {
        /// 警告，提示对话框
        AppTool().showDefineAlert(context, "错误", '出现错误，请回到主页面重新开始测试！');
        returnText = "继续";
      });
      return;
    }
  }

  ///保存测试结果
  void SaveResult() async {
    for (int i = 0; i < delAudioPath.length; i++) {
      print(await File(delAudioPath[i]).exists());
    }
    //DateTime time  = DateTime.now();
    var requestData = FormData.fromMap({
      "subjectId": TestRecord.subjectId,
      "mode": TestRecord.mode,
      //"createTime": time.toString(),
      "hearingStatus": TestRecord.hearingStatus,
      "corpusType": TestRecord.corpusType,
      "environment": TestRecord.environment,
      "tableId": TestRecord.tableId,
      "playVolume": TestRecord.playVolumeDB,
      "result": TestRecord.result,
      "accuracy": TestRecord.accuracy,
      "audiolist": audioList
    });
    // print(requestData);
    var response = await dio.post(DioClient.baseurl + '/api/testrecord',
        data: requestData);
    var res = response.data;
    var status = res["status"] as int;
    if (status == 0) {
      print('保存成功！');
      AppTool().showDefineAlert(context, '提示', '保存成功！');
    } else {
      var error = res["error"];
      setState(() {
        /// 警告，提示对话框
        AppTool().showDefineAlert(context, "警告", error);
      });
    }
  }

  ///录音
  record(String name) async {
    _recorder.closeRecorder();
    _recorder.openRecorder();
    var tempDirPath = (await getTemporaryDirectory()).path;
    var tempAudioPath =
        tempDirPath + "/" + TestRecord.subjectId.toString() + name;
    _recorder.startRecorder(
        codec: Codec.pcm16WAV,
        toFile: tempAudioPath,
        numChannels: 1,
        sampleRate: 16000);
    recordAudioPath = tempAudioPath;
  }

  /// 初始化变量的值
  void InitValues() {
    keyWords = [
      {"keyword": "这", "nonSemIndex": null, "check": false},
      {"keyword": "是", "nonSemIndex": null, "check": false},
      {"keyword": "一", "nonSemIndex": null, "check": false},
      {"keyword": "句", "nonSemIndex": null, "check": false},
      {"keyword": "示例", "nonSemIndex": 1, "check": false}
    ];
    _keywordNumber = 5;
  }

  /// 计算播放音量并设置播放器
  void CalculateVolume() {
    audioPlayer = AudioPlayer();
    _playVolume = CalibrationValue.calibrationVolume *
        ((TestRecord.playVolumeDB - 21) /
            ((CalibrationValue.calibrationDB - 21) /
                CalibrationValue.calibrationVolume));
    if (TestRecord.playVolumeDB >= 40 && TestRecord.playVolumeDB < 43) {
      _playVolume = _playVolume * 1.1;
    } else if (TestRecord.playVolumeDB >= 60 && TestRecord.playVolumeDB <= 77) {
      _playVolume = _playVolume * 0.95;
    }

    player = AudioCache(prefix: _path);
    VolumeController().setVolume(_playVolume, showSystemUI: false);
    audioPlayer!.setVolume(_playVolume);
  }

//录音请求
  micphoneRequest() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      AppTool().showDefineAlert(context, "提示", "未给予录音权限");
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    micphoneRequest();
    InitValues();
    TestRecord.mode = "练习模式";
    controller.addListener(onScroll);
    CalculateVolume();
    getSource();
    audioList = List.filled(_playSumNumber + 1, null);
    _rightNumberList = List.filled(_playSumNumber + 2, 0);
    _sumNumberList = List.filled(_playSumNumber + 2, 0);
    _result = List.filled(_playSumNumber + 1, null);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    audioPlayer?.release();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
  }

  void play() async {
    print("开始播放音乐");
    await audioPlayer?.play(AssetSource(_wavName));
    print('ok');
    // player?.play(_wavName);
  }

  void stop() {
    print("停止播放");
    audioPlayer?.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: controller,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyHeader(
              image: "assets/icons/Drcorona.svg",
              textTop: "L" +
                  TestRecord.tableId.toString() +
                  "  S" +
                  _playIndexList[_playIndex - 1 < 0 ? 0 : _playIndex - 1]
                      .toString() +
                  "\n累计正确率：",
              textBottom: _strAccuracy,
              offset: offset,
            ),
            const Text(
              '请勾选被试者复述正确的词：',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const Text(
              '每轮测试中的第一句话为练习句，不计入结果中。\n每句话中的蓝色字表示非语义字，不计入正确率。',
              style:
                  TextStyle(color: Colors.black87, fontSize: 14, height: 2.0),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.03),

            /// 关键词
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: keyWords
                  .map<Widget>((e) => Column(
                        children: [
                          Text.rich(
                              keyWordsTextSpan(e["keyword"], e["nonSemIndex"])),
                          Checkbox(
                            value: e["check"],
                            activeColor: kPrimaryColor,
                            onChanged: (value) {
                              setState(() {
                                e["check"] = value;
                              });
                            },
                          ),
                        ],
                      ))
                  .toList(),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.02),

            /// 全对or全不对
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '所有关键词：',
                  style: TextStyle(color: Colors.black87),
                ),
                SizedBox(
                    width: SizeConfig.screenWidth * 0.25,
                    child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            for (int i = 0; i < _keywordNumber; i++) {
                              keyWords[i]["check"] = true;
                            }
                          });
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blue),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.symmetric(
                              vertical: 0.0,
                              horizontal: 0.0,
                            )),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(color: Colors.white))),
                        child: const Column(children: [
                          Icon(
                            Icons.check,
                            color: Colors.white,
                          ),
                          Text(
                            '全对',
                            style: Styles.buttonTextStyle,
                          ),
                        ]))),
                Padding(
                    padding: EdgeInsets.all(
                  SizeConfig.screenWidth * 0.02,
                )),
                SizedBox(
                  width: SizeConfig.screenWidth * 0.25,
                  child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          for (int i = 0; i < _keywordNumber; i++) {
                            keyWords[i]["check"] = false;
                          }
                        });
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 0.0,
                          )),
                          textStyle: MaterialStateProperty.all(
                              const TextStyle(color: Colors.white))),
                      child: const Column(children: [
                        Icon(
                          Icons.clear,
                          color: Colors.white,
                        ),
                        Text(
                          '全不对',
                          style: Styles.buttonTextStyle,
                        ),
                      ])),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.05),

            /// 下一句按钮
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  width: SizeConfig.screenWidth * 0.35,
                  child: DefaultButton(
                    text: "上一句",
                    press: () {
                      setState(() async {
                        if (returnText == "中止") {
                          --_playIndex;
                          if (_playIndex > 0) {
                            await audioPlayer!.stop();
                            --_playIndex;

                            _rightNumber = _rightNumberList[_playIndex];
                            _sumNumber = _sumNumberList[_playIndex];
                            if (_sumNumber != 0)
                              _accuracy = _rightNumber / _sumNumber * 100;
                            else
                              _accuracy = 0;
                            // 更新界面显示正确率
                            _strAccuracy = _accuracy.toInt().toString() + " %";
                            AutoProcess();
                          } else {
                            _playIndex = 1;

                            /// 警告，提示对话框
                            AppTool().showDefineAlert(context, "提示", "已经是第一句！");
                          }
                        }
                      });
                      setState(() {});
                    },
                  )),
              Padding(
                  padding: EdgeInsets.all(
                SizeConfig.screenWidth * 0.02,
              )),
              SizedBox(
                width: SizeConfig.screenWidth * 0.35,
                child: DefaultButton(
                  text: tipText,
                  press: () {
                    setState(() async {
                      if (returnText == "中止") {
                        print(_playIndex);
                        //停止录音和播放
                        stop();
                        await _recorder.closeRecorder();
                        // 更新识别正确的个数
                        //if条件将第一句不计入正确率
                        if (_playIndex > 0 && _playIndex <= _playSumNumber) {
                          _result[_playIndex - 1] = keyWords;
                          //kerWords:keyword、nonSemIndex、check
                          for (int i = 0; i < _keywordNumber; i++) {
                            _result[_playIndex - 1][i]
                                .remove("nonSemIndex"); //移除nonSemIndex
                            if (keyWords[i]["check"] == true) {
                              _rightNumber++;
                            }
                          }

                          ///存储本句测试结果
                          var temp =
                              await MultipartFile.fromFile(recordAudioPath);
                          audioList[_playIndex - 1] = temp;
                          print(audioList.length);
                          delAudioPath.add(recordAudioPath);
                          // 每张表第一句语句不计入正确率计算
                          _sumNumber =
                              _sumNumber + _keywordNumber; // 更新已经播放的关键词总个数
                          _accuracy = _rightNumber / _sumNumber * 100;

                          _sumNumberList[_playIndex] = _sumNumber;
                          _rightNumberList[_playIndex] = _rightNumber;
                          // 更新正确率
                          _strAccuracy =
                              _accuracy.toInt().toString() + " %"; // 更新界面显示正确率
                        }
                        AutoProcess();
                      }
                    });
                  },
                ),
              )
            ]),
            SizedBox(height: SizeConfig.screenHeight * 0.03),

            /// 中止按钮
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              SizedBox(
                  width: SizeConfig.screenWidth * 0.35,
                  child: DefaultBorderButton(
                    text: "再次播放",
                    press: () async {
                      await audioPlayer?.stop();
                      play();
                    },
                  )),
              Padding(
                  padding: EdgeInsets.all(
                SizeConfig.screenWidth * 0.02,
              )),
              SizedBox(
                width: SizeConfig.screenWidth * 0.35,
                child: DefaultBorderButton(
                  text: returnText,
                  press: () async {
                    if (returnText == "继续") {}

                    /// 路由跳转
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SettingAudioPage()));
                  },
                ),
              ),
            ])
          ],
        ),
      ),
    );
  }

  TextSpan keyWordsTextSpan(String key, var value) {
    if (value == null) {
      return TextSpan(
        text: key,
        style: const TextStyle(fontSize: 18, color: Colors.black87),
      );
    } else {
      int keyLength = key.length;
      List temp = [];
      for (int i = 0; i < keyLength; i++) {
        if (i == value) {
          temp.add({"text": key[i], "color": Colors.blue});
        } else {
          temp.add({"text": key[i], "color": Colors.black87});
        }
      }
      return TextSpan(
        children: temp
            .map((e) => TextSpan(
                  text: e["text"],
                  style: TextStyle(fontSize: 18, color: e["color"]),
                ))
            .toList(),
      );
    }
  }
}
