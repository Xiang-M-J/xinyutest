import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import 'calibration_values.dart';

enum DeviceAvailability {
  no,
  maybe,
  yes,
}

class DeviceWithAvailability {
  BluetoothDevice device;
  DeviceAvailability availability;
  //接收信号强度
  int? rssi;

  DeviceWithAvailability(this.device, this.availability, [this.rssi]);
}

class GlobalBlueToothArgs {
  static BluetoothState bluetoothState = BluetoothState.UNKNOWN; //蓝牙状态
  static BluetoothDevice? curDevice; //蓝牙设备信息
  static BluetoothConnection? connection; //蓝牙连接信息
  static String curAddress = ""; //cursor address?
  static bool isBonded = false; //是否绑定
  static String tip = '当前状态：未连接设备';
  static List<DeviceWithAvailability> devices =
      List<DeviceWithAvailability>.empty(growable: true);
  static List<DeviceWithAvailability> devices2 =
      List<DeviceWithAvailability>.empty(growable: true);

  static const timeout = Duration(seconds: 1);

  bool get isConnected => (connection?.isConnected ?? false);

  void reset() {
    tip = '当前状态：未连接设备';
    curAddress = "";
    curDevice = null;
    isBonded = false;
    CalibrationValue.testedDevice = "testBluetooth";
  }

  void detectDevice() {
    if (isBonded) return;
    //获得绑定蓝牙设备信息
    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
      devices = bondedDevices
          .map(
            (device) => DeviceWithAvailability(
              device,
              DeviceAvailability.yes,
            ),
          )
          .toList();
//列表添加蓝牙设备
      if (devices.isNotEmpty) {
        for (var d in devices) {
          if (d.device.isConnected) {
            GlobalBlueToothArgs.curAddress = d.device.address;
            GlobalBlueToothArgs.curDevice = d.device;
            GlobalBlueToothArgs.isBonded = d.device.isBonded;
            CalibrationValue.testedDevice = d.device.name!;
            GlobalBlueToothArgs.tip =
                '当前状态：已连接' + CalibrationValue.testedDevice;
          }
        }
      }
    });
  }
}
