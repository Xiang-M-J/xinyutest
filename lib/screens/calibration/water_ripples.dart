import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:xinyutest/components/AppTool.dart';
import 'package:xinyutest/config/size_config.dart';
import '../../Global/BluetoothDeviceListEntry.dart';
import '../../Global/GlobalVarible.dart';
import '../../Global/calibration_values.dart';
import '../../components/default_button.dart';
import 'calibration_tip.dart';

/// 扫描蓝牙页
class WaterRipples extends StatefulWidget {
  const WaterRipples({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _WaterRipplesState();
}

class _WaterRipplesState extends State<WaterRipples>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  //动画控制器
  final List<AnimationController> _controllers = [];
  //动画控件集合
  final List<Widget> _children = [];
  //添加蓝牙检索动画计时器
  Timer? _searchBluetoothTimer;
  //利用StreamSubscription监听BlutoothDiscoveryResult并处理
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  late final Timer periodicTimer;

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        //查询results中是否已经包含r，若包含则输出该位置，不包含则添加r到results最后
        //indexWhere查询失败时会返回-1
        if (r.device.type != BluetoothDeviceType.le) {
          final existingIndex = results.indexWhere(
              (element) => element.device.address == r.device.address);
          if (existingIndex >= 0) {
            results[existingIndex] = r;
          } else {
            results.add(r);
          }
        }
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // if(filteredResults.isEmpty) print("filteredResults为空");

    return Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          title: const Text(
            '蓝牙连接',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 22.0,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(children: [
                Text(
                  GlobalBlueToothArgs.tip, //蓝牙连接状态
                  style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: SizeConfig.screenWidth * 0.01,
                ),
                SizedBox(
                  width: SizeConfig.screenWidth * 0.7,
                  height: SizeConfig.screenHeight * 0.306,
                  child: Stack(
                    alignment: Alignment.center,
                    children: _children,
                  ),
                ),
                SizedBox(
                  height: SizeConfig.screenHeight * 0.005,
                ),
                const Text(
                  "正在扫描...",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
                SizedBox(
                  height: SizeConfig.screenWidth * 0.01,
                ),
                const Text(
                  "长按下方设备名连接",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                ),
              ]),
            ),
            SizedBox(
              height: SizeConfig.screenHeight * 0.3,
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (BuildContext context, index) {
                  BluetoothDiscoveryResult result = results[index];
                  final device = result.device;
                  final address = device.address;
                  return BluetoothDeviceListEntry(
                    device: device,
                    rssi: result.rssi,
                    onLongPress: () async {
                      try {
                        bool bonded = false;
                        if (device.isBonded) {
                          print("water_ripples");
                          print('Unbonding from ${device.address}...');
                          var unBondresult = (await FlutterBluetoothSerial
                              .instance
                              .removeDeviceBondWithAddress(address))!;

                          if (unBondresult) {
                            print("解除绑定成功");
                            GlobalBlueToothArgs().reset();
                            AppTool().showDefineAlert(context, "提示", '成功解除绑定！');
                          } else {
                            print("解除绑定失败");
                          }
                        } else {
                          print("water_ripples");
                          print('Bonding with ${device.address}...');
                          bonded = (await FlutterBluetoothSerial.instance
                              .bondDeviceAtAddress(address))!;
                          if (bonded) {
                            GlobalBlueToothArgs.curDevice = device;
                            GlobalBlueToothArgs.curAddress = device.address;
                            GlobalBlueToothArgs.isBonded = bonded;
                          }
                          print(
                              'Bonding with ${GlobalBlueToothArgs.curAddress} has ${GlobalBlueToothArgs.isBonded ? 'succeed' : 'failed'}.');
                        }

                        if (mounted) {
                          setState(() {
                            results[results.indexOf(result)] =
                                BluetoothDiscoveryResult(
                                    device: BluetoothDevice(
                                      name: device.name ?? '',
                                      address: address,
                                      type: device.type,
                                      bondState: bonded
                                          ? BluetoothBondState.bonded
                                          : BluetoothBondState.none,
                                    ),
                                    rssi: result.rssi);
                          });
                        }
                      } catch (ex) {
                        print("错误信息：" + ex.toString());
                        // if(mounted) AppTool().showDefineAlert(context, "提示", '出错！');
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: SizeConfig.screenWidth * 0.8,
              child: DefaultButton(
                text: "下一页",
                press: () {
                  if (GlobalBlueToothArgs.isBonded) {
                    // 仅用作测试
                    setState(() {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CalibrationTipScreen()));
                    });
                  } else {
                    // _showUnBonded();
                    AppTool().showDefineAlert(context, "提示", '未绑定设备！');
                  }
                },
              ),
            ),
          ],
        ));
  }

  ///初始化蓝牙检索动画，依次添加5个缩放动画，形成水波纹动画效果
  void _startAnimation() {
    //动画启动前确保_children控件总数为0
    _children.clear();
    int count = 0;
    //添加第一个圆形缩放动画
    _addSearchAnimation(true);
    //以后每隔1秒，再次添加一个缩放动画，总共添加4个
    _searchBluetoothTimer =
        Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _addSearchAnimation(true);
      count++;
      if (count >= 4) {
        timer.cancel();
      }
    });
  }

  ///添加蓝牙检索动画控件
  ///init: 首次添加5个基本控件时，=true，
  void _addSearchAnimation(bool init) {
    var controller = _createController();
    _controllers.add(controller);
    //print("tag——children length : ${_children.length}");
    var animation = Tween(begin: 50.0, end: 290.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.linear));
    if (!init) {
      //5个基本动画控件初始化完成的情况下，每次添加新的动画控件时，移除第一个，确保动画控件始终保持5个
      _children.removeAt(0);
      //添加新的动画控件
      Future.delayed(const Duration(seconds: 1), () {
        if (!mounted) return;
        //动画页面没有执行退出情况下，继续添加动画
        _children.add(AnimatedBuilder(
            animation: controller,
            builder: (BuildContext context, Widget? child) {
              return Opacity(
                // opacity: (300.0 - animation.value) / 300.0,
                opacity: 1.0 - ((animation.value - 50.0) / 240.0),
                child: ClipOval(
                  child: Container(
                    width: animation.value,
                    height: animation.value,
                    color: Color.fromARGB(255, 6, 146, 240),
                  ),
                ),
              );
            }));
        try {
          //动画页退出时，捕获可能发生的异常
          controller.forward();
          setState(() {});
        } catch (e) {
          return;
        }
      });
    } else {
      _children.add(AnimatedBuilder(
          animation: controller,
          builder: (BuildContext context, Widget? child) {
            return Opacity(
              opacity: 1.0 - ((animation.value - 50.0) / 240.0),
              child: ClipOval(
                child: Container(
                  width: animation.value,
                  height: animation.value,
                  color: Color.fromARGB(255, 6, 146, 240),
                ),
              ),
            );
          }));
      controller.forward();
      setState(() {});
    }
  }

  ///创建蓝牙检索动画控制器
  AnimationController _createController() {
    var controller = AnimationController(
        duration: const Duration(milliseconds: 4000), vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
        if (_controllers.contains(controller)) {
          _controllers.remove(controller);
        }
        //每次动画控件结束时，添加新的控件，保持动画的持续性
        if (mounted) _addSearchAnimation(false);
      }
    });
    return controller;
  }

  ///监听应用状态，
  /// 生命周期变化时回调
  /// resumed:应用可见并可响应用户操作
  /// inactive:用户可见，但不可响应用户操作
  /// paused:已经暂停了，用户不可见、不可操作
  /// suspending：应用被挂起，此状态IOS永远不会回调
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      //应用退至后台，销毁蓝牙检索动画
      _disposeSearchAnimation();
    } else if (state == AppLifecycleState.resumed) {
      //应用回到前台，重新启动动画
      _startAnimation();
    }
  }

  ///销毁动画
  void _disposeSearchAnimation() {
    //释放动画所有controller
    for (var element in _controllers) {
      element.dispose();
    }
    _controllers.clear();
    _searchBluetoothTimer?.cancel();
    _children.clear();
  }

  @override
  void initState() {
    super.initState();
    isDiscovering = true;
    // GlobalBlueToothArgs.isDiscovering = isDiscovering;
    if (isDiscovering) {
      _startDiscovery();
    }

    // GlobalBlueToothArgs().detectDevice();

    _startAnimation();
    //添加应用生命周期监听
    WidgetsBinding.instance?.addObserver(this);

    //  ==========================================================================
    periodicTimer = Timer.periodic(GlobalBlueToothArgs.timeout, (timer) {
      GlobalBlueToothArgs.devices2.clear(); //监听绑定蓝牙设备状态
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
    //  ==========================================================================
  }

  @override
  void dispose() {
    //print("tag--=========================dispose===================");
    //销毁动画
    _disposeSearchAnimation();
    //销毁应用生命周期观察者
    WidgetsBinding.instance?.removeObserver(this);

    _streamSubscription?.cancel();
    periodicTimer.cancel();

    super.dispose();
  }
}
