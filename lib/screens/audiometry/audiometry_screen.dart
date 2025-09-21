
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xinyutest/Global/local_service.dart';
import 'package:xinyutest/dal/user/user_manager.dart';
import 'package:xinyutest/screens/audiometry/setting_audio.dart';
import 'package:volume_controller/volume_controller.dart';
import '../../Global/calibration_values.dart';
import '../../Global/dio_client.dart';
import '../../Global/test_record.dart';
import '../../components/AppTool.dart';
import '../../components/default_border_button.dart';
import '../../components/default_button.dart';
import '../../config/constants.dart';
import '../../config/size_config.dart';
import '../../config/styles.dart';
import '../home/home_screen.dart';
import 'components/ny_header.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// 中文语句识别率测试页
class AudiometryScreenPage extends StatefulWidget {
  /// 模式 0:练习模式  1：执行模式
  final int Mode;
  const AudiometryScreenPage({Key? key, this.Mode = 0}) : super(key: key);
  @override
  AudiometryScreenPageState createState() => AudiometryScreenPageState();
}

class AudiometryScreenPageState extends State<AudiometryScreenPage> {
  final controller = ScrollController();
  double offset = 0;
  //API工具
  var dio = DioClient.dio;
  //播放器
  AudioCache? player;
  AudioPlayer? audioPlayer;
  //提示文本
  String returnText = "中止";

  String? userId;

  ///录音
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  ///录音音频路径
  String recordAudioPath = '';

  /// 音频文件路径（不包含音频文件名）
  final String _path = "assets/";

  /// 音频文件名称
  String _wavName = "1.wav";

  /// 播放音频的音量
  double _playVolume = 0.4;

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

  ///用于提示目前进度文本
  String tipText = '开始';

  /// 用于乱序播放句子
  final List _playIndexList = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  ///存储语句测试详情
  List<List> _result = List.empty(growable: true);

  ///全部音频路径，用于删除
  List delAudioPath = List.empty(growable: true);

  ///存储全部测试音频
  List audioList = List.empty(growable: true);

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

  bool isStart = false; // 是否开始

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

        /// 对表中语句进行乱序排列，除第一句引导句之外
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
        _result = List.generate(
            _playSumNumber, (index) => List.empty(growable: true));
        audioList = List.generate(_playSumNumber, (index) => null);

        // AutoProcess();
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
          _keywordNumber =
              responseData[_playIndexList[_playIndex]]["keywordNumber"];
          var tempk = responseData[_playIndexList[_playIndex]]["keywords"];
          // 更新用于生成界面关键词组件的列表
          keyWords = tempk;
          // for (int i = 0;
          //     i < responseData[_playIndexList[_playIndex]]["keywordNumber"];
          //     i++) {
          //   keyWords[i]["check"] = false;
          // }

          // 第一次测试句子，没有关键字
          if (keywordsList[_playIndex].isEmpty) {
            for (int i = 0;
                i < responseData[_playIndexList[_playIndex]]["keywordNumber"];
                i++) {
              keyWords[i]["check"] = false;
              keywordsList[_playIndex].add(false);
            }
          }
          // 重复句子，存在关键字
          else {
            for (int i = 0;
                i < responseData[_playIndexList[_playIndex]]["keywordNumber"];
                i++) {
              keyWords[i]["check"] = keywordsList[_playIndex][i];
            }
          }
          keywordsNumList[_playIndex] = _keywordNumber;

          isDone = doneList[_playIndex];

          // TestRecord.resultDetail["keyWordNumber"][_playIndex] = _keywordNumber;
          _wavName =
              responseData[_playIndexList[_playIndex]]["name"]; // 更新用于播放的音频名称
          ///录音
          record(_wavName);

          // 播放音频
          if (autoplay) {
            play();
          }
          tipText = '下一句';
          returnText = "中止";
        } else {
          tipText = '已完成所有语句';
          if (isSave == false) {
            TestRecord.accuracy = _strAccuracy;
            // SaveResult();
            TestRecord.result = _result;
            isSave = true;
            // print(TestRecord.result);
          }
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
        setState(() {
          returnText = "继续";
        });
      });
      return;
    }
  }

  /// 保存测试结果
  void SaveResult() async {
    for (int i = 0; i < delAudioPath.length; i++) {
      print(await File(delAudioPath[i]).exists());
    }
    //DateTime time  = DateTime.now();
    // var requestData = FormData.fromMap({
    //   "subjectId": TestRecord.subjectId,
    //   "mode": TestRecord.mode,
    //   //"createTime": time.toString(),
    //   "hearingStatus": TestRecord.hearingStatus,
    //   "corpusType": TestRecord.corpusType,
    //   "environment": TestRecord.environment,
    //   "tableId": TestRecord.tableId,
    //   "playVolume": TestRecord.playVolumeDB,
    //   "result": TestRecord.result,
    //   "accuracy": TestRecord.accuracy,
    //   "audiolist": audioList
    // });

    var requestData = {
      "subjectId": TestRecord.subjectId,
      "mode": TestRecord.mode,
      // "createTime": time.toString(),
      "hearingStatus": TestRecord.hearingStatus,
      "corpusType": TestRecord.corpusType,
      "environment": TestRecord.environment,
      "tableId": TestRecord.tableId,
      "playVolume": TestRecord.playVolumeDB,
      "result": TestRecord.result,
      "accuracy": TestRecord.accuracy,
    };

    // print(requestData);
    // var response = await dio.post('${DioClient.baseurl}/api/testrecord',
    //     data: requestData);

    var response = await postTestRecordResponse(userId, requestData);
    
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
    // _playVolume = CalibrationValue.calibrationVolume *
    //     (pow(10, 0.05 * TestRecord.playVolumeDB) /
    //         pow(10, 0.05 * CalibrationValue.calibrationDB));

    _playVolume = CalibrationValue.calibrationVolume *
        ((TestRecord.playVolumeDB - CalibrationValue.micCalibrationDB) /
            (CalibrationValue.calibrationDB -
                CalibrationValue.micCalibrationDB));
    print(_playVolume);
    player = AudioCache(prefix: _path);
    VolumeController().setVolume(_playVolume, showSystemUI: false);
    audioPlayer?.setVolume(_playVolume);
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
    userId = UserManager().currentUser?.userphone;
    micphoneRequest();
    InitValues();
    TestRecord.mode = widget.Mode == 0 ? "练习模式" : "正式模式";
    controller.addListener(onScroll);
    CalculateVolume();
    getSource();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    for (int i = 0; i < delAudioPath.length; i++) {
      var dir = Directory(delAudioPath[i]);
      if (dir.existsSync()) {
          dir.deleteSync(recursive: true);

      }
    }
    audioPlayer?.release();
    super.dispose();
  }

  void onScroll() {
    setState(() {
      offset = (controller.hasClients) ? controller.offset : 0;
    });
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

  void play() async {
    print("开始播放音乐");
    await audioPlayer?.play(AssetSource(_wavName));
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
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                            vertical: 0.0,
                            horizontal: 0.0,
                          )),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
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
                      ]),
                    )),
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
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.symmetric(
                                  vertical: 0.0, horizontal: 0.0)),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0))),
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
                      ]),
                    )),
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

            /// 上一句，下一句
            Row(
              mainAxisAlignment: _playIndex < 1
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceEvenly,
              children: [
                _playIndex < 1
                    ? Container()
                    : SizedBox(
                        width: SizeConfig.screenWidth * 0.4,
                        child: DefaultButton(
                          text: "上一句",
                          press: () async {
                            stop();
                            await _recorder.closeRecorder();
                            if (_playIndex < _playSumNumber) {
                              // doneList[_playIndex] = true;
                              int rightNumber = 0;
                              for (int i = 0; i < _keywordNumber; i++) {
                                if (keyWords[i]["check"] == true) {
                                  rightNumber++;
                                }
                                keywordsList[_playIndex][i] =
                                    keyWords[i]["check"];
                              }
                              correctNumList[_playIndex] = rightNumber;

                              ///存储本句测试结果
                              print(await File(recordAudioPath).exists());
                              var temp =
                                  await MultipartFile.fromFile(recordAudioPath);
                              audioList[_playIndex] = temp;
                              // print(audioList.length);
                              if (!delAudioPath.contains(recordAudioPath)) {
                                delAudioPath.add(recordAudioPath);
                              }
                              _maxPlayIndex = doneList.lastIndexOf(true);
                              _accuracy = getAccuracy();
                              _strAccuracy =
                                  "${_accuracy.toInt()} %"; // 更新界面显示正确率
                            }
                            if (_playIndex > 0) {
                              _playIndex--;
                            }
                            setState(() {});
                            AutoProcess();
                          },
                        ),
                      ),

                /// 下一句按钮
                SizedBox(
                  width: SizeConfig.screenWidth * (_playIndex >= 1 ? 0.4 : 0.8),
                  child: DefaultButton(
                    text: tipText,
                    press: () async {
                      if (returnText == "中止") {
                        stop();
                        await _recorder.closeRecorder();
                        if (_playIndex < _playSumNumber) {
                          if (tipText != "开始") {
                            doneList[_playIndex] = true;
                            int rightNumber = 0;
                            if (_result[_playIndex].isEmpty) {
                              _result[_playIndex] = keyWords;
                              for (int i = 0; i < _keywordNumber; i++) {
                                _result[_playIndex][i].remove("nonSemIndex");
                              }
                            }
                            for (int i = 0; i < _keywordNumber; i++) {
                              if (keyWords[i]["check"] == true) {
                                rightNumber++;
                              }
                              keywordsList[_playIndex][i] =
                                  keyWords[i]["check"];
                            }
                            correctNumList[_playIndex] = rightNumber;

                            ///存储本句测试结果
                            print(await File(recordAudioPath).exists());
                            var temp =
                                await MultipartFile.fromFile(recordAudioPath);
                            audioList[_playIndex] = temp;
                            // print(audioList.length);
                            if (!delAudioPath.contains(recordAudioPath)) {
                                delAudioPath.add(recordAudioPath);
                            }

                            if (isStart) {
                              _maxPlayIndex = doneList.lastIndexOf(true);
                            }
                            _accuracy = getAccuracy();
                            _strAccuracy =
                                "${_accuracy.toInt()} %"; // 更新界面显示正确率
                          }
                        }

                        // 由于第一句示例没有音频，如果已经开始才加1
                        if (_playIndex < _playSumNumber && isStart) {
                          _playIndex++;
                        }
                        if (!isStart) {
                          isStart = true;
                        }
                        setState(
                          () {},
                        );
                        AutoProcess();
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.03),

            ///
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth * 0.4,
                  child: DefaultBorderButton(
                    text: "重播",
                    press: () {
                      stop();
                      play();
                    },
                  ),
                ),
                SizedBox(
                  width: SizeConfig.screenWidth * 0.4,
                  child: DefaultBorderButton(
                    text: returnText,
                    press: () async {
                      stop();
                      if (returnText == '继续') {
                        var result = await showCupertinoModalPopup(
                            //等待底部提示框的pop反馈值
                            context: context,
                            builder: (context) {
                              return CupertinoActionSheet(
                                title: const Text('请选择是否保存测试结果'),
                                actions: <Widget>[
                                  CupertinoActionSheetAction(
                                    child: const Text('保存，变更测试'),
                                    onPressed: () {
                                      Navigator.of(context).pop('保存，变更测试');
                                    },
                                    isDestructiveAction: false,
                                  ),
                                  CupertinoActionSheetAction(
                                    child: const Text('保存，结束访视'),
                                    onPressed: () {
                                      Navigator.of(context).pop('保存，结束访视');
                                    },
                                    isDestructiveAction: false,
                                  ),
                                  CupertinoActionSheetAction(
                                    child: const Text('不保存，继续测试'),
                                    onPressed: () {
                                      Navigator.of(context).pop('不保存，继续测试');
                                    },
                                    isDefaultAction: false,
                                  ),
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  child: const Text('取消'),
                                  onPressed: () {
                                    Navigator.of(context).pop('cancel');
                                  },
                                ),
                              );
                            });
                        if (result == '保存，变更测试') {
                          SaveResult();

                          /// 路由跳转
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SettingAudioPage()));
                        } else if (result == '保存，结束访视') {
                          SaveResult();

                          /// 路由跳转
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const HomeScreen()));
                        } else if (result == '不保存，继续测试') {
                          /// 路由跳转
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SettingAudioPage()));
                        }
                      } else {
                        /// 点击“中止”路由跳转
                        print(_result);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SettingAudioPage()));
                      }
                    },
                  ),
                ),
              ],
            )

            /// 中止按钮
          ],
        ),
      ),
    );
  }

  double getAccuracy() {
    if (_maxPlayIndex < 0) {
      return 0.0;
    }
    return 100.0 *
        sum(correctNumList.sublist(0, _maxPlayIndex + 1)) /
        sum(keywordsNumList.sublist(0, _maxPlayIndex + 1));
  }

  int sum(List numbers) {
    int s = 0;
    for (int n in numbers) {
      s += n;
    }
    return s;
  }

//将语句中的关键词标黑，虚词标蓝
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
