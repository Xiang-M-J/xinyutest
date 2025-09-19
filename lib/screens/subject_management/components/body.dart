import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';
import 'subjectmana_form.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: getProportionateScreenWidth(20)),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text("信息管理", style: headingStyle),
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                SubjectManagementForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
