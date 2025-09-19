import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:xinyutest/screens/splash/splash_screen.dart';
import 'package:flutter/services.dart';
import 'Global/GlobalVarible.dart';
import 'Global/calibration_values.dart';
import 'config/routes.dart';
import 'config/theme.dart';

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp, // 竖屏 Portrait 模式
      DeviceOrientation.portraitDown,
      // DeviceOrientation.landscapeLeft, // 横屏 Landscape 模式
      // DeviceOrientation.landscapeRight,
    ],
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> _getPermission2() async {
    Map<Permission, PermissionStatus> statuses;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt! >= 31) {
        //似乎缺少网络请求
        statuses = await [
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.location
        ].request();
        if (statuses[Permission.bluetoothConnect] != PermissionStatus.granted) {
          print("bluetoothConnect 未授权");
        } else {
          print("bluetoothConnect 已授权");
        }
        if (statuses[Permission.bluetoothScan] != PermissionStatus.granted) {
          print("bluetoothScan 未授权");
        } else {
          print("bluetoothScan 已授权");
        }
        if (statuses[Permission.location] != PermissionStatus.granted) {
          print("location 未授权");
        } else {
          print("location 已授权");
        }
      } else {
        statuses = await [Permission.bluetooth, Permission.location].request();
        if (statuses[Permission.bluetooth] != PermissionStatus.granted) {
          print("bluetooth 未授权");
        } else {
          print("bluetooth 已授权");
        }
        if (statuses[Permission.location] != PermissionStatus.granted) {
          print("location 未授权");
        } else {
          print("location 已授权");
        }
      }
    } else {
      print('ios not yet supported');
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    _getPermission2();

    GlobalBlueToothArgs().detectDevice();
    print("main：" + CalibrationValue.testedDevice);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: '心语',
      // 用于日期组件汉化
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh'),
        Locale('en'),
      ],
      // 设置文字大小不随系统设置改变
      builder: (context, widget) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: widget as Widget,
        );
      },
      theme: theme(),
      initialRoute: SplashScreen.routeName,
      routes: routes,
    );
  }
}
