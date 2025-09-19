class audioGram {
  ///判断右耳是否修改
  static bool changeRightEar = false;

  ///判断左耳是否修改
  static bool changeLeftEar = false;

  ///是否为右耳，默认为右耳
  static bool isRightEar = true;

  ///右耳数据
  static List<List<double>> rightEarData =
      List.generate(7, (index) => [index + 0.0, 0]);

  ///左耳数据
  static List<List<double>> leftEarData =
      List.generate(7, (index) => [index + 0.0, 0]);

  ///右耳
  static String rightEar = 'right';

  ///左耳
  static String leftEar = 'left';
}
