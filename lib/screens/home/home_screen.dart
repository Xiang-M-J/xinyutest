import 'dart:async';
import 'package:xinyutest/Global/local_service.dart';
import 'package:xinyutest/screens/sgin_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:xinyutest/components/default_border_button.dart';
import 'package:xinyutest/config/version.dart';
import 'package:xinyutest/screens/subject_management/subjectmana_screen.dart';
import '../../Global/GlobalVarible.dart';
import '../../Global/calibration_values.dart';
import '../../Global/dio_client.dart';
import '../../Global/get_device_info.dart';
import '../../components/AppTool.dart';
import '../../config/constants.dart';
import '../audiometry/get_subject.dart';
import '../calibration/water_ripples.dart';
import 'package:xinyutest/Global/subject_list.dart';
import 'package:xinyutest/config/size_config.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  /// 当日是否进行过声场校准
  bool isCalibration = false;
  bool isChecked = false;

  var dio = DioClient.dio;

  late final Timer periodicTimer;

  /// 获取设备信息
  void getDeviceInfo(bool isJump) async {
    var platformUid = await FlutterDeviceInfo.platformUid; //User's ID
    var platformName = await FlutterDeviceInfo.platformName; //Device name
    var platformModel = await FlutterDeviceInfo.platformModel; //Model name
    String deviceInfo =
        '(platformUid:$platformUid)(platformName:$platformName)(platformModel:$platformModel)';
    print(deviceInfo);
    CalibrationValue.testingDevice = deviceInfo;
    // 模拟器输出结果：(platformUid:4545a8d3254e5c08)(platformName:thyme)(platformModel:Xiaomi M2102J2SC)

    // 查询当日是否进行过声场校准
    checkIsCalibration(isJump);
  }

  /// 检查当日是否进行过声场校准
  void checkIsCalibration(bool isJump) async {
    try {
      print("checkIsCalibration:" + CalibrationValue.testedDevice);
      // String str = CalibrationValue.testingDevice +
      //     ',' +
      //     CalibrationValue.testedDevice +
      //     ',' +
      //     DateTime.now().toString();
      // print(str);
      // print('success');
      // var response = await dio
      //     .get(DioClient.baseurl + '/api/devicecalibration/' + str); //从API中获取信息
      var response = await getCalibrationResponse(CalibrationValue.testingDevice, CalibrationValue.testingDevice);
      print(response);
      var status = response.status;
      isChecked = true;
      if (status == 0) {
        setState(() {
          CalibrationValue.micCalibrationDB = response.micCalibrationDB;
          CalibrationValue.calibrationDB = response.calibrationDB;
          CalibrationValue.calibrationVolume = response.playVolume;
          isCalibration = true;
          // print(responseData);

          //应填入isCalibration && isJump,原为isJump
          if (isJump) {
            /// 路由跳转
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => GetSubjectPage()));
          }
        });
      } else {
        setState(() {
          isCalibration = false;
          if (isJump) {
            /// 警告，提示对话框
            AppTool().showDefineAlert(context, "提示", '请先进行声场校准！');
          }
        });
      }
    } catch (e) {
      setState(() {
        isCalibration = false;
        if (isJump) {
          /// 警告，提示对话框
          AppTool().showDefineAlert(context, "错误", '请检查网络连接！');
        }
      });
      return;
    }
  } //try

//检测蓝牙是否打开，并请求打开蓝牙，拒绝打开蓝牙将弹窗
  void openBluetooth() async {
    if (GlobalBlueToothArgs.bluetoothState != BluetoothState.STATE_ON) {
      await FlutterBluetoothSerial.instance.requestEnable();
      if (GlobalBlueToothArgs.bluetoothState == BluetoothState.STATE_ON) {
        GlobalBlueToothArgs.bluetoothState = BluetoothState.STATE_ON;
        setState(() {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const WaterRipples()));
        });
      } else {
        setState(() {
          AppTool().showDefineAlert(context, '提示', '打开蓝牙才能进行声场校准');
        });
      }
    } else {
      setState(() {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WaterRipples()));
      });
    }
  }

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

//初始化
  @override
  void initState() {
    super.initState();
    // 获取设备信息以及是否进行过声场校准
    getDeviceInfo(false);
    //获取被试者名单
    _getSubjects();

    //==============================================================================
    //循环执行定时器，循环周期timeout=1s
    periodicTimer = Timer.periodic(GlobalBlueToothArgs.timeout, (timer) {
      GlobalBlueToothArgs.devices2.clear();
      FlutterBluetoothSerial.instance
          .getBondedDevices()
          .then((List<BluetoothDevice> bondedDevices) {
        GlobalBlueToothArgs.devices2 = bondedDevices
            .map(
              (device) => DeviceWithAvailability(
                device,
                DeviceAvailability.yes,
              ),
            )
            .toList();

        bool flag = false;

        if (GlobalBlueToothArgs.devices2.isNotEmpty) {
          for (var d in GlobalBlueToothArgs.devices2) {
            if (d.device.isConnected) {
              flag = true;
              // print(d.device.address);
              GlobalBlueToothArgs.curAddress = d.device.address;
              GlobalBlueToothArgs.curDevice = d.device;
              GlobalBlueToothArgs.isBonded = d.device.isBonded;
              CalibrationValue.testedDevice = d.device.name!;
              GlobalBlueToothArgs.tip =
                  '当前状态：已连接' + CalibrationValue.testedDevice;
            }
          }
        }

        // 可以检测使用中的设备突然断电
        if (GlobalBlueToothArgs.isBonded && !flag) {
          GlobalBlueToothArgs().reset();
          setState(() {});
        }
      });
    });
//获取状态
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        GlobalBlueToothArgs.bluetoothState = state;
      });
    });
//获取变更状态
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        GlobalBlueToothArgs.bluetoothState = state;
      });
    });
    //==============================================================================
  }

  @override
  void dispose() {
    super.dispose();

    periodicTimer.cancel(); //销毁定时器
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            left: size.width * 0.04,
            top: size.height * 0.05,
            right: size.width * 0.03),
        child: ListView(
          children: <Widget>[
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween, //首尾与其他组件无空隙均匀分布
              children: <Widget>[
                SvgPicture.asset("assets/icons/menu.svg"),
                SvgPicture.asset("assets/icons/User.svg"),
              ],
            ),
            SizedBox(
              height: size.height * 0.05,
            ),
            const Text("中文语句识别率测试", style: kHeadingextStyle),
            SizedBox(
              height: size.height * 0.05,
            ),
            // 被试信息管理
            InkWell(
              child: Container(
                padding: EdgeInsets.only(left: size.width * 0.05),
                height: size.height * 0.2,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  //设置四周圆角 角度
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 30,
                      color: kShadowColor,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      '被试者信息管理',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Image.asset('assets/images/xinxiguanli.png'),
                  ],
                ),
              ),
              onTap: () {
                Navigator.pushNamed(
                    context, SubjectManagementScreen.routeName); //跳转
              },
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            // 声场校准
            InkWell(
              child: Container(
                padding: EdgeInsets.only(left: size.width * 0.05),
                height: size.height * 0.2,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  //设置四周圆角 角度
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 30,
                      color: kShadowColor,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      '声场校准',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Image.asset('assets/images/jiaozhun.png'),
                  ],
                ),
              ),
              //跳转
              onTap: () async {
                // print(GlobalBlueToothArgs().isConnected ? "未连接设备" : ("已连接设备：" + GlobalBlueToothArgs.curAddress));
                //==============================================================================
                // 若未开启蓝牙则打开蓝牙
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const WaterRipples()));
                // openBluetooth();
                //==============================================================================
              },
            ),
            SizedBox(
              height: size.height * 0.03,
            ),
            // 言语测听
            InkWell(
              child: Container(
                padding: EdgeInsets.only(left: size.width * 0.05),
                height: size.height * 0.2,
                width: size.width * 0.9,
                decoration: BoxDecoration(
                  color: Colors.white,
                  //设置四周圆角 角度
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 30,
                      color: kShadowColor,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      '言语测听',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Image.asset('assets/images/yanyuceting.png'),
                  ],
                ),
              ),
              //跳转
              onTap: () async {
                // /// 测试用
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => GetSubjectPage()));

                // getDeviceInfo(true);
              },
            ),

            DefaultBorderButton(
                text: '退出登录',
                press: () {
                  Navigator.pushNamed(context, SignInScreen.routeName);
                }),
            SizedBox(
              height: size.height * 0.03,
            ),
            Text(
              "版本号：" + Version.version,
            ),
          ],
        ),
      ),
    );
  }
}
