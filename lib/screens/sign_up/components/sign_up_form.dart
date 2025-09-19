import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Global/dio_client.dart';
import '../../../components/AppTool.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/default_button.dart';
import '../../../components/form_erroe.dart';
import '../../../components/rounded_input_field.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';
import '../../login_success/login_success_screen.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? phone;
  String? password;
  String? conform_password;
  String? organization_id;
  String? permission;
  bool remember = false;
  var dio = DioClient.dio;
  final List<String?> errors = [];

  void addError({String? error}) {
    if (!errors.contains(error))
      setState(() {
        errors.add(error);
      });
  }

  void removeError({String? error}) {
    if (errors.contains(error))
      setState(() {
        errors.remove(error);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          buildNameFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPhoneFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildConformPassFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildOrgIdFormField(),
          SizedBox(height: getProportionateScreenHeight(20)),
          buildPermissionFormField(),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButton(
            text: "注册",
            press: () async {
              
              // if (_formKey.currentState!.validate()) {
              //   _formKey.currentState!.save();
              //   try {
              //     var requestData = {
              //       "phoneNumber": phone,
              //       "realName": name,
              //       "password": password,
              //       "role": permission == '数据主管' ? 'Admin' : 'Normal',
              //       "organizationUniqueCode": organization_id
              //     };
              //     var response = await dio.post(
              //         DioClient.baseurl + '/api/interviewer/register',
              //         data: requestData);
              //     var res = response.data;
              //     var status = res["status"] as int;
              //     status = 0;
              //     if (status == 0) {
              //       var responseData = res["data"];

              //       var id = responseData["id"];

              //       // if all are valid then go to success screen
              //       Navigator.of(context).push(MaterialPageRoute(
              //           builder: (context) =>
              //               LoginSuccessScreen(textValue: false)));
              //     } else {
              //       var error = res["error"];
              //       setState(() {
              //         /// 警告，提示对话框
              //         AppTool().showDefineAlert(context, "警告", error);
              //       });
              //     }
              //   } catch (e) {
              //     setState(() {
              //       /// 警告，提示对话框
              //       AppTool().showDefineAlert(context, "警告", e.toString());
              //     });
              //     return;
              //   }
              // }
              //测试用
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => LoginSuccessScreen(textValue: false)));
            },
          ),
          SizedBox(height: getProportionateScreenHeight(20)),
        ],
      ),
    );
  }

  TextFormField buildConformPassFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => conform_password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        }
        if (value.isNotEmpty && password == conform_password) {
          removeError(error: kMatchPassError);
        }
        conform_password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if ((password != value)) {
          addError(error: kMatchPassError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "确认密码",
        hintText: "再次输入密码",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        }
        if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        password = value;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kPassNullError);
          return "";
        } else if (value.length < 8) {
          addError(error: kShortPassError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "密码",
        hintText: "输入你的密码（至少8位）",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  TextFormField buildPhoneFormField() {
    return TextFormField(
      keyboardType: TextInputType.phone,
      onSaved: (newValue) => phone = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
        }
        if (phoneValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidPhoneError);
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
        hintText: "输入你的手机号码",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Phone.svg"),
      ),
    );
  }

  TextFormField buildNameFormField() {
    return TextFormField(
      onSaved: (newValue) => name = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kNameNullError);
        }
        if (nameValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidNameError);
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
        hintText: "输入你的姓名",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/User.svg"),
      ),
    );
  }

  TextFormField buildOrgIdFormField() {
    return TextFormField(
      onSaved: (newValue) => organization_id = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kOrgIdNullError);
        }
        return null;
      },
      validator: (value) {
        if (value!.isEmpty) {
          addError(error: kOrgIdNullError);
          return "";
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: "注册码",
        hintText: "输入所在组织注册码",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/ID.svg"),
      ),
    );
  }

  RoundedInputField buildPermissionFormField() {
    return RoundedInputField(
      label: '权限',
      text: permission != null ? permission.toString() : '',
      hintText: "请选择你的权限",
      onChanged: (value) {
        permission = value;
      },
      ontap: () async {
        var result = await showCupertinoModalPopup(
            context: context,
            builder: (context) {
              return CupertinoActionSheet(
                title: const Text('请选择权限'),
                actions: <Widget>[
                  CupertinoActionSheetAction(
                    child: const Text('数据收集'),
                    onPressed: () {
                      Navigator.of(context).pop('数据收集');
                    },
                    isDefaultAction: true,
                  ),
                  CupertinoActionSheetAction(
                    child: const Text('数据主管'),
                    onPressed: () {
                      Navigator.of(context).pop('数据主管');
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
            permission = result;
          }
        });
      },
    );
  }
}
