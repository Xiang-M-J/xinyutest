import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xinyutest/Global/subject_list.dart';
import 'package:xinyutest/config/size_config.dart';
import '../../../Global/calibration_values.dart';
import '../../../Global/dio_client.dart';
import '../../../Global/exercise.dart';
import '../../../Global/get_device_info.dart';
import '../../../Global/test_record.dart';
import '../../../components/AppTool.dart';
import '../../../config/constants.dart';
import '../../audiometry/setting_audio.dart';
import '../subject_record.dart';
import 'package:xinyutest/Global/exercise.dart';
import 'package:xinyutest/screens/audiometry/noisemeter_audio.dart';

class SubjectListView extends StatefulWidget {
  @override
  _SubjectListViewState createState() => _SubjectListViewState();
}

class _SubjectListViewState extends State<SubjectListView> {
  bool isCheccked = false;

  /// 当日是否进行过声场校准
  bool isCalibration = false;
  bool isChecked = false;
  var dio = DioClient.dio;

  /// 获取设备信息
  // void getDeviceInfo(bool isJump) async {
  //   var platformUid = await FlutterDeviceInfo.platformUid;
  //   var platformName = await FlutterDeviceInfo.platformName;
  //   var platformModel = await FlutterDeviceInfo.platformModel;
  //   String deviceInfo =
  //       '(platformUid:$platformUid)(platformName:$platformName)(platformModel:$platformModel)';
  //   print(deviceInfo);
  //   CalibrationValue.testingDevice = deviceInfo;
  //   // 模拟器输出结果：(platformUid:a2040622850563f0)(platformName:beyond1q)(platformModel:samsung SM-G977Ng)

  //   // 查询当日是否进行过声场校准
  //   checkIsCalibration(isJump);
  // }

  // /// 检查当日是否进行过声场校准
  // void checkIsCalibration(bool isJump) async {
  //   try {
  //     print("checkIsCalibration:" + CalibrationValue.testedDevice);
  //     String str = CalibrationValue.testingDevice +
  //         ',' +
  //         CalibrationValue.testedDevice +
  //         ',' +
  //         DateTime.now().toString().substring(0, 10);
  //     var response =
  //         await dio.get(DioClient.baseurl + '/api/devicecalibration/' + str);
  //     var res = response.data;
  //     var status = res["status"] as int;
  //     isChecked = true;
  //     if (status == 0) {
  //       setState(() {
  //         var responseData = res["data"];
  //         CalibrationValue.micCalibrationDB =
  //             responseData["microphoneCalibrationValue"];
  //         CalibrationValue.calibrationDB =
  //             responseData["speakerCalibrationValue"];
  //         num temp = responseData["playVolume"];
  //         CalibrationValue.calibrationVolume = temp.toDouble();
  //         isCalibration = true;
  //         if (isJump) {
  //           print(TestRecord.subjectId);

  //           /// 路由跳转
  //           Navigator.of(context).push(
  //               MaterialPageRoute(builder: (context) => NoiseMeterAudioPage()));
  //         }
  //       });
  //     } else {
  //       var error = res["error"];
  //       setState(() {
  //         isCalibration = false;
  //         if (isJump) {
  //           /// 警告，提示对话框
  //           AppTool().showDefineAlert(context, "提示", '请先进行声场校准！');
  //         }
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isCalibration = false;
  //       if (isJump) {
  //         /// 警告，提示对话框
  //         AppTool().showDefineAlert(context, "错误", '请检查网络连接！');
  //       }
  //     });
  //     return;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (SubjectsList.subjects == null) {
      return Container();
    } else {
      return ListView.builder(
        itemCount: SubjectsList.subjects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(SubjectsList.subjects[index]['name']),
            subtitle: Text(
                (SubjectsList.subjects[index]['gender'] == 'male' ? '男' : '女') +
                    '  ' +
                    SubjectsList.subjects[index]['phoneNumber']),
            leading: Checkbox(
              value: SubjectsList.subjects[index]['check'] ?? false,
              activeColor: kPrimaryColor,
              onChanged: (value) {
                setState(() {
                  SubjectsList.subjects[index]['check'] = value;
                });
              },
            ),
            onTap: () {
              /// 点击查看历史测听记录
              TestRecord.subjectId = SubjectsList.subjects[index]["id"];
              SubjectsList.index = index;

              /// 路由跳转
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SubjectRecordForm()));
            },
          );
        },
      );
    }
  }
}
