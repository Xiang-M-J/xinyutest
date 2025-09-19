import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xinyutest/Global/dio_client.dart';
import '../../Global/subject_list.dart';
import '../../Global/test_record.dart';
import '../../config/constants.dart';
import '../../config/size_config.dart';
import 'package:xinyutest/components/AppTool.dart';
import 'package:xinyutest/screens/subject_management/components/subject_record_detail.dart';
import 'package:xinyutest/Global/user_role.dart';

class SubjectRecordForm extends StatefulWidget {
  @override
  _SubjectRecordFormState createState() => _SubjectRecordFormState();
}

class _SubjectRecordFormState extends State<SubjectRecordForm> {
  var dio = DioClient.dio;

  var _sourceData;
  // var keyWords;

  // 获取对应的测试记录
  void _getTestRecord() async {
    try {
      String idStr = TestRecord.subjectId.toString();
      var response = await dio.get(
        DioClient.baseurl + '/api/subject/' + idStr,
      );
      var res = response.data;
      var status = res["status"] as int;
      if (status == 0) {
        _sourceData = res["data"];
      }
      var responseRecords = await dio.get(
        DioClient.baseurl + '/api/subject/' + idStr + '/testrecords',
      );
      var resrecords = responseRecords.data;
      var statusrecords = resrecords["status"] as int;
      if (statusrecords == 0) {
        _sourceData["testrecords"] = resrecords["data"];
        //测试代码
      }
      setState(() {});
    } catch (e) {
      setState(() {
        /// 警告，提示对话框
        AppTool().showDefineAlert(context, "错误", '请检查网络连接！');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initial();
    _getTestRecord();

    print('object');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SubjectRecord"),
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
                  Text("测听记录", style: headingStyle),
                  SizedBox(height: SizeConfig.screenHeight * 0.04),
                  _subjectView(_sourceData),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container _subjectView(var sourceData) {
    if (sourceData == null) {
      return Container();
    } else {
      return Container(
        width: SizeConfig.screenWidth * 0.8,
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "姓名：" + sourceData["name"],
              style: const TextStyle(color: Colors.black87, fontSize: 20.0),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.02),
            Text(
              "性别：" + (sourceData["gender"] == "male" ? "男" : "女"),
              style: const TextStyle(color: Colors.black87, fontSize: 18.0),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Text(
              "出生日期：" + sourceData["birthDate"].toString().substring(0, 10),
              style: const TextStyle(color: Colors.black87, fontSize: 18.0),
            ),
            //Text(e["birthDate"].toString().substring(0,10)),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Text(
              "手机号：" + sourceData["phoneNumber"],
              style: const TextStyle(color: Colors.black87, fontSize: 18.0),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            Text(
              "测试点位：" + sourceData["teamIndex"].toString(),
              style: const TextStyle(color: Colors.black87, fontSize: 18.0),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),
            const Text(
              "测试记录：",
              style: TextStyle(color: Colors.black87, fontSize: 18.0),
            ),
            SizedBox(height: SizeConfig.screenHeight * 0.01),

            _subjectTestRecords(_sourceData["testrecords"]),
          ],
        ),
      );
    }
  }

  SizedBox _subjectTestRecords(var sourceData) {
    if (sourceData == null || sourceData.length == 0) {
      return SizedBox();
    } else {
      return SizedBox(
        height: SizeConfig.screenHeight * 0.5,
        width: double.infinity,
        child: ListView(
          children: sourceData.map<Widget>((e) {
            return Column(children: [
              ListTile(
                title: Text(
                    "模式: " +
                        e["mode"] +
                        "\n" +
                        "时间：" +
                        e["createTime"].toString().substring(0, 16) +
                        "\n" +
                        "正确率：" +
                        e["accuracy"],
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                subtitle: Text(
                    "表号:" +
                        e["tableId"].toString() +
                        "    强度：" +
                        e["playVolume"].toString() +
                        "dB A",
                    style: TextStyle(color: Colors.black, fontSize: 18)),
                onTap: () {
                  if (UserRole.role == '数据主管') {
                    if (e["result"].length == 0) {
                      setState(() {
                        AppTool()
                            .showDefineAlert(context, "提示", "该条测试记录无测听详情！");
                      });
                    } else {
                      TestRecord.id = e["id"];
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SubjectRecordDetail()));
                    }
                  } else {
                    AppTool().showDefineAlert(context, "提示", "只有数据主管才能查看测听详情");
                  }
                },
              ),
              Divider(
                height: 2,
                color: Colors.black,
              )
            ]);
          }).toList(),
        ),
      );
    }
  }
}
