import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:xinyutest/dal/user/userdata.dart';

class UserManager {
  // 单例实例
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // 初始化：从本地读取用户信息
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_info');
    if (userJson != null) {
      _currentUser = User.fromJson(json.decode(userJson));
    }
  }

  // 登录：保存用户信息
  Future<void> login(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_info', json.encode(user.toJson()));
  }

  // 退出登录：清除用户信息
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('user_info');
  }
}