import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xinyutest/Global/local_service.dart';
import 'package:xinyutest/dal/user/user_manager.dart';
import '../../../Global/dio_client.dart';
import '../../../components/AppTool.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/default_button.dart';
import '../../../components/form_erroe.dart';
import '../../../components/rounded_data_field.dart';
import '../../../components/rounded_input_field.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';
import '../../login_success/login_success_screen.dart';
import 'package:xinyutest/Global/test_record.dart';

class SubjectForm extends StatefulWidget {
  @override
  _SubjectFormState createState() => _SubjectFormState();
}

class _SubjectFormState extends State<SubjectForm> {
  final _formKey = GlobalKey<FormState>();
  bool isNew = true;
  String name = '';
  String sex = '';
  String birthday = '';
  String putonghua_level = '';
  String phone = '';
  String wearlog = '';
  String? userId;

  ///

  TextEditingController wearLogController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  final List<String?> errors = [];

  DateTime? newDate = DateTime.now();

  var dio = DioClient.dio;

  void addError({String? error}) {
    if (!errors.contains(error)) {
      setState(() {
        errors.add(error);
      });
    }
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  Future<void> _getSubjectInfo() async {
    if (TestRecord.isNewSubject == 0) {
      isNew = false;
      TestRecord.isNewSubject = -1;
      try {
        // var response = await dio.get(
        //   DioClient.baseurl + '/api/subject/' + TestRecord.subjectId.toString(),
        // );
        var response = await getSubjectByIdResponse(userId, TestRecord.subjectId);
        var res = response.data;
        var status = res["status"] as int;
        if (status == 0) {
          var subjectInfo = res["data"];
          nameController.text = subjectInfo["name"];
          name = subjectInfo["name"];
          if (subjectInfo["gender"] == 'male') {
            sex = '男';
          } else {
            sex = '女';
          }
          birthday = subjectInfo["birthDate"].toString().substring(0, 10);
          putonghua_level = subjectInfo["putonghuaLevel"];
          putonghua_level = subjectInfo["putonghuaLevel"];
          phoneController.text = subjectInfo["phoneNumber"];
          phone = subjectInfo["phoneNumber"];
          wearLogController.text = subjectInfo["wearLog"];
          wearlog = subjectInfo["wearLog"];
          print(subjectInfo);
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
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userId = UserManager().currentUser?.userphone;
    _getSubjectInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildNameFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildSexFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildBirthdayFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPhoneFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPutonghuaFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildWearlogFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButton(
            text: "保存",
            press: () async {
              //测试代码
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => LoginSuccessScreen(textValue: true)));

              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();

                // if (errors.isNotEmpty) {
                //   String error = errors.join('\n');
                //   AppTool().showDefineAlert(context, '警告', error);
                // }
                try {
                  var requestData = {
                    "name": name,
                    "gender": sex == '女' ? 'female' : 'male',
                    "birthDate": birthday,
                    "phoneNumber": phone,
                    "putonghuaLevel": putonghua_level,
                    "wearLog": wearlog,
                  };

                  if (isNew) {
                    // var response = await dio.post(
                    //     DioClient.baseurl + '/api/subject',
                    //     data: requestData);
                    
                    var response = await postSubjectResponse(userId, requestData);

                    var res = response.data;
                    var status = res["status"] as int;
                    if (status == 0) {
                      // var responseData = res["data"];

                      setState(() {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                LoginSuccessScreen(textValue: true)));
                      });
                    } else {
                      var error = res["error"];
                      setState(() {
                        /// 警告，提示对话框
                        AppTool().showDefineAlert(context, "警告", error);
                      });
                    }
                  } else {
                    // var response = await dio.put(
                    //     DioClient.baseurl +
                    //         '/api/subject/' +
                    //         TestRecord.subjectId.toString(),
                    //     data: requestData);
                      
                    var response = await putSubjectResponse(userId, TestRecord.subjectId, requestData);
                    
                    var res = response.data;
                    var status = res["status"] as int;
                    if (status == 0) {
                      var responseData = res["data"];

                      setState(() {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                LoginSuccessScreen(textValue: true)));
                      });
                    } else {
                      var error = res["error"];
                      setState(() {
                        /// 警告，提示对话框
                        AppTool().showDefineAlert(context, "警告", error);
                      });
                    }
                  }
                } catch (e) {
                  setState(() {
                    /// 警告，提示对话框
                    AppTool().showDefineAlert(context, "错误", '请输入所有项或检查网络连接！');
                  });
                  return;
                }
              }
            },
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  TextFormField buildNameFormField() {
    return TextFormField(
      //onSaved: (newValue) => name = newValue,
      controller: nameController,
      onChanged: (value) {
        name = value;
        if (value.isNotEmpty) {
          removeError(error: kNameNullError); //kNameNullError = "请输入你的名字"
        }
        if (nameValidatorRegExp.hasMatch(value)) {
          removeError(
              error: kInvalidNameError); //kInvalidNameError = "请输入有效的姓名"
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNameNullError);
          return "";
        } else if (!nameValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidNameError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "姓名",
        hintText: "输入被试者的姓名",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  RoundedInputField buildSexFormField() {
    return RoundedInputField(
      label: '性别',
      text: sex != null ? sex.toString() : '',
      hintText: "请输入被试者的性别",
      onChanged: (value) {
        sex = value;
      },
      ontap: () async {
        var result = await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                title: const Text('请选择性别'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: const Text('男'),
                    onPressed: () {
                      //选中后返回上一个页面并传递‘男’或‘女’作为value赋值给sex
                      Navigator.of(context).pop('男');
                    },
                    isDefaultAction: true,
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('女'),
                    onPressed: () {
                      Navigator.of(context).pop('女');
                    },
                    isDestructiveAction: true,
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
        // 修改界面内容
        setState(() {
          if (result != 'cancel') {
            sex = result;
          }
        });
      },
    );
  }

  RoundedDateField buildBirthdayFormField() {
    return RoundedDateField(
      label: '出生日期',
      hintText: "请输入被试者的出生日期",
      //显示的文本内容
      text: birthday != null ? birthday.toString() : '',
      //点击选择输入项
      ontap: () async {
        final currentDate = DateTime.now();
        var result = await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              //制作一个日期弹窗
              return CupertinoAlertDialog(
                title: const Text('请选择出生日期'),
                content: SizedBox(
                  width: 0.90 * SizeConfig.screenWidth,
                  height: 0.3 * SizeConfig.screenHeight, //width: 0.95.sw,

                  ////日期选择器
                  child: CupertinoDatePicker(
                    //backgroundColor: Colors.white70,
                    initialDateTime: currentDate,
                    maximumDate: currentDate,
                    minimumYear: 1800,
                    mode: CupertinoDatePickerMode.date,
                    onDateTimeChanged: (dateTime) {
                      newDate = dateTime;
                      //Navigator.of(context).pop(dateTime);
                    },
                  ),
                ),
                actions: <Widget>[
                  SizedBox(
                      //width: 0.45 * size.width,
                      child: CupertinoDialogAction(
                    child: const Text("取消"),
                    onPressed: () {
                      Navigator.pop(context, "取消");
                    },
                  )),
                  SizedBox(
                    //width: 0.45 * size.width,
                    child: CupertinoDialogAction(
                      child: const Text("确定"),
                      onPressed: () {
                        Navigator.pop(context, "确定");
                      },
                    ),
                  ),
                ],
              );
            });
        // 修改界面内容
        setState(() {
          if (result == "确定") {
            birthday = newDate.toString().substring(0, 10);
          }
        });
      },
      onChanged: (value) {},
    );
  }

  TextFormField buildPhoneFormField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      //onSaved: (newValue) => phone = newValue,
      onChanged: (value) {
        phone = value;
        if (value.isNotEmpty) {
          removeError(
              error:
                  kPhoneNumberNullError); //kPhoneNumberNullError = "请输入你的手机号码"
        }
        if (phoneValidatorRegExp.hasMatch(value)) {
          removeError(
              error: kInvalidPhoneError); //kInvalidPhoneError = "请输入有效的手机号码"
        }
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPhoneNumberNullError);
          return "";
        } else if (!phoneValidatorRegExp.hasMatch(value)) {
          addError(error: kInvalidPhoneError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "手机号",
        hintText: "输入被试者的手机号码",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  RoundedInputField buildPutonghuaFormField() {
    return RoundedInputField(
      label: '普通话水平',
      text: putonghua_level != null ? putonghua_level.toString() : '',
      hintText: "请输入被试者的普通话水平",
      onChanged: (value) {
        putonghua_level = value;
      },
      ontap: () async {
        var result = await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                title: const Text('请选择普通话水平'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: const Text('高'),
                    onPressed: () {
                      Navigator.of(context).pop('高');
                    },
                    isDestructiveAction: false,
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('中'),
                    onPressed: () {
                      Navigator.of(context).pop('中');
                    },
                    isDestructiveAction: false,
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('低'),
                    onPressed: () {
                      Navigator.of(context).pop('低');
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
        // 修改界面内容
        setState(() {
          if (result != 'cancel') {
            putonghua_level = result;
          }
        });
      },
    );
  }

  TextFormField buildWearlogFormField() {
    return TextFormField(
      controller: wearLogController,
      //onSaved: (newValue) => wearlog = newValue,
      onChanged: (value) {
        wearlog = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kNameNullError);
          return "";
        }
      },
      decoration: const InputDecoration(
        labelText: "助听器佩戴史",
        hintText: "输入被试者的助听器佩戴史",
        floatingLabelBehavior: FloatingLabelBehavior.always,
        //suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }
}
