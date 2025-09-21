import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:xinyutest/Global/database_utils.dart';
import 'package:xinyutest/Global/dio_client.dart';
import 'package:xinyutest/Global/local_service.dart';
import 'package:xinyutest/Global/user_role.dart';
import 'package:xinyutest/dal/user/user_manager.dart';

import '../../../components/AppTool.dart';
import '../../../components/custom_surfix_icon.dart';
import '../../../components/default_button.dart';
import '../../../components/form_erroe.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';
import '../../../dal/user/SharedPreferenceUtil.dart';
import '../../../dal/user/userdata.dart';
import '../../../helper/keyboard.dart';
import '../../forgot_password/forgot_password.dart';
import '../../home/home_screen.dart';
import '../../login_success/login_success_screen.dart';

class SignForm extends StatefulWidget {
  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController(); //手机号码控制
  TextEditingController passwordController = TextEditingController(); //密码控制
  String? phone; // 手机号码
  String? password; // 密码
  bool remember = false; // 是否记住账号密码
  var dio = DioClient.dio;
  final List<String?> errors = [];
  final List<User> _users = List.empty(growable: true); //历史账号

  @override
  void initState() {
    super.initState();
    _gainUsers();
  }

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
      //key的使用可以在动态Widget树变化时其相应的Element Tree也跟随相应的变化，以防Widget tree变换但Element tree不变
      //https://blog.51cto.com/jdsjlzx/5671340或https://www.jianshu.com/p/6e704112dc67查看key的理解
      key: _formKey,
      child: Column(
        children: [
          buildPhoneFormField(), //账户
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(), //密码
          SizedBox(height: getProportionateScreenHeight(30)),
          Row(
            children: [
              Checkbox(
                value: remember,
                activeColor: kPrimaryColor, //
                onChanged: (value) {
                  setState(() {
                    remember = value!;
                  });
                },
              ),
              const Text("记住账号密码"),
              const Spacer(),
              // GestureDetector(
              //   onTap: () => Navigator.pushNamed(
              //       context, ForgotPasswordScreen.routeName),
              //   child: const Text(
              //     "忘记密码？",
              //     style: TextStyle(decoration: TextDecoration.underline),
              //   ),
              // )
            ],
          ),
          FormError(errors: errors),
          SizedBox(height: getProportionateScreenHeight(20)),
          DefaultButton(
            text: "登录",
            press: //登录判断操作！
                () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                try {
                  var requestData = {
                    "phoneNumber": phone,
                    "password": password,
                  };
                  // var response = await dio.post(
                  //     DioClient.baseurl + '/api/interviewer/login',
                  //     // DioClient.baseurl + "/api/Interviewers/login",
                  //     data: requestData);


                  var response = await postLocalLogin(requestData);
                  var role = response.role;
                  var status = response.status;
                  if (status == 0) {
                    UserRole.role = role == "Admin" ? "数据主管" : "数据收集";
                    User user = User(phone!, password!, remember);
                    if (remember) {
                      /// 保存账号密码到本地，用于下次直接登录
                      SharedPreferenceUtil.saveUser(user);
                    }
                    await UserManager().login(user);
                    await DatabaseHelper.instance.init(user.userphone);
                    Navigator.pushNamed(context, HomeScreen.routeName);
                  } else {
                    var error = response.error;
                    setState(() {
                      /// 警告，提示对话框
                      AppTool().showDefineAlert(context, "警告", error);
                    });
                  }
                } catch (e) {
                  setState(() {
                    /// 警告，提示对话框
                    // AppTool().showDefineAlert(context, "错误", '请输入所有项或检查网络连接！');
                    AppTool().showDefineAlert(context, "错误", e.toString());
                  });
                  return;
                }
              }

              // 仅用作测试
              // KeyboardUtil.hideKeyboard(context);
              // Navigator.pushNamed(context, HomeScreen.routeName);
              // //
              // if (_formKey.currentState!.validate()) {
              //   _formKey.currentState!.save();
              //   // if all are valid then go to success screen
              //   KeyboardUtil.hideKeyboard(context);
              //   Navigator.pushNamed(context, HomeScreen.routeName);
              // }
            },
          ),
        ],
      ),
    );
  }

  TextFormField buildPasswordFormField() {
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      onSaved: (newValue) => password = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPassNullError);
        }
        if (value.length >= 8) {
          removeError(error: kShortPassError);
        }
        return null;
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
        hintText: "输入你的密码",
        // If  you are using latest version of flutter then lable text and hint text shown like this
        // if you r using flutter less then 1.20.* then maybe this is not working properly
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: CustomSurffixIcon(svgIcon: "assets/icons/Lock.svg"),
      ),
    );
  }

  //账号输入栏
  TextFormField buildPhoneFormField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.number,
      onSaved: (newValue) => phone = newValue,
      onChanged: (value) {
        if (value.isNotEmpty) {
          removeError(error: kPhoneNumberNullError);
        }
        if (phoneValidatorRegExp.hasMatch(value)) {
          removeError(error: kInvalidPhoneError);
        }
        return null;
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

  ///获取历史用户
  void _gainUsers() async {
    _users.clear();
    try {
      _users.addAll(await SharedPreferenceUtil.getUsers());
      //默认加载第一个账号
      if (_users.isNotEmpty) {
        setState(() {
          remember = _users[0].remeber;
          if (remember) {
            phone = _users[0].userphone;
            password = _users[0].password;
            phoneController.text = phone!;
            passwordController.text = password!;
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }
}
