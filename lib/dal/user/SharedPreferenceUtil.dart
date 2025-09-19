import 'package:shared_preferences/shared_preferences.dart';
import 'package:xinyutest/dal/user/userdata.dart';

///本地数据库相关的工具，主要用于账号存储至本地
class SharedPreferenceUtil {
  static const String ACCOUNT_NUMBER = "account_number";
  static const String USERPHONE = "userphone";
  static const String PASSWORD = "password";
  static const bool REMEBER = false;

  ///删掉单个账号
  static void delUser(User user) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    List<User> list = await getUsers();
    list.remove(user);
    saveUsers(list, sp);
  }

  ///保存账号，如果重复，就将最近登录账号放在第一个
  static void saveUser(User user) async {
    print('success');
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      print('success');
      List<User> list = await getUsers();

      addNoRepeat(list, user);
      saveUsers(list, sp);
    } catch (e) {
      print(e);
    }
  }

  ///去重并维持次序
  static void addNoRepeat(List<User> users, User user) {
    if (users.contains(user)) {
      users.remove(user);
    }
    users.insert(0, user);
  }

  ///获取已经登录的账号列表
  static Future<List<User>> getUsers() async {
    List<User> list = List.empty(growable: true);
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      int num = sp.getInt(ACCOUNT_NUMBER) ?? 0;
      if (num == 0) {
        return list;
      } else {
        for (int i = 0; i < num; i++) {
          var userphone = sp.getString("$USERPHONE$i");
          var password = sp.getString("$PASSWORD$i");
          var remeber = sp.getBool("$REMEBER$i");
          list.add(User(userphone!, password!, remeber!));
        }
        return list;
      }
    } catch (e) {
      print(e);
      return list;
    }
  }

  ///保存账号列表
  static saveUsers(List<User> users, SharedPreferences sp) {
    sp.clear();
    int size = users.length;
    for (int i = 0; i < size; i++) {
      sp.setString("$USERPHONE$i", users[i].userphone);
      sp.setString("$PASSWORD$i", users[i].password);
      sp.setBool("$REMEBER$i", users[i].remeber);
    }
    sp.setInt(ACCOUNT_NUMBER, size);
  }
}
