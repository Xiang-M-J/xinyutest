import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/adapter.dart';
// String PEM = "";

class DioClient {
  DioClient._internal();
  static Dio? _dio;
  

  // 获取全局唯一dio实例
  static Dio get dio {
    if (_dio == null) {
      _dio = Dio();
      dio.interceptors.add(CookieManager(CookieJar()));
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =(client){
        client.badCertificateCallback =(cert, host, port) {
          return true;
        };
      };
    }
    return _dio!;
  }

  // 获取API网址
  static String get baseurl => "http://175.27.222.58:5000";
  // static String get baseurl => "http://10.10.0.2:5000";
  // static String get baseurl => "http://10.0.2.2:5184";
}
//http://150.158.198.23:443/swagger/index.html
//192.168.110.46:5184
