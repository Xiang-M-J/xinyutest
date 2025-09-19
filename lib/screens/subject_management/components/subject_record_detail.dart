import 'package:flutter/material.dart';
import 'package:xinyutest/Global/dio_client.dart';
import 'package:xinyutest/Global/test_record.dart';
import 'package:xinyutest/components/AppTool.dart';
import 'package:xinyutest/config/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xinyutest/config/size_config.dart';

class SubjectRecordDetail extends StatefulWidget {
  const SubjectRecordDetail({super.key});
  @override
  State<SubjectRecordDetail> createState() => _SubjectRecordDetailState();
}

class _SubjectRecordDetailState extends State<SubjectRecordDetail> {
  var dio = DioClient.dio;
  List _result = List.empty();

  //获取测听详情
  void _getResource() async {
    String idStr = TestRecord.id.toString();
    try {
      var response =
          await dio.get(DioClient.baseurl + '/api/testrecord/' + idStr);
      var res = response.data;
      var status = res["status"] as int;
      if (status == 0) {
        _result = res["data"]["result"];
      }
      setState(() {});
    } catch (e) {
      setState(() {
        AppTool().showDefineAlert(context, "错误", '请检查网络连接！');
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getResource();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TestRecordDetail'),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Text(
            '测听详情',
            style: headingStyle,
          ),
          SizedBox(
            height: SizeConfig.screenHeight * 0.01,
          ),
          SizedBox(
            height: SizeConfig.screenHeight * 0.7,
            child: ListView.builder(
              itemCount: _result.length ?? 1,
              itemBuilder: (BuildContext context, int index) {
                return Column(children: [
                  Text(
                    (index + 1).toString(),
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: _result[index]
                        .map<Widget>((e) => Column(
                              children: [
                                Text(e["keyword"],
                                    style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                        letterSpacing: 5)),
                                SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: e["check"]
                                        ? SvgPicture.asset(
                                            "assets/icons/gouxuan.svg",
                                            color: kPrimaryColor,
                                          )
                                        : SvgPicture.asset(
                                            "assets/icons/weigouxuanv2.svg",
                                            color: Colors.black,
                                          )),
                              ],
                            ))
                        .toList(),
                  ),
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.05,
                    // width: SizeConfig.screenWidth * 0.8,
                    // child: Divider(
                    //   height: 2,
                    //   color: Colors.black,
                    // ),
                  )
                ]);
              },
            ),
          )
        ],
      )),
    );
  }
}
