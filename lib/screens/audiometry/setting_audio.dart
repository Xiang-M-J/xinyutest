import 'package:flutter/material.dart';
import 'package:xinyutest/screens/home/home_screen.dart';
import '../../Global/dio_client.dart';
import '../../Global/exercise.dart';
import '../../Global/test_record.dart';
import '../../components/AppTool.dart';
import '../../components/default_border_button.dart';
import '../../components/default_button.dart';
import '../../config/constants.dart';
import '../../config/size_config.dart';
import 'audiometry_exercise.dart';
import 'audiometry_screen.dart';

/// 设置页 -- 言语测听使用
class SettingAudioPage extends StatefulWidget {
  /// 模式
  final int Mode;
  SettingAudioPage({Key? key, this.Mode = 0}) : super(key: key);
  @override
  SettingAudioPageState createState() => SettingAudioPageState();
}

class SettingAudioPageState extends State<SettingAudioPage> {
  var dio = DioClient.dio;

  /// 助听状态
  String? _hearing_status = '无助听状态';

  /// 语料类型
  String? _corpus_type = '短';

  /// 测试环境
  String? _environment = '安静';

  /// 测试模式
  String? _testMode = '练习模式';

  /// 测试播放表号
  String? _table_index = '13';

  /// 测试声压级dB
  String? _play_volume = '40';

  /// 测试模式：0为练习模式，1为正式测听模式
  int mode = 0;

  /// 测试表号列表
  final List<String> _tableList = ['13', '14'];

  /// 是否是首次Session(无助听状态)
  bool isFirstSession = true;

  int _EnvironmentPart = 1;
  int _corpusPart = 1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _tableList.shuffle(); // 打乱顺序
      _table_index = _tableList[0];
    });
  }

  /// 保存相关设置参数
  void SaveSetting() {
    TestRecord.hearingStatus = _hearing_status!;
    TestRecord.corpusType = _corpus_type!;
    TestRecord.environment = _environment!;
    TestRecord.tableId = int.parse(_table_index!);
    TestRecord.playVolumeDB = int.parse(_play_volume!);
  }

  void getSource(String strMode) async {
    try {
      var response = await dio.get(
        DioClient.baseurl + '/api/speechtable/' + strMode,
      );
      var res = response.data;
      var status = res["status"] as int;
      if (status == 0) {
        List temp = res["data"];
        _tableList.clear();
        for (int i = 0; i < temp.length; i++) {
          _tableList.add(temp[i].toString());
        }
        setState(() {
          if (strMode == "Normal") {
            _tableList.shuffle(); // 打乱顺序
            _table_index = _tableList[0];
          } else {
            /// 练习模式
            if (ExerciseInfo.isFirstExercise) {
              _tableList.removeAt(1);
              _table_index = _tableList[0];
              ExerciseInfo.isFirstExercise = false;
            } else {
              _tableList.removeAt(0);
              _table_index = _tableList[0];
              ExerciseInfo.isFirstExercise = true;
            }
          }
        });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(
          '测试设置',
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
            child: ListView(children: <Widget>[
              Column(
                children: [
                  //SizedBox(height: SizeConfig.screenHeight * 0.02),
                  const Text(
                    '语句测听参数设置：',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),

                  /// 助听状态
                  Row(
                    children: [
                      const Text(
                        '助听状态：',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: SizeConfig.screenWidth * 0.05),
                        height: 60,
                        width: SizeConfig.screenWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: kSecondaryColor,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: SizeConfig.screenWidth * 0.01),
                            Expanded(
                              child: DropdownButton(
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                value: _hearing_status,
                                items: [
                                  '无助听状态',
                                  '已习惯使用自有助听器',
                                  '使用甲类4周以上',
                                  '使用乙类4周以上',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _hearing_status = value.toString();
                                    if (_hearing_status == '无助听状态') {
                                      isFirstSession = true;
                                      _testMode = '练习模式';
                                      mode = 0;
                                      getSource("Exercise");
                                    } else {
                                      isFirstSession = false;
                                      _testMode = '正式测听模式';
                                      mode = 1;
                                      getSource("Normal");
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.03),

                  /// 语料类型
                  SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          const Text(
                            '语料类型：',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          SizedBox(width: SizeConfig.screenWidth * 0.01),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: SizeConfig.screenWidth * 0.04),
                            height: 60,
                            width: SizeConfig.screenWidth * 0.6,
                            // decoration: BoxDecoration(
                            //   color: Colors.white,
                            //   borderRadius: BorderRadius.circular(25),
                            //   border: Border.all(
                            //     color: kSecondaryColor,
                            //   ),
                            //),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Radio(
                                        value: 1,
                                        groupValue: _corpusPart,
                                        activeColor: kPrimaryColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _corpusPart = 1;
                                            _corpus_type = '短';
                                          });
                                        }),
                                    const Text(
                                      '短',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                        value: 2,
                                        groupValue: _corpusPart,
                                        activeColor: kPrimaryColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _corpusPart = 1;
                                            _corpus_type = '中';
                                          });
                                        }),
                                    const Text(
                                      '中',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Radio(
                                        value: 3,
                                        groupValue: _corpusPart,
                                        activeColor: kPrimaryColor,
                                        onChanged: (value) {
                                          setState(() {
                                            _corpusPart = 1;
                                            _corpus_type = '长';
                                          });
                                        }),
                                    const Text(
                                      '长',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ],
                                ),

                                // Expanded(
                                //   child: DropdownButton(
                                //     isExpanded: true,
                                //     underline: const SizedBox(),
                                //     icon: const Icon(Icons.keyboard_arrow_down),
                                //     value: _corpus_type,
                                //     items: [
                                //       '短',
                                //       '中',
                                //       '长',
                                //     ].map<DropdownMenuItem<String>>((String value) {
                                //       return DropdownMenuItem<String>(
                                //         value: value,
                                //         child: Text(value,style: const TextStyle(color: Colors.black87),),
                                //       );
                                //     }).toList(),
                                //     onChanged: (value) {
                                //       setState(() {
                                //         _corpus_type = value.toString();
                                //       });
                                //     },
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: SizeConfig.screenHeight * 0.03),

                  /// 测听条件
                  Row(
                    children: [
                      const Text(
                        '测听条件：',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: SizeConfig.screenWidth * 0.05),
                        height: 60,
                        width: SizeConfig.screenWidth * 0.6,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: [
                                Radio(
                                    value: 1,
                                    groupValue: _EnvironmentPart,
                                    activeColor: kPrimaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _EnvironmentPart = 1;
                                        _environment = '安静';
                                      });
                                    }),
                                const Text(
                                  '安静',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Radio(
                                    value: 2,
                                    groupValue: _EnvironmentPart,
                                    activeColor: kPrimaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _EnvironmentPart = 2;
                                        _environment = '噪声';
                                      });
                                    }),
                                const Text(
                                  '噪声',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),

                            // Expanded(
                            //   child: DropdownButton(
                            //     isExpanded: true,
                            //     underline: const SizedBox(),
                            //     icon: const Icon(Icons.keyboard_arrow_down),
                            //     value: _environment,
                            //     items: [
                            //       '安静',
                            //       '噪声',
                            //     ].map<DropdownMenuItem<String>>((String value) {
                            //       return DropdownMenuItem<String>(
                            //         value: value,
                            //         child: Text(value,style: const TextStyle(color: Colors.black87),),
                            //       );
                            //     }).toList(),
                            //     onChanged: (value) {
                            //       setState(() {
                            //         _environment = value.toString();
                            //       });
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.03),

                  /// 测听模式
                  Row(
                    children: [
                      const Text(
                        '测听模式：',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: SizeConfig.screenWidth * 0.05),
                        height: 60,
                        width: SizeConfig.screenWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: kSecondaryColor,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: SizeConfig.screenWidth * 0.01),
                            Expanded(
                              child: DropdownButton(
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                value: _testMode, //显示值
                                items: [
                                  '正式测听模式',
                                  '练习模式',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _testMode = value.toString();
                                    if (_testMode == '练习模式') {
                                      mode = 0;
                                      getSource("Exercise");
                                    } else {
                                      mode = 1;
                                      getSource("Normal");
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.03),

                  /// 测试播放表号
                  Row(
                    children: [
                      const Text(
                        '测试表号：',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.01),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: SizeConfig.screenWidth * 0.05),
                        height: 60,
                        width: SizeConfig.screenWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: kSecondaryColor,
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: SizeConfig.screenWidth * 0.01),
                            Expanded(
                              child: DropdownButton(
                                isExpanded: true,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                value: _table_index,
                                items: _tableList.map<DropdownMenuItem<String>>(
                                    (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _table_index = value.toString();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.03),

                  /// 测试播放声压级
                  Row(
                    children: [
                      const Text(
                        '播放音量（声压级）：',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.01),
                      SizedBox(
                        height: 60,
                        width: SizeConfig.screenWidth * 0.3,
                        child: TextFormField(
                          initialValue: "40",
                          keyboardType: TextInputType.number,
                          onSaved: (newValue) => _play_volume = newValue,
                          onChanged: (value) {
                            _play_volume = value.toString();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              _play_volume = '40';
                              return "";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(width: SizeConfig.screenWidth * 0.05),
                      const Text(
                        'dB',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                    ],
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.04),

                  /// 执行按钮
                  DefaultButton(
                    text: "执行",
                    press: () {
                      if (isFirstSession) {
                        /// '无助听状态'被视为首次访视Session，必须完成两张练习表访客执行正式测试
                        if (_testMode == '正式测听模式') {
                          if (ExerciseInfo.TableNumber_Finished >= 1) {
                            /// 已完成两张练习表
                            SaveSetting();
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AudiometryScreenPage(
                                      Mode: mode, //mode传递测听模式
                                    )));
                          } else {
                            /// 未完成两张练习表
                            setState(() {
                              AppTool().showDefineAlert(
                                  context, "提示", '该状态下必须先完成一张练习表！');
                            });
                          }
                        } else {
                          /// 练习模式
                          SaveSetting();
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AudiometryExercisePage()));
                        }
                      } else {
                        /// 非‘无助听状态’，即非必须完成两张练习表，可直接进行正式测试
                        SaveSetting();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AudiometryScreenPage(
                                  Mode: mode,
                                )));
                      }
                    },
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.03),

                  /// 返回上一级页面按钮
                  DefaultBorderButton(
                    text: "返回上一级页面",
                    press: () {
                      SaveSetting();

                      /// 路由跳转
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const HomeScreen()));
                    },
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
