import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

class DioClient {
  DioClient._internal();
  static Dio? _dio;

  // 获取全局唯一dio实例
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio();
      dio.interceptors.add(CookieManager(CookieJar()));
    }
    return _dio!;
  }

  // 获取API网址
  static String get baseurl => "http://175.27.222.58:5000";
}
//http://150.158.198.23:443/swagger/index.html
//192.168.110.46:5184
//175.27.222.58:5000