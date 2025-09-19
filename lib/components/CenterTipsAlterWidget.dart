import 'package:flutter/cupertino.dart';
import '../config/constants.dart';
class ShowDefineAlertWidget extends StatefulWidget {

  final String _title;
  final String _hintText;
  const ShowDefineAlertWidget(this._title, this._hintText);

  @override
  ShowDefineAlertWidgetState createState() => ShowDefineAlertWidgetState();
}

class ShowDefineAlertWidgetState extends State<ShowDefineAlertWidget> {

  @override
  Widget build(BuildContext context) {

    /// 设置弹框的宽度为屏幕宽度的86%
    var _dialogWidth = MediaQuery.of(context).size.width *0.86;

    return CupertinoAlertDialog(
      title: Text(widget._title),
      content: Column(
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Align(
            child: Text(widget._hintText),
            alignment: const Alignment(0, 0),
          ),
        ],
      ),
      actions: <Widget>[
        CupertinoDialogAction(
          child: const Text("确定",
          style: TextStyle(color: kPrimaryColor),),
          onPressed: () {
            Navigator.pop(context);
            //print("确定");
          },
        ),
      ],
    );

  }

}

