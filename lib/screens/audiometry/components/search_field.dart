import 'package:flutter/material.dart';
import '../../../config/constants.dart';
import '../../../config/size_config.dart';

class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const SearchField({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth * 0.8,
      decoration: BoxDecoration(
        color: kSecondaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
                horizontal: getProportionateScreenWidth(20),
                vertical: getProportionateScreenWidth(9)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            hintText: "查找被试者",
            prefixIcon: const Icon(Icons.search)),
      ),
    );
  }
}