/// 声场校准全局变量
class CalibrationValue {
  /// 测试设备信息
  static String testingDevice = "";

  /// 被测设备信息
  static String testedDevice = "testBluetooth";

  /// 校准时间（年月日）
  static String testTime = "";

  /// 环境校准值（dB）
  static int micCalibrationDB = 0;

  /// 蓝牙音响校准值（dB）
  static int calibrationDB = 90;

  /// 蓝牙音响校准值所对应的内置播放器音量
  static double calibrationVolume = 1.0;

  ///校准完成标记，用于完成校准后的首次测听跳过再次环境评估
  static bool newCalibrationFinished = false;

  ///录制的环境音频路径
  static String recordPath = "";
}
