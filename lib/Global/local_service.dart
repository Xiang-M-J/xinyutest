import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xinyutest/Global/database_utils.dart';
import 'package:xinyutest/Global/speech_resources.dart';

import '../../../dal/user/SharedPreferenceUtil.dart';
import 'package:xinyutest/dal/user/userdata.dart';

// Response()

// class DisplaySubject

class ErrorResponse extends Response {
  ErrorResponse(String error)
      : super(
            requestOptions: RequestOptions(path: ""),
            data: {"status": 1, "error": error});
}

class SuccessResponse extends Response {
  SuccessResponse(var data)
      : super(
            requestOptions: RequestOptions(path: ""),
            data: {"status": 0, "data": data});
}

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

  CalibrationResponse(
      this.status, this.micCalibrationDB, this.calibrationDB, this.playVolume);
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

  Map data = {"status": 0, "id": 0, "error": ""};

  Response response = Response(
    requestOptions: RequestOptions(path: ''),
    data: data,
    statusCode: 200,
  );

  return response;
}

Future<CalibrationResponse> getCalibrationResponse(
    String testingDevice, String testedDevice) async {
  String filename = "${testingDevice}_$testedDevice.txt";
  filename = filename.replaceAll(":", " ");
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

  if (isChecked) {
    String result = await readTextFile(filePath);
    List<String> lines = result.split('\n');
    int micCalibrationDB = int.parse(lines[0]);
    int calibrationDB = int.parse(lines[1]);
    double playVolume = double.parse(lines[2]);
    CalibrationResponse response =
        CalibrationResponse(0, micCalibrationDB, calibrationDB, playVolume);
    return response;
  }

  return CalibrationResponse(1, 0, 0, 0);
}

Future<Response> postCalibrationResponse(Map formData) async {
  String testedDevice = formData['testedDevice'];
  String testingDevice = formData['testingDevice'];
  String filename = "${testingDevice}_$testedDevice.txt";
  filename = filename.replaceAll(":", " ");
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/$filename';

  String content =
      "${formData['micCalibrationDB']}\n${formData['calibrationDB']}\n${formData['playVolume']}";

  try {
    bool is_success = await saveTextFile(filePath, content);
    if (!is_success) {
      return ErrorResponse("出现错误");
    }
    bool is_exist = await File(filePath).exists();
    print("file exists: $is_exist");
    return SuccessResponse("");
  } catch (e) {
    return ErrorResponse(e.toString());
  }
}

Future<bool> saveTextFile(String path, String content) async {
  try {
    // final directory = await getApplicationDocumentsDirectory();
    // final path = '${directory.path}/$filename';

    final file = File(path);
    await file.writeAsString(content);
    return true;
  } catch (e) {
    print(e.toString());
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

List convertSubjects(List<Subject> subjects) {
  List results = List.empty(growable: true);

  for (var i = 0; i < subjects.length; i++) {
    Map dummy = subjects[i].toMap();
    dummy["check"] = false;
    results.add(dummy);
  }
  return results;
}

Future<Response> getSubjectResponse(String? userId) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }
  try {
    List<Subject> subjects = await DatabaseHelper.instance.queryAllSubjects();
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {"status": 0, "data": convertSubjects(subjects)},
    );
  } catch (e) {
    return ErrorResponse("数据库查询错误：${e.toString()}");
  }
}

Future<Response> deleteSubjectResponse(String? userId, int subjectId) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }
  try {
    int id = await DatabaseHelper.instance.deleteSubject(subjectId);
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {"status": 0},
    );
  } catch (e) {
    return ErrorResponse("删除错误");
  }
}

Future<Response> getSubjectByNameResponse(
    String? userId, String searchName) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }
  try {
    // int id = await DatabaseHelper.instance(subjectId);
    List<Subject> results =
        await DatabaseHelper.instance.querySubjectsByName(searchName);
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {"status": 0, "data": convertSubjects(results)},
    );
  } catch (e) {
    return ErrorResponse("查询错误");
  }
}

Future<Response> getSubjectByIdResponse(String? userId, int id) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }
  try {
    // int id = await DatabaseHelper.instance(subjectId);
    List<Subject> results = await DatabaseHelper.instance.querySubjectsById(id);
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {"status": 0, "data": results[0].toMap()},
    );
  } catch (e) {
    return ErrorResponse("数据库操作错误");
  }
}

Future<Response> postSubjectResponse(String? userId, Map requestData) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }

  try {
    int result = await DatabaseHelper.instance.insertSubject(Subject(
        name: requestData['name'],
        gender: requestData['gender'],
        birthDate: requestData['birthDate'],
        phoneNumber: requestData['phoneNumber'],
        putonghuaLevel: requestData['putonghuaLevel'],
        wearLog: requestData['wearLog']));
    if (result <= 0) {
      return ErrorResponse("数据库操作错误");
    } else {
      return Response(
          requestOptions: RequestOptions(path: ""),
          data: {"status": 0, "data": ""});
    }
  } catch (e) {
    return ErrorResponse("数据库操作错误");
  }
}

// 修改
Future<Response> putSubjectResponse(
    String? userId, int subjectId, Map requestData) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }

  try {
    int result = await DatabaseHelper.instance.updateSubject(Subject(
        id: subjectId,
        name: requestData['name'],
        gender: requestData['gender'],
        birthDate: requestData['birthDate'],
        phoneNumber: requestData['phoneNumber'],
        putonghuaLevel: requestData['putonghuaLevel'],
        wearLog: requestData['wearLog']));
    if (result <= 0) {
      return ErrorResponse("数据库操作错误");
    } else {
      return Response(
          requestOptions: RequestOptions(path: ""),
          data: {"status": 0, "data": ""});
    }
  } catch (e) {
    return ErrorResponse("数据库操作错误");
  }
}

// 获取Subject的record
Future<Response> getSubjectTestRecordByIdResponse(
    String? userId, int id) async {
  List convertSubjects(List<TestRecord> records) {
    List results = List.empty(growable: true);
    for (var i = 0; i < records.length; i++) {
      results.add(records[i].toMap());
    }
    return results;
  }

  if (userId == null) {
    return ErrorResponse("用户未登录");
  }
  try {
    List<TestRecord> results =
        await DatabaseHelper.instance.queryTestRecordsBySubject(id);
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {"status": 0, "data": convertSubjects(results)},
    );
  } catch (e) {
    return ErrorResponse("数据库操作错误");
  }
}

// 获取Record
Future<Response> getTestRecordByIdResponse(String? userId, int id) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }
  try {
    List<TestRecord> results =
        await DatabaseHelper.instance.queryTestRecordsById(id);
    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {"status": 0, "data": results[0].toMap()},
    );
  } catch (e) {
    return ErrorResponse("数据库操作错误");
  }
}

List<Map> convertSpeechResources(List<SpeechResource> resources) {
  List<Map> results = List.empty(growable: true);
  for (var i = 0; i < resources.length; i++) {
    Map resource = resources[i].toMap();
    List<Map> keywords = List.empty(growable: true);
    for (var i = 0; i < resource["keywords"].length; i++) {
      keywords.add({"keyword": resource["keywords"][i], "check": false});
    }
    resource['keywords'] = keywords;
    results.add(resource);
  }
  return results;
}

int? findnonSemIndex(String keyword) {
  int? result;
  for (var i = 0; i < keyword.length; i++) {
    if (keyword[i] == "#") {
      result = i;
      break;
    }
  }
  return result;
}

// 获取SpeechTable
Future<Response> getSpeechTableByIdResponse(String? userId, int id) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }
  try {
    List<SpeechResource> results =
        await DatabaseHelper.instance.querySpeechResourcesByTableId(id);
    if (results.isEmpty) {
      return ErrorResponse("无语音表");
    }
    List<Map> resources = List.empty(growable: true);

    for (var i = 0; i < results.length; i++) {
      Map resource = results[i].toMap();
      List<String> tmpKeywords = resource['keywords'].split("_");
      List<Map> keywords = [];

      for (var i = 0; i < tmpKeywords.length; i++) {
        int? nonSemIndex = findnonSemIndex(tmpKeywords[i]);
        keywords.add({
          "keyword": tmpKeywords[i].replaceAll("#", ""),
          'check': false,
          'nonSemIndex': nonSemIndex
        });
      }
      resource['keywords'] = keywords;
      resources.add(resource);
    }

    // if (results[0].resources != null) {
    //   List ids = results[0].resources!.split(',');
    //   for (var element in ids) {
    //     resources.add(int.parse(element));
    //   }
    // }
    // int? resourceNumber = results[0].resourceNumber;
    // resourceNumber ??= resources.length;
    int resourceNumber = resources.length;

    return Response(
      requestOptions: RequestOptions(path: ''),
      data: {
        "status": 0,
        "data": {"resources": resources, "resourceNumber": resourceNumber}
      },
    );

    // Map data = Map.from(speechTables[id.toString()]);
    // data["resources"] = convertSpeechResources(data["resources"]);
    // return SuccessResponse(data);
  } catch (e) {
    return ErrorResponse("数据库操作错误");
  }
}

String convertResult(List results) {
  String strRes = "";

  for (var i = 0; i < results.length; i++) {
    for (var j = 0; j < results[i].length; j++) {
      strRes = "$strRes${results[i][j]['keyword']}: ${results[i][j]['check']}";
    }
    strRes = "$strRes\n";
  }
  return strRes;
}

// 上传TestRecord
Future<Response> postTestRecordResponse(String? userId, Map requestData) async {
  if (userId == null) {
    return ErrorResponse("用户未登录");
  }

  try {
    int result = await DatabaseHelper.instance.insertTestRecord(TestRecord(
      subjectId: requestData['subjectId'] as int,
      interviewerId: 1,
      mode: requestData['mode'] as String,
      createTime: "",
      hearingStatus: requestData['hearingStatus'] as String,
      corpusType: requestData['corpusType'] as String,
      environment: requestData['environment'] as String,
      tableId: requestData['tableId'] as int,
      playVolume: requestData['playVolume'] as int,
      result: convertResult(requestData['result'] as List),
      accuracy: requestData['accuracy'] as String,
    ));
    if (result <= 0) {
      return ErrorResponse("数据库操作错误");
    } else {
      return Response(
          requestOptions: RequestOptions(path: ""),
          data: {"status": 0, "data": ""});
    }
  } catch (e) {
    return ErrorResponse("数据库操作错误");
  }
}

// 上传TestRecord
Future<Response> getSpeechTableByModeResponse(String mode) async {
  try {
    // Map data = Map.from(speechTables['14']);
    // if (mode == "Normal"){
    //   data = Map.from(speechTables['13']);
    // }
    // data["resources"] = convertSpeechResources(data["resources"]);

    if (mode == "Normal") {
      return SuccessResponse([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    } else {
      return SuccessResponse([13, 14]);
    }
  } catch (e) {
    return ErrorResponse("错误");
  }
}
