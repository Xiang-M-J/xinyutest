import 'package:flutter/material.dart';
import 'package:xinyutest/Global/user_role.dart';
import 'package:xinyutest/screens/subject_management/components/subjects_list.dart';
import '../../../Global/dio_client.dart';
import '../../../Global/subject_list.dart';
import '../../../Global/test_record.dart';
import '../../../components/AppTool.dart';
import '../../../components/default_border_button.dart';
import '../../../config/size_config.dart';
import '../../audiometry/components/search_field.dart';
import '../../subject/subject_screen.dart';

class SubjectManagementForm extends StatefulWidget {
  @override
  _SubjectManagementFormState createState() => _SubjectManagementFormState();
}

class _SubjectManagementFormState extends State<SubjectManagementForm> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String sex = '';
  String birthday = '';
  String putonghua_level = '';
  String phone = '';
  String wearlog = '';
  final List<String?> errors = [];

  DateTime? newDate = DateTime.now();

  late StateSetter _deleteSetter;

  var dio = DioClient.dio;
  String searchName = '';

  void _getSubjects() async {
    try {
      var response = await dio.get(
        DioClient.baseurl + '/api/subject',
      );
      var res = response.data;
      var status = res["status"] as int;
      if (status == 0) {
        SubjectsList.subjects = res["data"];

        for (int i = 0; i < SubjectsList.subjects.length; i++) {
          // 添加复选框标记
          var t = SubjectsList.subjects[i];
          t["check"] = false;
          SubjectsList.subjects[i] = t;
        }
        setState(() {});
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
  void initState() {
    super.initState();
    _getSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          /// 新增、编辑、删除
          SizedBox(
            width: SizeConfig.screenWidth * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 新增按钮
                SizedBox(
                  width: SizeConfig.screenWidth * 0.23,
                  child: DefaultBorderButton(
                    text: "新增",
                    press: () {
                      Navigator.pushNamed(context, SubjectScreen.routeName);
                    },
                  ),
                ),
                SizedBox(
                  width: SizeConfig.screenWidth * 0.05,
                ),

                /// 编辑按钮
                SizedBox(
                  width: SizeConfig.screenWidth * 0.23,
                  child: DefaultBorderButton(
                    text: "编辑",
                    press: () {
                      /// 检查是否只有一位被试被选中
                      int isChecked_Count = 0;
                      for (int i = 0; i < SubjectsList.subjects.length; i++) {
                        if (SubjectsList.subjects[i]["check"] == true) {
                          isChecked_Count++;
                          TestRecord.subjectId = SubjectsList.subjects[i]["id"];
                        }
                      }
                      if (isChecked_Count > 1) {
                        // 若多于一位则操作不被允许
                        AppTool()
                            .showDefineAlert(context, "警告", "编辑用户一次只可选中一位！");
                      } else if (isChecked_Count == 1) {
                        // 若只有一位则更新标志位,并进入编辑页面
                        TestRecord.isNewSubject = 0;

                        Navigator.pushNamed(context, SubjectScreen.routeName);
                      } else {
                        // 若没有用户被选中
                        AppTool().showDefineAlert(context, "提示", "请先选中编辑对象！");
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: SizeConfig.screenWidth * 0.05,
                ),

                /// 删除按钮
                SizedBox(
                  width: SizeConfig.screenWidth * 0.23,
                  child: DefaultBorderButton(
                    text: "删除",
                    press: () async {
                      if (UserRole.role == '数据收集') {
                        AppTool().showDefineAlert(context, '提示', "没有权限删除！");
                      } else {
                        int isChecked_Count = 0;
                        int isSucceed = 0;
                        int isFailed = 0;
                        var tmpList = [];   // 存储未被删除的数据
                        for (int i = 0; i < SubjectsList.subjects.length; i++) {
                          if (SubjectsList.subjects[i]["check"] == true) {
                            isChecked_Count++;
                            TestRecord.subjectId =
                                SubjectsList.subjects[i]["id"];
                            try {
                              var response = await dio.delete(
                                DioClient.baseurl +
                                    '/api/subject/' +
                                    TestRecord.subjectId.toString(),
                              );
                              var res = response.data;
                              var status = res["status"] as int;
                              if (status == 0) {
                                isSucceed++;
                              } else {
                                isFailed++;
                                tmpList.add(SubjectsList.subjects[i]);
                              }
                            } catch (e) {
                              setState(() {
                                /// 警告，提示对话框
                                AppTool()
                                    .showDefineAlert(context, "错误", '请检查网络连接！');
                              });
                              return;
                            }
                          }else{
                            tmpList.add(SubjectsList.subjects[i]);
                          }
                        }
                        
                        String tips = '';
                        if (isChecked_Count == 0) {
                          tips = '未选中用户！';
                        } else {
                          tips = '操作完成！';
                          if (isSucceed > 0) {
                            tips += '成功' + isSucceed.toString() + '位.';
                          }
                          if (isFailed > 0) {
                            tips += '失败' + isSucceed.toString() + '位.';
                          }
                        }
                       
                        AppTool().showDefineAlert(context, '提示', tips);

                        SubjectsList.subjects = tmpList;
                        _deleteSetter(() {});
                        setState(() {});
                        
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: getProportionateScreenHeight(20)),

          /// 查找 按姓或者名
          SearchField(
            onChanged: (value) async {
              searchName = value;
              try {
                var response = await dio.get(
                  DioClient.baseurl + '/api/subject/' + searchName,
                );
                var res = response.data;
                var status = res["status"] as int;
                if (status == 0) {
                  SubjectsList.subjects = res["data"];

                  /// 获取对应的测试记录
                  for (int i = 0; i < SubjectsList.subjects.length; i++) {
                    // 用于复选框
                    var t = SubjectsList.subjects[i];
                    t["check"] = false;
                    SubjectsList.subjects[i] = t;

                    // String idStr = SubjectsList.subjects[i]["id"].toString();
                    // var responseRecords = await dio.get(
                    //   DioClient.baseurl +
                    //       '/api/subject/' +
                    //       idStr +
                    //       "/testrecords",
                    // );
                    // var resRecords = responseRecords.data;
                    // var statusRecords = resRecords["status"] as int;
                    // if (statusRecords == 0) {
                    //   SubjectsList.subjects[i]["testrecords"] =
                    //       resRecords["data"];
                    // }
                  }
                  setState(() {});
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
            },
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
          StatefulBuilder(
              builder: (BuildContext context, StateSetter stateSetter) {
            _deleteSetter = stateSetter;
            return SizedBox(
              height: getProportionateScreenHeight(480),
              width: SizeConfig.screenWidth,
              child: SubjectListView(),
            );
          })
        ],
      ),
    );
  }
}
