import 'package:flutter/material.dart';
import 'components/body.dart';

class SubjectManagementScreen extends StatelessWidget {
  static String routeName = "/subject_management";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("SubjectManagement"),
      ),
      body: Body(),
    );
  }
}