
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xinyutest/Global/local_service.dart';
import 'package:xinyutest/config/size_config.dart';
import 'package:xinyutest/dal/user/user_manager.dart';
import 'package:xinyutest/screens/home/home_screen.dart';
import 'package:xinyutest/screens/audiogram/components/paint.dart';
import 'package:xinyutest/components/default_button.dart';
import 'package:xinyutest/screens/login_success/login_success_screen.dart';
import 'package:xinyutest/Global/audiogramData.dart';
import 'package:xinyutest/config/constants.dart';
import 'package:xinyutest/components/AppTool.dart';
import 'package:xinyutest/Global/dio_client.dart';
import 'package:xinyutest/Global/test_record.dart';

class audiogramPage extends StatefulWidget {
  const audiogramPage({super.key});

  @override
  State<audiogramPage> createState() => _audiogramPageState();
}

class _audiogramPageState extends State<audiogramPage> {
  @override
  var audioGramdata = audioGram.rightEarData;
  var dio = DioClient.dio;
  String? userId;

  ///判断是否上传成功
  bool _isSuccess = true;
  Widget build(BuildContext context) {
    var data = [
      List.generate(25, (index) => (index * 5).toString()).toList(),
      List.generate(25, (index) => (index * 5).toString()).toList(),
      List.generate(25, (index) => (index * 5).toString()).toList(),
      List.generate(25, (index) => (index * 5).toString()).toList(),
      List.generate(25, (index) => (index * 5).toString()).toList(),
      List.generate(25, (index) => (index * 5).toString()).toList(),
      List.generate(25, (index) => (index * 5).toString()).toList(),
    ];

    void _saveResult() async {
      try {
        if (audioGram.changeLeftEar) {
          var requestData = {
            "subjectId": TestRecord.subjectId,
            // "createTime": DateTime.now().toString(),
            "ear": audioGram.leftEar,
            "data": {
              "loss125Hz": audioGram.leftEarData[0][1],
              "loss250Hz": audioGram.leftEarData[1][1],
              "loss500Hz": audioGram.leftEarData[2][1],
              "loss1000Hz": audioGram.leftEarData[3][1],
              "loss2000Hz": audioGram.leftEarData[4][1],
              "loss4000Hz": audioGram.leftEarData[5][1],
              "loss8000Hz": audioGram.leftEarData[6][1]
            }
          };
          // var response = await dio.post(DioClient.baseurl + '/api/audiogram',
          //     data: requestData);
          var response = await postAudiogramResponse(userId, requestData);
          var res = response.data;
          var status = res["status"] as int;
          if (status == 0) {
            _isSuccess = true;
          } else {
            _isSuccess = false;
            var error = res["error"];
            setState(() {
              /// 警告，提示对话框
              AppTool().showDefineAlert(context, "警告", error);
            });
          }
        }
        if (audioGram.changeRightEar) {
          var requestData = {
            "subjectId": TestRecord.subjectId,
            // "createTime": DateTime.now().toString(),
            "ear": audioGram.rightEar,
            "data": {
              "loss125Hz": audioGram.rightEarData[0][1],
              "loss250Hz": audioGram.rightEarData[1][1],
              "loss500Hz": audioGram.rightEarData[2][1],
              "loss1000Hz": audioGram.rightEarData[3][1],
              "loss2000Hz": audioGram.rightEarData[4][1],
              "loss4000Hz": audioGram.rightEarData[5][1],
              "loss8000Hz": audioGram.rightEarData[6][1]
            }
          };
          // var response = await dio.post(DioClient.baseurl + '/api/audiogram',
          //     data: requestData);

          var response = await postAudiogramResponse(userId, requestData);
          var res = response.data;
          var status = res["status"] as int;
          if (status == 0) {
            _isSuccess = true;
          } else {
            _isSuccess = false;
            var error = res["error"];
            setState(() {
              /// 警告，提示对话框
              AppTool().showDefineAlert(context, "警告", error);
            });
          }
        }
        if (audioGram.changeLeftEar & _isSuccess ||
            audioGram.changeRightEar & _isSuccess ||
            _isSuccess) {
          audioGram.changeLeftEar = false;
          audioGram.changeRightEar = false;
          for (int i = 0; i < audioGram.leftEarData.length; i++) {
            audioGram.leftEarData[i][1] = 0.0;
            audioGram.rightEarData[i][1] = 0.0;
          }
          setState(() {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => LoginSuccessScreen(
                      textValue: true,
                    )));
          });
        }
      } catch (e) {
        _isSuccess = false;
        setState(() {
          /// 警告，提示对话框
          AppTool().showDefineAlert(context, "错误", '请检查网络连接！');
        });
        return;
      }
    }

    @override
    void initState() {
      super.initState();
      userId = UserManager().currentUser!.userphone;
    }

    @override
    void dispose() {
      for (int i = 0; i < audioGram.leftEarData.length; i++) {
        audioGram.leftEarData[i][1] = 0.0;
        audioGram.rightEarData[i][1] = 0.0;
      }
      super.dispose();
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(
          '听力图',
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
          child: Column(
        children: [
          const Text('提示'),
          paintAudiogram(),
          SizedBox(
            height: SizeConfig.screenHeight * 0.05,
          ),
          SizedBox(
              height: getProportionateScreenHeight(56),
              width: SizeConfig.screenWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // IconButton(onPressed: () {}, icon: Icon()),
                  TextButton(
                      style: TextButton.styleFrom(
                        minimumSize:
                            Size(SizeConfig.screenWidth / 4, double.infinity),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        foregroundColor: Colors.white,
                        backgroundColor:
                            audioGram.isRightEar ? kPrimaryColor : Colors.red,
                      ),
                      onPressed: () {
                        setState(() {
                          setState(() {
                            audioGramdata = audioGram.leftEarData;
                            audioGram.isRightEar = false;
                          });
                        });
                      },
                      child: Text(
                        '左耳',
                        style: TextStyle(
                          fontSize: getProportionateScreenWidth(18),
                          color: Colors.white,
                        ),
                      )),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize:
                          Size(SizeConfig.screenWidth / 4, double.infinity),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      foregroundColor: Colors.white,
                      backgroundColor:
                          audioGram.isRightEar ? Colors.red : kPrimaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        audioGramdata = audioGram.rightEarData;
                        audioGram.isRightEar = true;
                      });
                    },
                    child: Text(
                      '右耳',
                      style: TextStyle(
                        fontSize: getProportionateScreenWidth(18),
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              )),
          SizedBox(
            height: SizeConfig.screenHeight * 0.02,
          ),
          DefaultButton(
            press: () {
              return Pickers.showMultiPicker(context, data: data,
                  onConfirm: (p, position) {
                setState(() {
                  if (audioGram.isRightEar) {
                    for (int i = 0; i < p.length; i++) {
                      double temp = double.parse(p[i]);
                      audioGram.rightEarData[i][1] = temp;
                    }
                    audioGram.changeRightEar = true;
                    audioGramdata = audioGram.rightEarData;
                  } else {
                    for (int i = 0; i < p.length; i++) {
                      double temp = double.parse(p[i]);
                      audioGram.leftEarData[i][1] = temp;
                    }
                    audioGram.changeLeftEar = true;
                    audioGramdata = audioGram.leftEarData;
                  }
                });

                print('longer >>> 返回数据下标：${position.join(',')}');
                print(
                    'longer >>> 返回数据类型：${p.map((x) => x.runtimeType).toList()}');
              },
                  pickerStyle: PickerStyle(
                    showTitleBar: true,
                    menu: _headMenuView,
                  ));
            },
            text: '添加听力数据',
          ),
          SizedBox(
            height: SizeConfig.screenHeight * 0.02,
          ),
          DefaultButton(
              press: () {
                _saveResult();
              },
              text: '保存')
        ],
      )),
    );
  }
}

TextStyle pickermenu = TextStyle(color: Colors.white, fontSize: 14);
Widget _headMenuView = Container(
    color: Color.fromARGB(255, 168, 164, 164),
    height: 36,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Expanded(child: Center(child: Text('125Hz', style: pickermenu))),
      Expanded(child: Center(child: Text('250Hz', style: pickermenu))),
      Expanded(child: Center(child: Text('500Hz', style: pickermenu))),
      // Expanded(child: Center(child: Text('750Hz', style: pickermenu))),
      Expanded(child: Center(child: Text('1kHz', style: pickermenu))),
      // Expanded(child: Center(child: Text('1.5kHz', style: pickermenu))),
      Expanded(child: Center(child: Text('2kHz', style: pickermenu))),
      // Expanded(child: Center(child: Text('3kHz', style: pickermenu))),
      Expanded(child: Center(child: Text('4kHz', style: pickermenu))),
      // Expanded(child: Center(child: Text('6kHz', style: pickermenu))),
      Expanded(child: Center(child: Text('8kHz', style: pickermenu))),
    ]));
