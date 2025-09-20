class User{
  String _userphone;
  String _password;
  bool _remeber;


  User(this._userphone,
      this._password,
      this._remeber);

  get userphone => _userphone;
  get password => _password;
  get remeber => _remeber;

  @override
  String toString() {
    return "|$_userphone $_password $_remeber|";
  }

  // 从 JSON 解析用户信息（登录接口返回数据时使用）
  factory User.fromJson(Map<String, dynamic> json) {
    return User(json['username'], json['password'], json['remeber']);
    
     }

  // 转换为 JSON（用于本地存储）
  Map<String, dynamic> toJson() {
    return {
      'username': _userphone,
      'password': _password,
      'remeber': _remeber,
    };
  }

// @override
// bool operator == (other) {
//   return (_username == other._username) && (_password == other._password);
// }

}
