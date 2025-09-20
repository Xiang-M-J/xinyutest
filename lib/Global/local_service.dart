import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../dal/user/SharedPreferenceUtil.dart';
import 'package:xinyutest/dal/user/userdata.dart';

// Response()

class LoginResponse {
  int status;
  String error;
  String role;

  LoginResponse(this.status, this.error, this.role) {
    status = status;
    error = error;
    role = role;
  }
}

class RegisterResponse {
  int status;
  String error;

  RegisterResponse(this.status, this.error) {
    status = status;
    error = error;
  }
}

class CalibrationResponse {
  int status;
  int micCalibrationDB;
  int calibrationDB;
  double playVolume;

  CalibrationResponse(this.status, this.micCalibrationDB, this.calibrationDB, this.playVolume);
}

Future<LoginResponse> postLocalLogin(Map requestData) async {
  String phoneNumber = requestData["phoneNumber"];
  String password = requestData["password"];

  LoginResponse response = LoginResponse(1, "", "");

  List<User> users = await SharedPreferenceUtil.getUsers();
  for (User user in users) {
    if (user.userphone == phoneNumber && user.password == password) {
      response.status = 0;
      response.role = "Admin";
      return response;
    }
  }
  response.status = 1;
  response.error = "账号或密码错误";
  return response;
}


Future<Response> postLocalRegister(Map requestData) async {
  String phoneNumber = requestData["phoneNumber"];
  String password = requestData["password"];
  // String name = requestData['realName']
  // String role = 
  // var requestData = {
  //     "phoneNumber": phone,
  //     "realName": name,
  //     "password": password,
  //     "role": permission == '数据主管' ? 'Admin' : 'Normal',
  //     "organizationUniqueCode": organization_id
  //   };

  User user = User(phoneNumber, password, false);

  SharedPreferenceUtil.saveUser(user);

  // RegisterResponse response = RegisterResponse(0, "");

  Map data = {
    "status": 0,
    "id": 0,
    "error": ""
  };
  

  Response response = Response(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: 200,
    );

  return response;
}



Future<CalibrationResponse> getCalibrationResponse(String testingDevice, String testedDevice) async {
  String filename = "${testingDevice}_$testedDevice.txt";
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$filename';

  final file = File(filePath);

  bool isChecked = false;

  if (await file.exists()) {
    // 获取文件状态
    FileStat stat = await file.stat();

    DateTime modified = stat.modified;
    DateTime now = DateTime.now();

    bool isToday = modified.year == now.year &&
        modified.month == now.month &&
        modified.day == now.day;

    if (isToday) {
      isChecked = true;
    } else {
      print("文件存在，但不是今天创建/修改的: $filePath");
    }
  } else {
    print("文件不存在: $filePath");
  }

  if(isChecked){
    String result = await readTextFile(filePath);
    List<String> lines = result.split('\n');
    int micCalibrationDB = int.parse(lines[0]);
    int calibrationDB = int.parse(lines[1]);
    double playVolume = double.parse(lines[2]);
    CalibrationResponse response = CalibrationResponse(0, micCalibrationDB, calibrationDB, playVolume);
    return response;
  }

  return CalibrationResponse(1, 0, 0, 0);

}

Future<bool> saveTextFile(String filename, String content) async {
  try {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';

    final file = File(path);
    await file.writeAsString(content);
    return true;
  } catch (e) {
    return false;
  }
}

Future<String> readTextFile(String filename) async {
  try {
    // 获取应用文档目录
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$filename';

    // 读取文件
    final file = File(path);
    String contents = await file.readAsString();

    return contents;
  } catch (e) {
    print("读取文件失败: $e");
    return "";
  }
}

