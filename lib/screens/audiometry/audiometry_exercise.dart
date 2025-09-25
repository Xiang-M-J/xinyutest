import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:xinyutest/Global/local_service.dart';
import 'package:xinyutest/dal/user/user_manager.dart';
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

  /// 播放音频的音量
  double _playVolume = 40;

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

  /// 判断是否保存
  bool isSave = false;

  /// 用于乱序播放句子
  List _playIndexList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  ///用于更新提示按钮文本
  String tipText = '下一句';

  // 储存测试音频的关键字数量
  List keywordsNumList = List.empty(growable: true);

  // 储存每一句音频的正确关键字数量
  List correctNumList = List.empty(growable: true);

  // 储存每一句音频记录的关键字，勾选关键字为 true，不勾选为 false
  List<List<bool>> keywordsList = List.empty(growable: true);

  /// 最大播放的语句索引，用于计算正确率
  int _maxPlayIndex = 0;

  // 每条语句是否已经测试过
  List<bool> doneList = List.empty(growable: true);
  bool isDone = false;

  String? userId;

  // bool  = true;

  void getSource() async {
    try {
      // var response = await dio.get(
      //   DioClient.baseurl + '/api/speechtable/' + TestRecord.tableId.toString(),
      // );

      var response = await getSpeechTableByIdResponse(userId, TestRecord.tableId);
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

        keywordsNumList = List.generate(_playSumNumber, (index) => 0);
        correctNumList = List.generate(_playSumNumber, (index) => 0);
        keywordsList = List.generate(
            _playSumNumber, (index) => List.empty(growable: true));
        doneList = List.generate(_playSumNumber, (index) => false);
        AutoProcess();
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
  void AutoProcess({bool autoplay = true}) {
    try {
      setState(() {
        if (_playIndex < _playSumNumber) {
          // TODO 将speech_resources写死
          _keywordNumber =
              responseData[_playIndexList[_playIndex]]["keywordNumber"];   //

          var tempk = responseData[_playIndexList[_playIndex]]
              ["keywords"]; // 更新用于生成界面关键词组件的列表

          keyWords = tempk;

          // 第一次测试句子，没有关键字
          if (keywordsList[_playIndex].isEmpty) {
            for (int i = 0;
                i < responseData[_playIndexList[_playIndex]]["keywordNumber"];
                i++) {
              var t = tempk[i];
              t["check"] = false;
              keywordsList[_playIndex].add(false);
              keyWords[i] = t;
            }
          }
          // 重复句子，存在关键字
          else {
            for (int i = 0;
                i < responseData[_playIndexList[_playIndex]]["keywordNumber"];
                i++) {
              var t = tempk[i];
              t["check"] = keywordsList[_playIndex][i];
              keyWords[i] = t;
            }
          }

          keywordsNumList[_playIndex] = _keywordNumber;
          _wavName =
              responseData[_playIndexList[_playIndex]]["name"]; // 更新用于播放的音频名称

          isDone = doneList[_playIndex];
          print(_wavName);
          // 播放音频，如果自动播放，
          if (autoplay) {
            play();
            print('finish');
          }
          tipText = "下一句";
          returnText = "中止";
        } else {
          tipText = '已完成所有语句';
          if (isSave == false) {
            TestRecord.accuracy = _strAccuracy;
            isSave = true;
          }
          // 所有流程已结束，显示并记录结果
          AppTool().showDefineAlert(context, "提示", '测试结束！正确率：$_strAccuracy');
          returnText = "继续";
          ExerciseInfo.TableNumber_Finished++;
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
        ((TestRecord.playVolumeDB - CalibrationValue.micCalibrationDB) /
            ((CalibrationValue.calibrationDB -
                    CalibrationValue.micCalibrationDB) /
                CalibrationValue.calibrationVolume));

    player = AudioCache(prefix: _path);
    VolumeController().setVolume(_playVolume, showSystemUI: false);
    audioPlayer!.setVolume(_playVolume);
  }

  @override
  void initState() {
    super.initState();
    userId = UserManager().currentUser?.userphone;
    InitValues();
    TestRecord.mode = "练习模式";
    controller.addListener(onScroll);
    CalculateVolume();
    getSource();
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
    if (_wavName.endsWith(".wav")) {
      await audioPlayer?.play(AssetSource(_wavName));

    }else{
      // ignore: prefer_interpolation_to_compose_strings
      await audioPlayer?.play(AssetSource(_wavName+".wav"));

    }
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
              textTop:
                  "L${TestRecord.tableId}  S${_playIndexList[_playIndex == _playSumNumber ? _playIndex - 1 : _playIndex]}\n累计正确率：",
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
                        onPressed: returnText == "中止"
                            ? () {
                                setState(() {
                                  for (int i = 0; i < _keywordNumber; i++) {
                                    keyWords[i]["check"] = true;
                                  }
                                });
                              }
                            : null,
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
                      onPressed: returnText == "中止"
                          ? () {
                              setState(() {
                                for (int i = 0; i < _keywordNumber; i++) {
                                  keyWords[i]["check"] = false;
                                }
                              });
                            }
                          : null,
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
                SizedBox(width: getProportionateScreenWidth(15)),
                isDone
                    ? const Icon(
                        Icons.done,
                        size: 30,
                        color: Colors.green,
                      )
                    : const Icon(size: 30, Icons.done),
              ],
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.05),

            Row(
              mainAxisAlignment: _playIndex == 0
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
              children: [
                Offstage(
                  offstage: _playIndex == 0,
                  child: SizedBox(
                    width: SizeConfig.screenWidth * 0.4,
                    child: DefaultButton(
                      text: "上一句",
                      press: () async {
                        if (_playIndex > 0) {
                          setState(() {
                            if (_playIndex < _playSumNumber) {
                              // doneList[_playIndex] = true;  // 是否需要给与上一句确认完成的权限
                              int rightNumber = 0;
                              for (int i = 0; i < _keywordNumber; i++) {
                                if (keyWords[i]["check"] == true) {
                                  rightNumber++;
                                }
                                keywordsList[_playIndex][i] =
                                    keyWords[i]["check"];
                              }
                              correctNumList[_playIndex] = rightNumber;

                              _maxPlayIndex = doneList.lastIndexOf(true);
                              _accuracy = getAccuracy();
                              _strAccuracy =
                                  "${_accuracy.toInt()} %"; // 更新界面显示正确率
                            }
                            _playIndex--;
                          });
                        }
                        AutoProcess();
                      },
                    ),
                  ),
                ),
                // _playIndex == 0
                //     ? Container(width: 0,)
                //     :
                // 下一句
                SizedBox(
                  width: SizeConfig.screenWidth * (_playIndex == 0 ? 0.8 : 0.4),
                  child: DefaultButton(
                    text: tipText,
                    press: () {
                      setState(() {
                        if (returnText == "中止") {
                          doneList[_playIndex] = true;
                          if (_playIndex < _playSumNumber) {
                            int rightNumber = 0;
                            for (int i = 0; i < _keywordNumber; i++) {
                              if (keyWords[i]["check"] == true) {
                                rightNumber++;
                              }
                              keywordsList[_playIndex][i] =
                                  keyWords[i]["check"];
                            }
                            correctNumList[_playIndex] = rightNumber;
                            // 每张表第一句语句不计入正确率计算
                            // _sumNumber = _sumNumber + _keywordNumber; // 更新已经播放的关键词总个数
                            // _accuracy = _rightNumber / _sumNumber * 100; // 更新正确率
                            // _maxPlayIndex 为已完成的语句的最大索引
                            _maxPlayIndex = doneList.lastIndexOf(true);
                            _accuracy = getAccuracy();
                            _strAccuracy =
                                "${_accuracy.toInt()} %"; // 更新界面显示正确率
                          }

                          // 增加 1
                          if (_playIndex < _playSumNumber) {
                            setState(() {
                              _playIndex++;
                            });
                          }
                          // 更新本句中的识别正确的个数

                          AutoProcess();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeConfig.screenHeight * 0.03),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth * 0.4,
                  child: DefaultBorderButton(
                    text: "重播",
                    press: () async {
                      print(_playIndex);
                      stop();
                      play();
                    },
                  ),
                ),

                /// 中止按钮
                SizedBox(
                  width: SizeConfig.screenWidth * 0.4,
                  child: DefaultBorderButton(
                    text: returnText,
                    press: () {
                      stop();

                      /// 路由跳转
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SettingAudioPage()));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double getAccuracy() {
    
    if (_maxPlayIndex < 1) {
      return 0.0;
    }
    return 100.0 *
        sum(correctNumList.sublist(1, _maxPlayIndex + 1)) /
        sum(keywordsNumList.sublist(1, _maxPlayIndex + 1));
  }

  int sum(List numbers) {
    int s = 0;
    for (int n in numbers) {
      s += n;
    }
    return s;
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
