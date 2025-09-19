import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';
import 'subject_form.dart';
import 'package:xinyutest/Global/test_record.dart';

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
                Text("被试信息", style: headingStyle),
                TestRecord.isNewSubject
                    ? const Text(
                        "添加被试者的详细信息",
                        textAlign: TextAlign.center,
                      )
                    : const Text(
                        "编辑被试者的详细信息",
                        textAlign: TextAlign.center,
                      ),
                SizedBox(height: SizeConfig.screenHeight * 0.04),
                SubjectForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
