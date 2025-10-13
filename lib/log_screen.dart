import 'package:constyle/utils.dart';
import 'package:constyle/widgets/button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  _SendCodeScreenState createState() => _SendCodeScreenState();
}

class _SendCodeScreenState extends State<LogScreen> {

  double windowWidth = 0;
  double windowHeight = 0;
  var _text = "";

  @override
  void initState() {
    _text = getLogText();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    windowWidth = MediaQuery.of(context).size.width;
    windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          margin: const EdgeInsets.all(5),
        child: Stack(
          children: [
            ListView(
              children: [
                _text.isEmpty ? const Text("empty") : Text(_text),
              ],
            ),
            Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(child: button2("Cancel", (){
                    Navigator.pop(context,);
                  }, )),
                  const SizedBox(width: 10,),
                  Expanded(child: button2("Copy", (){
                    Clipboard.setData(ClipboardData(text: _text));
                    messageOk(context, "Текст скопирован");
                  }, )),
                ],
              )
            )
          ],
        ))
    );
  }
}


