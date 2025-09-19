/// 测试记录信息
class TestRecord {
  ///是否编辑被试者信息，0为编辑被试者信息
  static bool isNewSubject = true;

  /// 被试者ID
  static int subjectId = 0;

  /// 模式，分为练习模式和正式模式
  static String mode = "";

  /// 创建时间
  static String createTime = "";

  /// 助听状态
  static String hearingStatus = "无助听状态";

  /// 语料类型（短/中/长）
  static String corpusType = "短";

  /// 测试环境
  static String environment = "安静";

  /// 测试播放表号
  static int tableId = 1;

  /// 播放声压级（dB）
  static int playVolumeDB = 40;

  ///测试结果详细
  static List result = List.empty(growable: true);

  ///测试结果
  static String accuracy = '';

  ///测听记录的id
  static int id = -1;
}
