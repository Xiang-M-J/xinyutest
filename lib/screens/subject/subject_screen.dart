import 'package:flutter/material.dart';
import 'components/body.dart';

class SubjectScreen extends StatelessWidget {
  static String routeName = "/subject";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subject"),
      ),
      body: Body(),
    );
  }
}