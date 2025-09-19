import 'package:flutter/material.dart';
import 'package:xinyutest/config/size_config.dart';

const kPrimaryColor = Color.fromARGB(255, 1, 123, 255);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color.fromARGB(255, 252, 109, 26), Color.fromARGB(255, 247, 97, 52)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Color(0xFF757575);
const kAnimationDuration = Duration(milliseconds: 200);
final kShadowColor = const Color(0xFFB7B7B7).withOpacity(.16);

final headingStyle = TextStyle(
  fontSize: getProportionateScreenWidth(28),
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// Form Error
final RegExp phoneValidatorRegExp = RegExp(r'1[3456789]\d{9}$');
const String kInvalidPhoneError = "请输入有效的手机号码";
const String kPassNullError = "请输入你的密码（至少8位）";
const String kShortPassError = "密码太短了（至少8位）";
const String kMatchPassError = "两次输入的密码不一致";
final RegExp nameValidatorRegExp =
    RegExp(r'([\u4e00-\u9fa5]{1,20}|[a-zA-Z\.\s]{1,20})$');
const String kInvalidNameError = "请输入有效的姓名";
const String kNameNullError = "请输入你的名字";
const String kPhoneNumberNullError = "请输入你的手机号码";
const String kAddressNullError = "请输入你的地址";
const String kOrgIdNullError = "请输入所在组织ID";
const String kPermissionNullError = "请选择权限";

final otpInputDecoration = InputDecoration(
  contentPadding:
      EdgeInsets.symmetric(vertical: getProportionateScreenWidth(15)),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(getProportionateScreenWidth(15)),
    borderSide: BorderSide(color: kTextColor),
  );
}

// Colors
const kTextColor1 = Color(0xFF0D1333);
const kBlueColor = Color(0xFF6E8AFA);
const kBestSellerColor = Color(0xFFFFD073);
const kGreenColor = Color(0xFF49CC96);

// My Text Styles
const kHeadingextStyle = TextStyle(
  fontSize: 20,
  color: kTextColor1,
  fontWeight: FontWeight.bold,
);
const kSubheadingextStyle = TextStyle(
  fontSize: 24,
  color: Color(0xFF61688B),
  height: 2,
);

const kTitleTextStyle = TextStyle(
  fontSize: 20,
  color: kTextColor1,
  fontWeight: FontWeight.bold,
);

const kSubtitleTextSyule = TextStyle(
  fontSize: 18,
  color: kTextColor1,
  // fontWeight: FontWeight.bold,
);

// Text Style
const kHeadingTextStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
);
