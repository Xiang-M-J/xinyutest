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

// @override
// bool operator == (other) {
//   return (_username == other._username) && (_password == other._password);
// }

}
