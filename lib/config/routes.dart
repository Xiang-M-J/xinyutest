// We use name route
// All our routes will be available here

import 'package:flutter/widgets.dart';
import '../screens/forgot_password/forgot_password.dart';
import '../screens/home/home_screen.dart';
import '../screens/login_success/login_success_screen.dart';
import '../screens/sgin_in/sign_in_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/subject/subject_screen.dart';
import 'package:xinyutest/screens/subject_management/subjectmana_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  SignInScreen.routeName: (context) => SignInScreen(),
  ForgotPasswordScreen.routeName: (context) => ForgotPasswordScreen(),
  // LoginSuccessScreen.routeName: (context) => LoginSuccessScreen(),
  SignUpScreen.routeName: (context) => SignUpScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  SubjectScreen.routeName: (context) => SubjectScreen(),
  SubjectManagementScreen.routeName: (context) => SubjectManagementScreen(),
};
