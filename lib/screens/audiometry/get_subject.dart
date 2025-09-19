import 'package:flutter/material.dart';
import 'package:xinyutest/screens/audiometry/setting_audio.dart';
import '../../Global/dio_client.dart';
import '../../Global/exercise.dart';
import '../../Global/test_record.dart';
import '../../components/AppTool.dart';
import '../../components/default_border_button.dart';
import '../../components/default_button.dart';
import '../../config/constants.dart';
import '../../config/size_config.dart';
import '../home/home_screen.dart';
import 'components/search_field.dart';
import 'noisemeter_audio.dart';
import 'package:xinyutest/Global/subject_list.dart';
import 'package:xinyutest/Global/calibration_values.dart';

/// 查找被试者页 -- 言语测听使用
class GetSubjectPage extends StatefulWidget {
  /// 模式
  final int Mode;
  GetSubjectPage({Key? key, this.Mode = 0}) : super(key: key);
  @override
  GetSubjectPageState createState() => GetSubjectPageState();
}

class GetSubjectPageState extends State<GetSubjectPage> {
  var dio = DioClient.dio;
  String searchName = '';
  var searchResult;
  var searchResultTestRecord;
  @override
  void initState() {
    super.initState();
    searchResult = SubjectsList.subjects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text(
          '言语测听',
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
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
                  const Text(
                    '信息确定：',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
                  const Text('    检索框中输入姓或名；若未找到，请先返回主页，添加被试者详细信息。',
                      style: TextStyle(
                          color: Colors.black87, fontSize: 16, height: 2.0)),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
                  SearchField(
                    onChanged: (value) async {
                      searchName = value;
                      try {
                        //拉取符合条件的id—list
                        var response = await dio.get(
                          DioClient.baseurl + '/api/subject/' + searchName,
                        );
                        var res = response.data;
                        var status = res["status"] as int;
                        if (status == 0) {
                          searchResult = res["data"];

                          /// 获取对应id的测试记录
                          // for (int i = 0; i < searchResult.length; i++) {
                          //   String idStr = searchResult[i]["id"].toString();
                          //   var responseRecords = await dio.get(
                          //     DioClient.baseurl +
                          //         '/api/subject/' +
                          //         idStr +
                          //         "/testrecords",
                          //   );
                          //   var resRecords = responseRecords.data;
                          //   var statusRecords = resRecords["status"] as int;
                          //   if (statusRecords == 0) {
                          //     searchResult[i]["testrecords"] =
                          //         resRecords["data"];
                          //   }
                          // }
                          setState(() {});
                        } else {
                          //拉取的数据的state出错，弹窗警告
                          var error = res["error"];
                          setState(() {
                            /// 警告，提示对话框
                            AppTool().showDefineAlert(context, "警告", error);
                          });
                        }
                      } catch (e) {
                        //访问API出错，弹窗警告
                        setState(() {
                          /// 警告，提示对话框
                          AppTool().showDefineAlert(context, "错误", '请检查网络连接！');
                        });
                        return;
                      }
                    },
                  ),
                  SizedBox(height: SizeConfig.screenHeight * 0.02),
                  //将搜索栏拉取的被试者list输入，生成信息栏
                  _subjectView(searchResult),

                  SizedBox(height: SizeConfig.screenHeight * 0.03),

                  /// 返回主页按钮
                  SizedBox(
                    width: SizeConfig.screenWidth * 0.8,
                    child: DefaultButton(
                      text: '返回上一级页面',
                      press: () {
                        /// 路由跳转
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const HomeScreen()));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _subjectView(var sourceData) {
    //信息栏生成
    if (sourceData == null) {
      return Container();
    } else {
      return Container(
        height: SizeConfig.screenHeight * 0.5,
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: sourceData
              .map<Widget>((e) => Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: SizeConfig.screenWidth * 0.1,
                          right: SizeConfig.screenWidth * 0.1,
                          top: SizeConfig.screenHeight * 0.01),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e["name"],
                            style: const TextStyle(
                                color: Colors.black87, fontSize: 20.0),
                          ),
                          SizedBox(height: SizeConfig.screenHeight * 0.01),
                          Text((e["gender"] == "male" ? "男" : "女") +
                              "    " +
                              e["birthDate"].toString().substring(0, 10)),
                          //Text(e["birthDate"].toString().substring(0,10)),
                          Text(e["phoneNumber"]),
                          _subjectTestRecords(e["testrecords"]),
                          ButtonBar(
                            children: [
                              OutlinedButton(
                                  onPressed: () {
                                    TestRecord.subjectId = e["id"];
                                    ExerciseInfo.TableNumber_Finished = 0;

                                    /// 路由跳转
                                    if (CalibrationValue
                                        .newCalibrationFinished) {
                                      CalibrationValue.newCalibrationFinished =
                                          false;
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SettingAudioPage()));
                                    } else {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  NoiseMeterAudioPage()));
                                    }
                                  },
                                  child: Text('进入测试'.toUpperCase()))
                              /* FlatButton(
                                child: Text('进入测试'.toUpperCase()),
                                onPressed: () {
                                  TestRecord.subjectId = e["id"];
                                  ExerciseInfo.TableNumber_Finished = 0;

                                  /// 路由跳转
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          SettingAudioPage()));
                                },
                              ) */
                            ],
                          )
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      );
    }
  }

  Column _subjectTestRecords(var sourceData) {
    if (sourceData == null) {
      return Column();
    } else {
      return Column(
        children: sourceData
            .map<Widget>((e) => Text(
                e["createTime"].toString().substring(0, 19) +
                    "    " +
                    e["result"]))
            .toList(),
      );
    }
  }
}

//Card示例：用于测试！
// class example extends StatefulWidget {
//   const example({super.key});

//   @override
//   State<example> createState() => _exampleState();
// }

// class _exampleState extends State<example> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: SizeConfig.screenHeight * 0.5,
//         padding: const EdgeInsets.all(10),
//         child: ListView(children: [
//           Card(
//             elevation: 10,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Padding(
//               padding: EdgeInsets.only(
//                   left: SizeConfig.screenWidth * 0.1,
//                   right: SizeConfig.screenWidth * 0.1,
//                   top: SizeConfig.screenHeight * 0.01),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "name",
//                     style:
//                         const TextStyle(color: Colors.black87, fontSize: 20.0),
//                   ),
//                   SizedBox(height: SizeConfig.screenHeight * 0.01),
//                   Text(("男") + "    " + "birthDate"),
//                   //Text(e["birthDate"].toString().substring(0,10)),
//                   Text("phoneNumber"),
//                   ButtonBar(
//                     children: [
//                       OutlinedButton(
//                           onPressed: () {
//                             TestRecord.subjectId = 5;
//                             ExerciseInfo.TableNumber_Finished = 0;

//                             /// 路由跳转
//                             Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) => NoiseMeterPage()));
//                           },
//                           child: Text('进入测试'.toUpperCase()))
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           )
//         ]));
//   }
// }
